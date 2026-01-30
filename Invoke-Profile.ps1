#Requires -Modules Posh-SSH

[CmdletBinding()]

param(
    [Parameter(Mandatory = $false)]
    [string]$HostName,

    [Parameter(Mandatory = $false)]
    [string]$UserName = "testrunner",

    [Parameter(Mandatory = $false)]
    [int]$Port = 22,

    [Parameter(Mandatory = $false)]
    [int]$Timeout = 0,  # 0 = run indefinitely until Ctrl-C

    [Parameter(Mandatory = $false)]
    [int]$Interval = 15  # Seconds between samples (default 15 to account for 10s CPU measurement)
)

<#
.SYNOPSIS
    Profiles CPU and memory usage on an AMX device over time via SSH.

.DESCRIPTION
    Connects to an AMX device and continuously monitors CPU usage and memory statistics.
    Collects data samples and displays statistics (min/max/avg) on completion.

.PARAMETER HostName
    The hostname or IP address of the AMX device.

.PARAMETER UserName
    The username to authenticate with (default: testrunner).

.PARAMETER Port
    The SSH port (default: 22).

.PARAMETER Timeout
    Duration in seconds to run profiling. If 0 or omitted, runs until Ctrl-C.

.PARAMETER Interval
    Seconds between samples (default: 15). Should be >= 15 to allow for CPU measurement time.

.EXAMPLE
    # Run for 5 minutes, sampling every 20 seconds
    .\Invoke-Profile.ps1 -HostName "192.168.1.100" -Timeout 300 -Interval 20

.EXAMPLE
    # Run indefinitely until Ctrl-C
    .\Invoke-Profile.ps1 -HostName "192.168.1.100"

.EXAMPLE
    # Use environment variables
    $env:AMX_TESTRUNNER_SSH_HOST = "192.168.1.100"
    $env:AMX_TESTRUNNER_SSH_PASSWORD = "mypassword"
    .\Invoke-Profile.ps1
#>

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "INFO" { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        default { "White" }
    }

    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Parse-CpuUsage {
    param([string]$Output)

    if ($Output -match 'CPU usage = ([\d.]+)%') {
        return [double]$matches[1]
    }
    return $null
}

function Parse-MemoryStats {
    param([string]$Output)

    $stats = @{}

    if ($Output -match 'Volatile Free\s*:\s*([\d]+)/([\d]+)') {
        $stats.VolatileFree = [long]$matches[1]
        $stats.VolatileMax = [long]$matches[2]
        $stats.VolatileUsedPercent = [math]::Round((1 - ($stats.VolatileFree / $stats.VolatileMax)) * 100, 2)
    }

    if ($Output -match 'NonVolatile Free\s*:\s*([\d]+)/([\d]+)') {
        $stats.NonVolatileFree = [long]$matches[1]
        $stats.NonVolatileMax = [long]$matches[2]
        $stats.NonVolatileUsedPercent = [math]::Round((1 - ($stats.NonVolatileFree / $stats.NonVolatileMax)) * 100, 2)
    }

    if ($Output -match 'Disk Free\s*:\s*([\d]+)/([\d]+)') {
        $stats.DiskFree = [long]$matches[1]
        $stats.DiskMax = [long]$matches[2]
        $stats.DiskUsedPercent = [math]::Round((1 - ($stats.DiskFree / $stats.DiskMax)) * 100, 2)
    }

    if ($Output -match 'Duet Memory Free\s*:\s*([\d]+)/([\d]+)') {
        $stats.DuetMemoryFree = [long]$matches[1]
        $stats.DuetMemoryMax = [long]$matches[2]
        $stats.DuetMemoryUsedPercent = [math]::Round((1 - ($stats.DuetMemoryFree / $stats.DuetMemoryMax)) * 100, 2)
    }

    return $stats
}

function Format-Bytes {
    param([long]$Bytes)

    if ($Bytes -ge 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    }
    elseif ($Bytes -ge 512KB) {
        # Show MB for anything >= 512KB for consistency
        return "{0:N2} MB" -f ($Bytes / 1MB)
    }
    elseif ($Bytes -ge 1KB) {
        return "{0:N2} KB" -f ($Bytes / 1KB)
    }
    else {
        return "$Bytes bytes"
    }
}

function Show-Statistics {
    param([array]$Samples)

    if ($Samples.Count -eq 0) {
        Write-Log "No samples collected" "WARNING"
        return
    }

    Write-Host "`n" -NoNewline
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host "PROFILING STATISTICS" -ForegroundColor Cyan
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host ""

    $duration = ($Samples[-1].Timestamp - $Samples[0].Timestamp).TotalSeconds
    Write-Host "Duration       : " -NoNewline -ForegroundColor Gray
    Write-Host ("{0:N0} seconds" -f $duration) -ForegroundColor White
    Write-Host "Samples        : " -NoNewline -ForegroundColor Gray
    Write-Host $Samples.Count -ForegroundColor White
    Write-Host "Interval       : " -NoNewline -ForegroundColor Gray
    Write-Host ("{0:N1} seconds (avg)" -f ($duration / ($Samples.Count - 1))) -ForegroundColor White
    Write-Host ""

    # CPU Usage Statistics
    $cpuSamples = $Samples | Where-Object { $null -ne $_.CpuUsage }
    if ($cpuSamples.Count -gt 0) {
        $cpuValues = $cpuSamples | ForEach-Object { $_.CpuUsage }
        $cpuMin = ($cpuValues | Measure-Object -Minimum).Minimum
        $cpuMax = ($cpuValues | Measure-Object -Maximum).Maximum
        $cpuAvg = ($cpuValues | Measure-Object -Average).Average

        Write-Host "CPU USAGE" -ForegroundColor Yellow
        Write-Host "---------" -ForegroundColor Yellow
        Write-Host "  Minimum      : " -NoNewline -ForegroundColor Gray
        Write-Host ("{0:N2}%" -f $cpuMin) -ForegroundColor Green
        Write-Host "  Maximum      : " -NoNewline -ForegroundColor Gray
        Write-Host ("{0:N2}%" -f $cpuMax) -ForegroundColor Red
        Write-Host "  Average      : " -NoNewline -ForegroundColor Gray
        Write-Host ("{0:N2}%" -f $cpuAvg) -ForegroundColor Cyan
        Write-Host ""
    }

    # Memory Statistics
    $memSamples = $Samples | Where-Object { $null -ne $_.Memory }
    if ($memSamples.Count -gt 0) {
        Write-Host "VOLATILE MEMORY (RAM)" -ForegroundColor Yellow
        Write-Host "---------------------" -ForegroundColor Yellow

        $volFree = $memSamples | ForEach-Object { $_.Memory.VolatileFree }
        $volMin = ($volFree | Measure-Object -Minimum).Minimum
        $volMax = ($volFree | Measure-Object -Maximum).Maximum
        $volAvg = ($volFree | Measure-Object -Average).Average
        $volMaxTotal = $memSamples[0].Memory.VolatileMax

        Write-Host "  Free (min)   : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $volMin) -ForegroundColor Red
        Write-Host "  Free (max)   : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $volMax) -ForegroundColor Green
        Write-Host "  Free (avg)   : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $volAvg) -ForegroundColor Cyan
        Write-Host "  Total        : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $volMaxTotal) -ForegroundColor White

        # Volatile memory leak detection
        if ($memSamples.Count -ge 3) {
            $volRate = ($volFree[0] - $volFree[-1]) / $duration
            if ($volRate -gt 100) {
                # Only show if > 100 bytes/sec
                Write-Host "  Leak rate    : " -NoNewline -ForegroundColor Gray
                Write-Host ("{0}/second" -f (Format-Bytes $volRate)) -ForegroundColor Red
                $timeToEmpty = $volFree[-1] / $volRate
                Write-Host "  Time to full : " -NoNewline -ForegroundColor Gray
                Write-Host ("{0:N1} hours" -f ($timeToEmpty / 3600)) -ForegroundColor Red
            }
        }
        Write-Host ""

        Write-Host "NON-VOLATILE MEMORY (Flash)" -ForegroundColor Yellow
        Write-Host "---------------------------" -ForegroundColor Yellow

        $nonVolFree = $memSamples | ForEach-Object { $_.Memory.NonVolatileFree }
        $nonVolMin = ($nonVolFree | Measure-Object -Minimum).Minimum
        $nonVolMax = ($nonVolFree | Measure-Object -Maximum).Maximum
        $nonVolAvg = ($nonVolFree | Measure-Object -Average).Average
        $nonVolMaxTotal = $memSamples[0].Memory.NonVolatileMax

        Write-Host "  Free (min)   : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $nonVolMin) -ForegroundColor Red
        Write-Host "  Free (max)   : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $nonVolMax) -ForegroundColor Green
        Write-Host "  Free (avg)   : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $nonVolAvg) -ForegroundColor Cyan
        Write-Host "  Total        : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $nonVolMaxTotal) -ForegroundColor White

        # Non-volatile memory leak detection
        if ($memSamples.Count -ge 3) {
            $nonVolRate = ($nonVolFree[0] - $nonVolFree[-1]) / $duration
            if ($nonVolRate -gt 100) {
                # Only show if > 100 bytes/sec
                Write-Host "  Leak rate    : " -NoNewline -ForegroundColor Gray
                Write-Host ("{0}/second" -f (Format-Bytes $nonVolRate)) -ForegroundColor Red
                $timeToEmpty = $nonVolFree[-1] / $nonVolRate
                Write-Host "  Time to full : " -NoNewline -ForegroundColor Gray
                Write-Host ("{0:N1} hours" -f ($timeToEmpty / 3600)) -ForegroundColor Red
            }
        }
        Write-Host ""

        Write-Host "DUET MEMORY" -ForegroundColor Yellow
        Write-Host "-----------" -ForegroundColor Yellow

        $duetFree = $memSamples | ForEach-Object { $_.Memory.DuetMemoryFree }
        $duetMin = ($duetFree | Measure-Object -Minimum).Minimum
        $duetMax = ($duetFree | Measure-Object -Maximum).Maximum
        $duetAvg = ($duetFree | Measure-Object -Average).Average
        $duetMaxTotal = $memSamples[0].Memory.DuetMemoryMax

        Write-Host "  Free (min)   : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $duetMin) -ForegroundColor Red
        Write-Host "  Free (max)   : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $duetMax) -ForegroundColor Green
        Write-Host "  Free (avg)   : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $duetAvg) -ForegroundColor Cyan
        Write-Host "  Total        : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $duetMaxTotal) -ForegroundColor White
        Write-Host ""

        Write-Host "DISK SPACE" -ForegroundColor Yellow
        Write-Host "----------" -ForegroundColor Yellow

        $diskFree = $memSamples | ForEach-Object { $_.Memory.DiskFree }
        $diskAvg = ($diskFree | Measure-Object -Average).Average
        $diskMaxTotal = $memSamples[0].Memory.DiskMax

        Write-Host "  Free (avg)   : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $diskAvg) -ForegroundColor Cyan
        Write-Host "  Total        : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-Bytes $diskMaxTotal) -ForegroundColor White
        Write-Host ""
    }

    Write-Host "=" * 80 -ForegroundColor Cyan
}

function Start-InterruptibleSleep {
    param([int]$Milliseconds)

    $iterations = [Math]::Ceiling($Milliseconds / 100)
    for ($i = 0; $i -lt $iterations; $i++) {
        if ($script:StopRequested) { break }
        Start-Sleep -Milliseconds 100
    }
}

# Global variables for cleanup
$script:Samples = @()
$script:Session = $null
$script:Stream = $null

try {
    # Load .env file if it exists
    $envFile = Join-Path $PSScriptRoot ".env"
    if (Test-Path $envFile) {
        Write-Log "Loading environment variables from .env file"
        Get-Content $envFile | ForEach-Object {
            $line = $_.Trim()
            if ($line -and -not $line.StartsWith("#")) {
                if ($line -match '^([^=]+)=(.*)$') {
                    $key = $matches[1].Trim()
                    $value = $matches[2].Trim() -replace '^["'']|["'']$', ''
                    [Environment]::SetEnvironmentVariable($key, $value, "Process")
                }
            }
        }
    }

    # Check if Posh-SSH module is available
    if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
        Write-Log "Posh-SSH module is not installed. Installing..." "WARNING"
        Install-Module -Name Posh-SSH -Force -Scope CurrentUser
        Write-Log "Posh-SSH module installed successfully" "SUCCESS"
    }

    Import-Module Posh-SSH -ErrorAction Stop

    # Resolve HostName
    if ([string]::IsNullOrEmpty($HostName)) {
        if (Test-Path env:AMX_TESTRUNNER_SSH_HOST) {
            $HostName = $env:AMX_TESTRUNNER_SSH_HOST
        }
        else {
            $HostName = Read-Host "Enter hostname or IP address"
        }
    }

    # Resolve UserName
    if (-not $PSBoundParameters.ContainsKey('UserName') -and (Test-Path env:AMX_TESTRUNNER_SSH_USER)) {
        $UserName = $env:AMX_TESTRUNNER_SSH_USER
    }

    Write-Log "Starting profiling session on ${UserName}@${HostName}:${Port}"
    if ($Timeout -gt 0) {
        Write-Log "Duration: $Timeout seconds (sampling every $Interval seconds)"
    }
    else {
        Write-Log "Duration: Indefinite (press Ctrl-C to stop, sampling every $Interval seconds)"
    }

    # Get password
    $securePassword = $null
    if (Test-Path env:AMX_TESTRUNNER_SSH_PASSWORD) {
        $password = $env:AMX_TESTRUNNER_SSH_PASSWORD
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    }
    else {
        $securePassword = Read-Host "Enter password for ${UserName}@${HostName}" -AsSecureString
    }

    # Create credential and establish session
    $credential = New-Object System.Management.Automation.PSCredential($UserName, $securePassword)

    Write-Log "Establishing SSH session..."
    $script:Session = New-SSHSession -ComputerName $HostName -Port $Port -Credential $credential -AcceptKey -ErrorAction Stop

    if ($null -eq $script:Session) {
        Write-Log "Failed to establish SSH session" "ERROR"
        exit 1
    }

    Write-Log "SSH session established (Session ID: $($script:Session.SessionId))" "SUCCESS"

    # Create shell stream
    $script:Stream = New-SSHShellStream -SSHSession $script:Session -ErrorAction Stop

    # Wait for initial prompt and clear it
    Start-Sleep -Milliseconds 500
    $null = $script:Stream.Read()

    # Sample collection
    $script:Samples = @()
    $startTime = Get-Date
    $sampleCount = 0

    Write-Host "`nStarting profiling... (Ctrl-C to stop)`n" -ForegroundColor Green

    while ($true) {
        # Check timeout
        if ($Timeout -gt 0) {
            $elapsed = ((Get-Date) - $startTime).TotalSeconds
            if ($elapsed -ge $Timeout) {
                Write-Log "Timeout reached ($Timeout seconds)" "INFO"
                break
            }
        }

        $sampleTime = Get-Date
        $sampleCount++

        Write-Host "[Sample $sampleCount at $($sampleTime.ToString('HH:mm:ss'))]" -ForegroundColor Cyan

        # Get CPU usage
        Write-Host "  Measuring CPU... " -NoNewline
        $script:Stream.WriteLine("cpu usage")
        Start-Sleep -Milliseconds 11000  # Wait for 10s measurement + buffer
        $cpuOutput = $script:Stream.Read()
        $cpuUsage = Parse-CpuUsage -Output $cpuOutput

        if ($null -ne $cpuUsage) {
            Write-Host ("{0:N2}%" -f $cpuUsage) -ForegroundColor Yellow
        }
        else {
            Write-Host "Failed" -ForegroundColor Red
        }

        # Get memory stats
        Write-Host "  Measuring Memory... " -NoNewline
        $script:Stream.WriteLine("show mem")
        Start-Sleep -Milliseconds 500
        $memOutput = $script:Stream.Read()
        $memStats = Parse-MemoryStats -Output $memOutput

        if ($memStats.Count -gt 0) {
            Write-Host "Volatile: $(Format-Bytes $memStats.VolatileFree) free, Non-Volatile: $(Format-Bytes $memStats.NonVolatileFree) free" -ForegroundColor Yellow
        }
        else {
            Write-Host "Failed" -ForegroundColor Red
        }

        # Store sample
        $script:Samples += [PSCustomObject]@{
            Timestamp = $sampleTime
            CpuUsage  = $cpuUsage
            Memory    = if ($memStats.Count -gt 0) { $memStats } else { $null }
        }

        # Wait for next interval (accounting for time already spent)
        $processingTime = ((Get-Date) - $sampleTime).TotalSeconds
        $waitTime = [Math]::Max(0, $Interval - $processingTime)

        if ($waitTime -gt 0) {
            Write-Host ""
            Start-Sleep -Seconds $waitTime
        }
    }

    # Normal completion
    Write-Host ""
    Write-Log "Profiling completed. Collected $($script:Samples.Count) samples." "SUCCESS"

}
catch {
    # Ctrl-C or other error
    Write-Host ""
    if ($_.Exception -is [System.Management.Automation.PipelineStoppedException]) {
        Write-Log "Profiling interrupted by user (Ctrl-C)" "WARNING"
    }
    else {
        Write-Log "Error: $_" "ERROR"
        Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    }
}
finally {
    # Always runs - cleanup and show statistics
    if ($null -ne $script:Stream) {
        try { $script:Stream.Dispose() } catch { }
    }
    if ($null -ne $script:Session) {
        try {
            Remove-SSHSession -SessionId $script:Session.SessionId -ErrorAction SilentlyContinue | Out-Null
            Write-Log "SSH session closed" "SUCCESS"
        }
        catch { }
    }

    # Show statistics if we collected samples
    if ($script:Samples.Count -gt 0) {
        Show-Statistics -Samples $script:Samples
    }
    else {
        Write-Log "No samples collected" "WARNING"
    }
}
