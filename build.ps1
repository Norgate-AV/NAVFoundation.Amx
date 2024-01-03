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

    $axiFiles = Get-ChildItem -Path $Path -Recurse -File -Filter *.axi -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch ".history" }
    $axsFiles = Get-ChildItem -Path $Path -Recurse -File -Filter *.axs -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch ".history" }

    if (!$axiFiles -and !$axsFiles) {
        Write-Host "No files found in $Path" -ForegroundColor Yellow
        exit
    }

    $files = [System.Collections.ArrayList]::new()

    foreach ($axiFile in $axiFiles) {
        $files += $axiFile
    }

    foreach ($axsFile in $axsFiles) {
        $files += $axsFile
    }

    Write-Host "Building $($files.Count) files..." -ForegroundColor Cyan

    foreach ($file in $files) {
        $x = $files.IndexOf($file) + 1
        Write-Host "Building file $x of $($files.Count)..." -ForegroundColor Cyan

        $percent = [math]::Round((($x - 1) / $files.Count) * 100, 2)
        Write-Host "[$percent%]" -ForegroundColor Cyan

        & "genlinx" build -s $file

        if ($LASTEXITCODE -ne 0) {
            Write-Host "genlinx failed with exit code $($LASTEXITCODE)" -ForegroundColor Red
            exit 1
        }
    }

    $percent = [math]::Round(($x / $files.Count) * 100, 2)
    Write-Host "[$percent%]" -ForegroundColor Cyan
    Write-Host "Build complete!" -ForegroundColor Green
}
catch {
    Write-Host $_.Exception.GetBaseException().Message -ForegroundColor Red
    exit 1
}
