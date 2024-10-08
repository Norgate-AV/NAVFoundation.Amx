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
    $OutDir = "dist"
)

try {
    $Path = Resolve-Path -Path $Path

    $manifest = Get-Content -Path "$Path/manifest.json" -Raw | ConvertFrom-Json

    if (!$manifest) {
        Write-Error "No manifest.json file found in $Path"
        exit 1
    }

    $version = $manifest.version
    $name = $manifest.name

    $files = @()

    foreach ($file in $manifest.files) {
        $files += Get-ChildItem -File $file -ErrorAction Stop | Where-Object { $_.FullName -notmatch "(.git|.history|node_modules|dist)" }
    }

    $files += "$Path/manifest.json"

    if (-not(Test-Path -Path "$Path/$OutDir")) {
        New-Item -Path "$Path/$OutDir" -Type Directory | Out-Null
    }

    $zip = "$Path/$OutDir/$name.$version.archive.zip"
    Compress-Archive -Path $files -DestinationPath $zip -Force

    (Get-FileHash $zip).Hash.ToLower() | Out-File -FilePath "$zip.sha256" -Encoding ascii
}
catch {
    Write-Host $_.Exception.GetBaseException().Message -ForegroundColor Red
    exit 1
}
