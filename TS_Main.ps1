##########################################################################################################
##
## Main v1.0.1
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

cls

# Ask user expected IP
$expectedIPAddress = Read-Host -Prompt "Enter expected machine IP"
# Below variables are input from CFG_MachinesList.csv
# If you need more add new columns to the csv and add variable below
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

$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$currentHost = (Get-WmiObject Win32_ComputerSystem).Name
$computers = Import-Csv "$ScriptDirectory\CFG_MachinesList.csv"

$expectedHosts = Import-Csv "$ScriptDirectory\CFG_Hosts.csv"

# Find expected variables for manual testing scripts
foreach($computer in $computers){

    if($computer.IPAddress -eq $expectedIPAddress){
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

if([string]::IsNullOrEmpty($expectedHostname)){
    "IP {0} not found in CSV list, check your list or IP" -f $expectedIPAddress
    Exit
}

if(!(Test-Path "$ScriptDirectory\Results\$currentHost")){
    New-Item -Path "$ScriptDirectory\Results\$currentHost" -ItemType directory
}
$datetime = Get-Date -Format "MMddyyyy_HH_mm"
$filePrefix = $datetime + "_"

$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Import-Module "$ScriptDirectory\Pester\Pester.psm1"

$resultsPath = "$ScriptDirectory\Results\$currentHost"

# Run all AutomatedTests in AutoConfigs
$autoConfigFiles = Get-ChildItem -Path "$ScriptDirectory\AutoConfigs"

foreach($autoConfigFile in $autoConfigFiles){
    $configFileAsString = [String]$autoConfigFile
    $configFileNoExtension = $configFileAsString.Split('.')[0]
    $resultFileName = $filePrefix + $configFileNoExtension + ".xml"
    $configPath = "$ScriptDirectory\AutoConfigs\$configFileAsString"

    # Only Invoke-Pester if runOnMachines is all or matches hostname
    $jsonRoot = Get-Content -Raw -Path $configPath | ConvertFrom-Json

    if($jsonRoot.runOnMachines -match 'all' -or
       $jsonRoot.runOnMachines -match (Get-WmiObject Win32_ComputerSystem).Name){

        Invoke-Pester -OutputFile "$resultsPath\$resultFileName" `
        -Script @{Path="$ScriptDirectory\TS_AutomatedTests.ps1";`
        Parameters=@{configPath=$configPath}}

    }
}

# Run all Manual Powershell test cases in Manual
$manualConfigFiles = Get-ChildItem -Path "$ScriptDirectory\Manual"

foreach($manualConfigFile in $manualConfigFiles){
    $configFileAsString = [String]$manualConfigFile
    $configFileNoExtension = $configFileAsString.Split('.')[0]
    $resultFileName = $filePrefix + $configFileNoExtension + ".xml"
    $configPath = "$ScriptDirectory\Manual\$configFileAsString"

    Invoke-Pester -OutputFile "$resultsPath\$resultFileName" $configPath
}
