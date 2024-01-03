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
    $Path = "."
)

try {
    $Path = Resolve-Path $Path

    $name = (Get-Content -Path "$Path/package.json" -Raw | ConvertFrom-Json).name
    $url = (Get-Content -Path "$Path/package.json" -Raw | ConvertFrom-Json).repository.url
    $tag = git describe --tags $(git rev-list --tags --max-count=1)

    if (!(Test-Path -Path ~/$name)) {
        New-Item -Path ~/$name -ItemType Directory | Out-Null
    }

    Write-Host "Cloning $tag" -ForegroundColor Green
    git clone --depth 1 --branch $tag $url ~/$name/$tag
    Remove-Item -Path ~/$name/$tag/.git -Recurse -Force | Out-Null
    New-Item -Path ~/$name/current -ItemType SymbolicLink -Value ~/$name/$tag | Out-Null

    Write-Host "Creating symlinks" -ForegroundColor Green
    ~/$name/current/SymLink.ps1
}
catch {
    Write-Host $_.Exception.GetBaseException().Message -ForegroundColor Red
    exit 1
}
