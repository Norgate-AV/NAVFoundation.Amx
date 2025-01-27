#!/usr/bin/env pwsh

<#
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>


[CmdletBinding()]

param (
    [Parameter(Mandatory = $false)]
    [string]
    $Path = ".",

    [Parameter(Mandatory = $false)]
    [string]
    $OutDir = "vendor",

    [Parameter(Mandatory = $false)]
    [switch]
    $Symlink = $false
)

function Get-ConfigConverter {
    param (
        [string]$Path,
        [switch]$To
    )

    switch ([System.IO.Path]::GetExtension($Path)) {
        ".json" {
            if ($To) {
                { process { $_ | ConvertTo-Json -Depth 10 } }
            }
            else {
                { process { $_ | ConvertFrom-Json } }
            }
        }
        { $_ -in ".yaml", ".yml" } {
            if ($To) {
                { process { $_ | ConvertTo-Yaml } }
            }
            else {
                { process { $_ | ConvertFrom-Yaml } }
            }
        }
        default { throw "Unsupported file extension: $Path" }
    }
}

function Get-GitHubRepoInfo {
    param (
        [string]$url
    )

    if ($url -match "github.com/([^/]+)/([^/]+)") {
        return @{
            Owner = $matches[1]
            Repo  = $matches[2]
        }
    }

    throw "Invalid GitHub URL format: $url"
}

function Get-GitHubRelease {
    param (
        [string]$owner,
        [string]$repo,
        [string]$version,
        [string]$destinationPath
    )

    $version = $version -replace "^v", ""
    $url = "https://github.com/$owner/$repo/releases/download/v$version"

    $files = @("$repo.$version.archive.zip")

    try {
        foreach ($file in $files) {
            $fileUrl = "$url/$file"
            $filePath = Join-Path $destinationPath $file

            Write-Host "Downloading $file..."
            Invoke-WebRequest -Uri $fileUrl -OutFile $filePath

            # Check for a matching checksum file at the same url
            # Download and verify the checksum if it exists
            $checksumUrl = "$fileUrl.sha256"
            $checksumPath = "$filePath.sha256"

            if (Invoke-WebRequest -Uri $checksumUrl -UseBasicParsing -Method Head -ErrorAction SilentlyContinue) {
                Write-Host "Verifying checksum..."
                Invoke-WebRequest -Uri $checksumUrl -OutFile $checksumPath

                $checksum = Get-Content -Path $checksumPath
                $hash = Get-FileHash -Path $filePath -Algorithm SHA256

                if ($hash.Hash -ne $checksum) {
                    throw "Checksum verification failed for $file"
                }
            }

            # Delete checksum file
            if (Test-Path $checksumPath) {
                Remove-Item -Path $checksumPath
            }

            # Extract archive
            Write-Host "Extracting $file..."
            $global:ProgressPreference = "SilentlyContinue"
            Expand-Archive -Path $filePath -DestinationPath $destinationPath
            $global:ProgressPreference = "Continue"

            # Delete archive
            Remove-Item -Path $filePath
        }
    }
    catch {
        throw "Failed to download release: $_"
    }
}

function Get-GitHubReleases {
    param (
        [string]$Owner,
        [string]$Repo
    )

    $apiUrl = "https://api.github.com/repos/$Owner/$Repo/releases"
    Write-Host "Fetching releases..."

    $headers = @{
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }

    # Check the environment for a GitHub token
    # If a variable called GITHUB_TOKEN is set, use it for authentication
    $token = [Environment]::GetEnvironmentVariable("GITHUB_TOKEN")

    if ($token) {
        $headers["Authorization"] = "Bearer $token"
    }

    $params = @{
        Uri = $apiUrl
        UseBasicParsing = $true
        Headers = $headers
        ContentType = "application/json"
    }

    $releases = Invoke-RestMethod @params

    # Extract version numbers and sort them
    $versions = @($releases | ForEach-Object {
        # Try to extract version from tag_name
        if ($_.tag_name -match 'v?(\d+\.\d+\.\d+)') {
            @{
                Version = $matches[1]
                TagName = $_.tag_name
            }
        }
    } | Where-Object { $null -ne $_.Version })

    return $versions
}

function Find-GenlinxRc {
    param (
        [string]$Path
    )

    $genlinxrcPath = Get-ChildItem -Path $Path -Recurse -File -Filter ".genlinxrc.*" `
        -ErrorAction SilentlyContinue | Select-Object -First 1

    return $genlinxrcPath
}

function Update-GenlinxRc {
    param (
        [string]$Path,
        [string]$OutDir,
        [string]$DependencyOwner,
        [string]$DependencyUrl,
        [string]$DependencyVersion
    )

    if (-not (Test-Path $Path)) {
        throw "Invalid path: $Path"
    }

    Write-Host "Updating .genlinxrc..."

    $convertFrom = Get-ConfigConverter -Path $Path
    $convertTo = Get-ConfigConverter -Path $Path -To

    $genlinxrc = Get-Content -Path $Path -Raw | & $convertFrom

    # Ensure `.` is replaced with `-` in the owner and repo names, and version
    $DependencyOwner = $DependencyOwner.Replace(".", "-")
    $DependencyUrl = $DependencyUrl.Replace(".", "-")
    $DependencyVersion = $DependencyVersion.Replace(".", "-")

    $genlinxrc.build.nlrc.includePath += "./$OutDir/$DependencyOwner/$DependencyUrl/$DependencyVersion"
    $genlinxrc.build.nlrc.modulePath += "./$OutDir/$DependencyOwner/$DependencyUrl/$DependencyVersion"

    # Ensure the paths are unique
    $genlinxrc.build.nlrc.includePath = @($genlinxrc.build.nlrc.includePath | Select-Object -Unique)
    $genlinxrc.build.nlrc.modulePath = @($genlinxrc.build.nlrc.modulePath | Select-Object -Unique)

    $genlinxrc | & $convertTo | Out-File -FilePath $Path -NoNewline
}

function New-GenlinxRc {
    param (
        [string]$Path
    )

    $contents = @{
        build = @{
            nlrc = @{
                includePath = @()
                modulePath = @()
            }
        }
    }

    $contents | ConvertTo-Json -Depth 10 | Out-File -FilePath "$Path/.genlinxrc.json"
}

function Compare-Versions {
    param (
        [string]$Version1,
        [string]$Version2
    )

    $v1Parts = $Version1.Split('.') | ForEach-Object { [int]$_ }
    $v2Parts = $Version2.Split('.') | ForEach-Object { [int]$_ }

    for ($i = 0; $i -lt 3; $i++) {
        if ($v1Parts[$i] -gt $v2Parts[$i]) {
            return 1
        }

        if ($v1Parts[$i] -lt $v2Parts[$i]) {
            return -1
        }
    }

    return 0
}

function Get-CompatibleVersion {
    param (
        [string]$RequiredVersion,
        [string]$Prefix,
        [array]$AvailableVersions
    )

    Write-Host "Looking for compatible updates..."

    # Sort versions in descending order first
    $sortedVersions = $AvailableVersions | Sort-Object {
        # Split version into parts and cast each to integer for proper numeric sorting
        $parts = $_.Version.Split('.')
        [int]$parts[0] * 1000000 + [int]$parts[1] * 1000 + [int]$parts[2]
    } -Descending

    $reqParts = $RequiredVersion.Split('.') | ForEach-Object { [int]$_ }
    $compatible = $null

    foreach ($version in $sortedVersions) {
        $comparison = Compare-Versions $version.Version $RequiredVersion

        # If we hit a lower version, we can stop checking
        if ($comparison -lt 0) {
            break
        }

        $verParts = $version.Version.Split('.') | ForEach-Object { [int]$_ }

        $isCompatible = switch ($Prefix) {
            '^' { $true }  # We already know it's >= required version
            '~' { $verParts[0] -eq $reqParts[0] }  # Just check major version match
            default { $comparison -eq 0 }  # Exact match only
        }

        if ($isCompatible) {
            $compatible = $version
            break  # We can stop here since versions are sorted
        }
    }

    if ($null -eq $compatible) {
        return $null
    }

    return $compatible
}


function Get-Version {
    param (
        [string]$Version
    )

    Write-Host "Resolving version: $Version..."
    $requirement = Get-VersionRequirement -Version $Version

    # For exact versions, just return the cleaned version
    if (!$requirement.Prefix) {
        return $requirement.Version
    }

    # Get available releases
    $releases = Get-GitHubReleases -Owner $repoInfo.Owner -Repo $repoInfo.Repo

    # Find the best matching version
    $bestMatch = Get-CompatibleVersion -RequiredVersion $requirement.Version `
                                     -Prefix $requirement.Prefix `
                                     -AvailableVersions $releases

    if (!$bestMatch) {
        throw "No compatible updates found for $Version"
    }

    if ($bestMatch.Version -ne $requirement.Version) {
        Write-Host "Found compatible update: $($bestMatch.Version)"
    }

    Write-Host "Using version: $($bestMatch.Version)"
    return $bestMatch.Version
}

function Get-VersionRequirement {
    param (
        [string]$Version
    )

    $requirement = @{
        Original = $Version
        Prefix = $null
        Version = $null
    }

    if ($Version.StartsWith("^")) {
        $requirement.Prefix = "^"
        $requirement.Version = $Version.TrimStart("^")
    }
    elseif ($Version.StartsWith("~")) {
        $requirement.Prefix = "~"
        $requirement.Version = $Version.TrimStart("~")
    }
    else {
        $requirement.Version = $Version
    }

    # Validate version format
    if ($requirement.Version -notmatch "^\d+\.\d+\.\d+$") {
        throw "Invalid version format: $Version"
    }

    return $requirement
}

function Read-EnvFile {
    $envPath = Join-Path $PSScriptRoot ".env"

    if (-not (Test-Path $envPath)) {
        return
    }

    Get-Content $envPath | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, [EnvironmentVariableTarget]::Process)
        }
    }

    Write-Host "Loaded environment variables from .env file"
}

function Add-Symlinks {
    param (
        [string]$Path,
        [string]$Extension,
        [string]$TargetDirectory,
        [switch]$GitIgnore = $false
    )

    $files = Get-ChildItem -Path $Path -Recurse -Filter "*.$Extension" -ErrorAction SilentlyContinue

    if (!$files) {
        return
    }

    Write-Host "Symlinking .$Extension files..."

    if (-not (Test-Path $TargetDirectory)) {
        New-Item -ItemType Directory -Path $TargetDirectory | Out-Null
    }

    foreach ($file in $files) {
        $symlinkPath = Join-Path $TargetDirectory $file.Name
        New-Item -ItemType SymbolicLink -Path $symlinkPath -Target $file.FullName -Force | Out-Null

        if (!$GitIgnore) {
            continue
        }

        # Update .gitignore file with relative path to symlink
        $gitignoreFile = "$PSScriptRoot/.gitignore"
        $ignorePath = "$(Split-Path -Path $TargetDirectory -Leaf)/$($file.Name)"

        if (Select-String -Path $gitignoreFile -Pattern $ignorePath -Quiet) {
            continue
        }

        Add-Content -Path $gitignoreFile -Value $ignorePath
    }
}

try {
    $Path = Resolve-Path -Path $Path

    $manifest = Get-Content -Path "$Path/manifest.json" -Raw | ConvertFrom-Json

    if (!$manifest) {
        Write-Error "No manifest.json file found in $Path"
        exit 1
    }

    if ($env:CI) {
        Write-Host "Running in CI environment"
    } else {
        Write-Host "Running in local environment"
    }

    # Look for a .env file in the same directory.
    # If it exists, load the environment variables from it
    Read-EnvFile

    if (!$env:GITHUB_TOKEN) {
        Write-Host "GITHUB_TOKEN environment variable not set"
        Write-Host "GitHub API rate limits may apply"
    }

    $vendorPath = Join-Path $PSScriptRoot $OutDir

    $genlinxrc = Find-GenlinxRc -Path $Path
    if (!$genlinxrc) {
        Write-Host
        Write-Host "Creating new .genlinxrc file..."
        New-GenlinxRc -Path $Path

        $genlinxrc = Find-GenlinxRc -Path $Path
    }

    if ($genlinxrc.Extension -match "yml|yaml") {
        if (-not (Get-Module -Name powershell-yaml -ListAvailable)) {
            Write-Host "Installing powershell-yaml module..."
            Install-Module -Name powershell-yaml -Scope CurrentUser -Force
        }

        Import-Module -Name powershell-yaml
    }

    foreach ($dependency in $manifest.dependencies) {
        Write-Host
        Write-Host "Processing dependency $($dependency.url)..."

        try {
            $repoInfo = Get-GitHubRepoInfo -url $dependency.url

            $version = Get-Version -Version $dependency.version

            $packagePath = Join-Path $vendorPath "$($repoInfo.Owner.Replace(".", "-"))/$($repoInfo.Repo.Replace(".", "-"))/$($version.Replace(".", "-"))"
            if (-not (Test-Path $packagePath)) {
                New-Item -ItemType Directory -Path $packagePath | Out-Null
            }
            else {
                Write-Host "Dependency $($repoInfo.Repo)@$($version) already installed"
                continue
            }

            Get-GitHubRelease `
                -owner $repoInfo.Owner `
                -repo $repoInfo.Repo `
                -version $version `
                -destinationPath $packagePath

            if (!$Symlink) {
                # NLRC doesn't seem to like lots of paths in the includePath and modulePaths
                # Unsure of the exact number. It works upto a point and then fails.
                # If adding a lot of paths, it's better to symlink the files in the package instead
                if (!$genlinxrc) {
                    continue
                }

                Update-Genlinxrc `
                    -Path $genlinxrc `
                    -OutDir $OutDir `
                    -DependencyOwner $repoInfo.Owner `
                    -DependencyUrl $repoInfo.Repo `
                    -DependencyVersion $version
            } else {
                # This will allow the NLRC to find the files without having to add them to the .genlinxrc file
                # This is a workaround until we can figure out how to add the paths to the .genlinxrc file
                Add-Symlinks -Path $packagePath -Extension "axi" -TargetDirectory "$Path/include" -GitIgnore

                # tko, jar files are already ignored by Git
                Add-Symlinks -Path $packagePath -Extension "tko" -TargetDirectory "$Path/module"
                Add-Symlinks -Path $packagePath -Extension "jar" -TargetDirectory "$Path/module"
            }

            Write-Host "Successfully installed $($repoInfo.Repo)@$($version)"
        }
        catch {
            Write-Error "Failed to process dependency $($dependency.url): $_"
            Remove-Item -Path $packagePath -Recurse -Force
            continue
        }
    }
}
catch {
    Write-Host $_.Exception.GetBaseException().Message -ForegroundColor Red
    exit 1
}
