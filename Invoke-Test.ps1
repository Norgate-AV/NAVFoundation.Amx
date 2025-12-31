#Requires -Modules Posh-SSH

[CmdletBinding()]

param(
    [Parameter(Mandatory = $false)]
    [string]$HostName,

    [Parameter(Mandatory = $false)]
    [string]$UserName = "testrunner",

    [Parameter(Mandatory = $false)]
    [int]$Port = 22
)

<#
.SYNOPSIS
    Initiates an SSH connection to an AMX device and runs control commands.

.DESCRIPTION
    This script connects to an AMX device via SSH and executes two specific commands:
    - msg on all
    - pulse[33201:1:0,1]

    Password must be provided via the AMX_TESTRUNNER_SSH_PASSWORD environment variable or will be prompted securely.

.PARAMETER HostName
    The hostname or IP address of the AMX device.

.PARAMETER UserName
    The username to authenticate with (default: testrunner).

.PARAMETER Port
    The SSH port (default: 22).

.EXAMPLE
    $env:AMX_SSH_PASSWORD = "mypassword"; .\ssh-runner.ps1 -HostName "192.168.1.100"

.EXAMPLE
    .\ssh-runner.ps1 -HostName "10.0.0.5" -UserName "admin"
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

# Define the commands to execute
$commands = @(
    "msg on all",
    "pulse[33201:1:0,1]"
)

try {
    # Load .env file if it exists
    $envFile = Join-Path $PSScriptRoot ".env"
    if (Test-Path $envFile) {
        Write-Log "Loading environment variables from .env file"
        Get-Content $envFile | ForEach-Object {
            $line = $_.Trim()
            # Skip empty lines and comments
            if ($line -and -not $line.StartsWith("#")) {
                # Parse KEY=VALUE format
                if ($line -match '^([^=]+)=(.*)$') {
                    $key = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    # Remove quotes if present
                    $value = $value -replace '^["'']|["'']$', ''
                    # Set environment variable for this session
                    [Environment]::SetEnvironmentVariable($key, $value, "Process")
                }
            }
        }

        Write-Log ".env file loaded successfully" "SUCCESS"
    }

    # Check if Posh-SSH module is available
    if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
        Write-Log "Posh-SSH module is not installed. Installing..." "WARNING"
        Install-Module -Name Posh-SSH -Force -Scope CurrentUser
        Write-Log "Posh-SSH module installed successfully" "SUCCESS"
    }

    Import-Module Posh-SSH -ErrorAction Stop

    # Resolve HostName: command line > env var > prompt
    if ([string]::IsNullOrEmpty($HostName)) {
        if (Test-Path env:AMX_TESTRUNNER_SSH_HOST) {
            $HostName = $env:AMX_TESTRUNNER_SSH_HOST
            Write-Log "Using hostname from environment variable: $HostName"
        }
        else {
            $HostName = Read-Host "Enter hostname or IP address"
            if ([string]::IsNullOrEmpty($HostName)) {
                Write-Log "Hostname cannot be empty" "ERROR"
                exit 1
            }
        }
    }

    # Resolve UserName: command line > env var > default
    # Check if UserName was explicitly provided via command line (not just the default)
    if ($PSBoundParameters.ContainsKey('UserName')) {
        Write-Log "Using username from command line: $UserName"
    }
    elseif (Test-Path env:AMX_TESTRUNNER_SSH_USER) {
        $UserName = $env:AMX_TESTRUNNER_SSH_USER
        Write-Log "Using username from environment variable: $UserName"
    }
    else {
        Write-Log "Using default username: $UserName"
    }

    Write-Log "Starting SSH connection to ${UserName}@${HostName}:${Port}"

    # Get password from environment variable or prompt
    $securePassword = $null
    if (Test-Path env:AMX_TESTRUNNER_SSH_PASSWORD) {
        $password = $env:AMX_TESTRUNNER_SSH_PASSWORD
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        Write-Log "Using password from environment variable: AMX_TESTRUNNER_SSH_PASSWORD"
    }
    else {
        Write-Log "Environment variable 'AMX_TESTRUNNER_SSH_PASSWORD' not found. Prompting for password..." "WARNING"
        $securePassword = Read-Host "Enter password for ${UserName}@${HostName}" -AsSecureString
    }

    if ($null -eq $securePassword) {
        Write-Log "Password cannot be empty" "ERROR"
        exit 1
    }

    # Create credential object
    $credential = New-Object System.Management.Automation.PSCredential($UserName, $securePassword)

    # Establish SSH session
    Write-Log "Establishing SSH session..."
    $session = New-SSHSession -ComputerName $HostName -Port $Port -Credential $credential -AcceptKey -ErrorAction Stop

    if ($null -eq $session) {
        Write-Log "Failed to establish SSH session" "ERROR"
        exit 1
    }

    Write-Log "SSH session established (Session ID: $($session.SessionId))" "SUCCESS"
    Write-Host ""

    # Create SSH shell stream for interactive commands
    Write-Log "Creating SSH shell stream..."
    $stream = New-SSHShellStream -SSHSession $session -ErrorAction Stop

    # Collect all output for analysis
    $allOutput = ""

    # Wait for initial prompt
    Start-Sleep -Milliseconds 500
    $initialOutput = $stream.Read()
    if ($initialOutput) {
        Write-Host $initialOutput
        $allOutput += $initialOutput
    }

    # Execute each command with streaming output
    $commandIndex = 1
    foreach ($command in $commands) {
        Write-Log "Executing command $commandIndex/$($commands.Count): $command"

        # Send command
        $stream.WriteLine($command)

        # Wait for command to process and read output
        Start-Sleep -Milliseconds 1000

        $output = $stream.Read()
        if ($output) {
            # Stream output directly to console
            Write-Host $output
            $allOutput += $output
        }

        Write-Log "Command sent successfully" "SUCCESS"
        Write-Host ""
        $commandIndex++
    }

    # Give final output time to arrive
    Start-Sleep -Milliseconds 500
    $finalOutput = $stream.Read()
    if ($finalOutput) {
        Write-Host $finalOutput
        $allOutput += $finalOutput
    }

    # Close stream and session
    Write-Log "Closing SSH connection..."
    $stream.Dispose()
    Remove-SSHSession -SSHSession $session | Out-Null
    Write-Log "SSH session closed successfully" "SUCCESS"

    # Analyze test results
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Test Results Analysis" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    # Parse test results
    $passedTests = [regex]::Matches($allOutput, "Test (\d+) passed")
    $failedTests = [regex]::Matches($allOutput, "Test (\d+) failed")

    $passedCount = $passedTests.Count
    $failedCount = $failedTests.Count
    $totalCount = $passedCount + $failedCount

    Write-Host ""
    Write-Host "Total Tests: $totalCount" -ForegroundColor White
    Write-Host "Passed: $passedCount" -ForegroundColor Green
    Write-Host "Failed: $failedCount" -ForegroundColor $(if ($failedCount -gt 0) { "Red" } else { "Green" })
    Write-Host ""

    if ($failedCount -gt 0) {
        Write-Host "Failed Tests:" -ForegroundColor Red
        foreach ($match in $failedTests) {
            $testNum = $match.Groups[1].Value
            Write-Host "  - Test $testNum" -ForegroundColor Red
        }
        Write-Host ""
        Write-Log "Test run completed with failures" "ERROR"
        exit 1
    }
    else {
        Write-Log "All tests passed successfully!" "SUCCESS"
        exit 0
    }

}
catch {
    Write-Log "An error occurred: $($_.Exception.Message)" "ERROR"

    # Clean up stream and session if they exist
    if ($null -ne $stream) {
        try {
            $stream.Dispose()
        }
        catch {
            # Ignore cleanup errors
        }
    }

    if ($null -ne $session) {
        try {
            Remove-SSHSession -SSHSession $session | Out-Null
        }
        catch {
            # Ignore cleanup errors
        }
    }

    exit 1
}
