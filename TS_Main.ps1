##########################################################################################################
##
## TS_Main v1.0.1
##
## by Fernando ***REMOVED*** (fernandobe+git@protonmail.com)
## 6/19/2020
##
## Need the following cmd ran first on powershell to be able to run scripts.
## Set-ExecutionPolicy Unrestricted
##
## To revert policy to original:
## Set-ExecutionPolicy -ExecutionPolicy Restricted
##
##########################################################################################################

[CmdletBinding()]
param (
    [Parameter()]
    [switch]$promptManual = $false,
    [Parameter()]
    [switch]$removeData = $false
)

cls

# Check platform
$OSPlatform = [Environment]::OSVersion.Platform

$dataFileName = "TS_Data.txt"
if ($OSPlatform -eq "Win32NT" -and $removeData ) {
    Remove-Item "C:\Windows\Temp\$dataFileName"
}

if ($OSPlatform -eq "Unix" -and $removeData) {
    Remove-Item "/tmp/$dataFileName"
}

# Ask user expected IP
$expectedIPAddress = Read-Host -Prompt "Enter expected machine IP"
$expectedHostname = ""
$expectedImageVersion = ""
$expectedTechSupport = ""
$expectedDomain = ""
$expectedRam = ""
$expectedLogicalProcessors = ""
$expectedDiskSize = ""
$expectedResolutionWidth = ""
$expectedResolutionHeight = ""
$expectedPsVersion = ""

$ScriptDirectory = pwd
$currentHost = hostname

$computers = Import-Csv "$ScriptDirectory\CFG_MachinesList.csv"
$expectedHosts = Import-Csv "$ScriptDirectory\CFG_Hosts.csv"

# Find expected variables for manual testing scripts
foreach ($computer in $computers) {

    if ($computer.IPAddress -eq $expectedIPAddress) {
        $expectedHostname = $computer.Hostname
        $expectedImageVersion = $computer.ImageVersion
        $expectedTechSupport = $computer.TechSupport
        $expectedDomain = $computer.Domain
        $expectedRam = $computer.Ram
        $expectedLogicalProcessors = $computer.LogicalProcessors
        $expectedDiskSize = $computer.DiskSize
        $expectedResolutionWidth = $computer.ResolutionWidth
        $expectedResolutionHeight = $computer.ResolutionHeight
        $expectedPsVersion = $computer.PowershellVersion
    }
}

if ([string]::IsNullOrEmpty($expectedHostname)) {
    "IP {0} not found in CSV list, check your list or IP" -f $expectedIPAddress
    Exit
}

if (!(Test-Path "$ScriptDirectory\Results\$currentHost")) {
    New-Item -Path "$ScriptDirectory\Results\$currentHost" -ItemType directory
}
$datetime = Get-Date -Format "MMddyyyy_HH_mm"
$filePrefix = $datetime + "_"

Import-Module "$ScriptDirectory\Pester\Pester.psm1"

$resultsPath = "$ScriptDirectory\Results\$currentHost"

$totalCount = 0
$totalCountPassed = 0
$totalCountFailed = 0

# Run all AutomatedTests in AutoConfigs
$autoConfigFiles = Get-ChildItem -Path "$ScriptDirectory\AutoConfigs"

foreach ($autoConfigFile in $autoConfigFiles) {
    $configFileAsString = [String]$autoConfigFile
    $configFileNoExtension = $configFileAsString.Substring(0, $configFileAsString.Length - 5)
    $onlyFileNameNoPath = $configFileNoExtension.Split("/")[-1]
    $resultFileName = $filePrefix + $onlyFileNameNoPath + ".xml"

    if ($OSPlatform -eq "Win32NT") {
        $configPath = "$ScriptDirectory\AutoConfigs\$configFileAsString"
    }

    if ($OSPlatform -eq "Unix") {
        $configPath = $configFileAsString
    }

    # Only Invoke-Pester if runOnMachines is all or matches hostname
    $jsonRoot = Get-Content -Raw -Path $configPath | ConvertFrom-Json

    if ($jsonRoot.runOnMachines -match 'all' -or
        $jsonRoot.runOnMachines -match $currentHost -and
        $jsonRoot.runOnOS -match $OSPlatform) {

        $pesterResults = Invoke-Pester -PassThru -OutputFile "$resultsPath\$resultFileName" `
            -Script @{Path = "$ScriptDirectory\TS_AutomatedTests.ps1"; `
                Parameters = @{configPath = $configPath }
        }

        $totalCount = $totalCount + $pesterResults.TotalCount
        $totalCountPassed = $totalCountPassed + $pesterResults.PassedCount
        $totalCountFailed = $totalCountFailed + $pesterResults.FailedCount
    }
}

# Run all Manual Powershell test cases in Manual
if ($OSPlatform -eq "Win32NT") {
    $manualConfigFiles = Get-ChildItem -Path "$ScriptDirectory\Manual\Windows"
}

if ($OSPlatform -eq "Unix") {
    $manualConfigFiles = Get-ChildItem -Path "$ScriptDirectory\Manual\Linux"
}

foreach ($manualConfigFile in $manualConfigFiles) {
    $configFileAsString = [String]$manualConfigFile
    $configFileNoExtension = $configFileAsString.Substring(0, $configFileAsString.Length - 5)
    $onlyFileNameNoPath = $configFileNoExtension.Split("/")[-1]
    $resultFileName = $filePrefix + $onlyFileNameNoPath + ".xml"

    if ($OSPlatform -eq "Win32NT") {
        $configPath = "$ScriptDirectory\Manual\Windows\$configFileAsString"
    }

    if ($OSPlatform -eq "Unix") {
        $configPath = $configFileAsString
    }

    $pesterResults = Invoke-Pester -PassThru -OutputFile "$resultsPath\$resultFileName" $configPath

    $totalCount = $totalCount + $pesterResults.TotalCount
    $totalCountPassed = $totalCountPassed + $pesterResults.PassedCount
    $totalCountFailed = $totalCountFailed + $pesterResults.FailedCount
}

# Print information about all the results
Write-Output "Total of tests executed: $totalCount"
Write-Output "Total of tests passed: $totalCountPassed"
Write-Host  "Total of tests failed: $totalCountFailed" -ForegroundColor red
