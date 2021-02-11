
try{
    . ("$ScriptDirectory\Utils\Get-RecycleBinSize.ps1")
} catch{
    Write-Host "Error while loading supporting PowerShell Scripts"
}

Describe "Hostname" {
    It "Verifies hostname" {
        (Get-WmiObject Win32_ComputerSystem).Name | Should Be $expectedHostname
    }
}

Describe "ImageVersion" {
    It "Verifies Image Version" {
        $regKey = "Registry::HKEY_USERS\.Default"
        $keyPropertyName = "ImageVersion"
        Get-RegistryKey $regKey $keyPropertyName | Should Be $expectedImageVersion
    }
}

Describe "IPAddress" {
    It "Verifies IPAddress" {
        (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress | Should Be $expectedIPAddress
    }
}

Describe "TechSupport" {
    It "Verifies Tech Support Number" {
        $regKey = "Registry::HKEY_USERS\.Default"
        $keyPropertyName = "TechSupport"
        Get-RegistryKey $regKey $keyPropertyName | Should Be $expectedTechSupport
    }
}

Describe "Domain" {
    It "Verifies Domain" {
        (Get-WmiObject Win32_ComputerSystem).Domain | Should Be $expectedDomain
    }
}

$bins = (Get-RecycleBinSize -ComputerName $currentHost)

for($i=0; $i -lt $bins.Count; $i++)
{
    $describeMessage = "" + $bins[$i].User + " bin size"
    $shouldMessage = "Verifies " + $bins[$i].User + " bin is empty"
    
    Describe $describeMessage{
        It $shouldMessage {
            $bins[$i].Size | Should be 0
        }
    }
}

Describe "CPUs Specification" {
    It "Verifies number of CPUs allocated" {
        $numOfProcessors = Get-NumProcessors
        $numOfProcessors | Should Be $expectedLogicalProcessors
    }
}

Describe "RAM Specification" {
    It "Verifies RAM specs" {
        $ramBytes = Get-RamBytes
        $ramMB = Convert-Size -From Bytes -To MB -Value $ramBytes
        $ramMB | Should Be $expectedRam
    }
}

Describe "Disk Size Specification" {
    It "Verifies disk size specs" {
        $diskSizeBytes = Get-DiskSize $currentHost "C"
        $diskSizeGB = Convert-Size -From Bytes -To GB -Value $diskSizeBytes -Precision 2
        ([math]::Round($diskSizeGB)) | Should Be $expectedDiskSize
    }
}

## Example of running in most VMs except a few
## Logic needed to exclude certain VMs
$skipTest = $false
$skipMachines = @("Workstation-01", "Workstation-02")
if($skipMachines -match (Get-WmiObject Win32_ComputerSystem).Name){
        $skipTest = $true
}
######################################

if($skipTest -eq $false){
    Describe "Test" {
        It "Verifies certain logic" {
            # Test logic goes here

            # $someVar | Should be $expectedValue
        }
    }
}
$skipTest = $false
######################################

Describe "Remote Assistance is Disabled" {
    It "Verifies Remote Assistance is Disabled" {
        $regKey = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance"
        $keyPropertyName = "fAllowToGetHelp"

        # if the path exists make sure fAllowToGetHelp == 0
        if(Test-Path $regKey){
            $val = (Get-ItemProperty -Path $regKey -Name $keyPropertyName).$keyPropertyName
            $val | Should be 0
        } else {
            # else path never existed
            Test-Path $regKey | Should be $false
        }
    }
}

# this check is manual because it can be 2 if setting has never been changed. ie. default setting
# or if is changed manually == 24
# BUG this test case isn't giving proper results
Describe "Background Services Setting Enabled" {
    It "Background Services Setting Enabled" {
        $regKey = "Registry::HKEY_LOCAL_MACHINE\System\ControlSet001\Control\PriorityControl"
        $keyPropertyName = "Win32PrioritySeparation"
        $val = (Get-ItemProperty -Path $regKey -Name $keyPropertyName).$keyPropertyName

        if($val -eq 24 -or $val -eq 2){
            $true | Should be $true
        } else {
            $false | Should be $true
        }
    }
}

Describe "CPU Load Less than 60%" {
    It "CPU Load Less than 60%" {
        $currentLoadPercentage = (Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select Average).Average

        $currentLoadPercentage | Should -BeLessOrEqual 60.0
    }
}

# should be 40% or greater from total ram
Describe "Memory Usage Less than 60%" {
    It "Memory Usage Less than 60%" {
        $os = Get-Ciminstance Win32_OperatingSystem
        $pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)

        $pctFree | Should -BeGreaterOrEqual 40.0
    }
}

Describe "Free Disk Space Greater than 40%" {
    It "Free Disk Space Greater than 40%" {
        $freeSpaceDecimal = (Get-CimInstance -Class CIM_LogicalDisk | Select-Object @{Name="Free";Expression={"{0,6}" -f(($_.freespace/1gb) / ($_.size/1gb))}}).Free

        # some machines have more than 1 disk
        # need to account for that we only care about C drive

        if($freeSpaceDecimal.Count -eq 2){
             $freeSpacePercentage = [Decimal]([string]$freeSpaceDecimal[0]) * 100
        } else {
            $freeSpacePercentage = [Decimal]([string]$freeSpaceDecimal) * 100
        }       

        $freeSpacePercentage | Should -BeGreaterOrEqual 40
    }
}

Describe "Paging Size Automatically Managed" {
    It "Paging Size Automatically Managed" {

        (Get-WmiObject Win32_Pagefile) -eq $null | Should be $true
    }
}

Describe "Windows Network Discovery Enabled" {
    It "Windows Network Discovery Enabled" {
        $discoveryRules = Get-NetFirewallRule -DisplayGroup "Network Discovery"
        $networkDiscoveryIsEnabled = $true

        # check network discovery rules all should be true
        # will change to false if one rule is found to be false
        foreach($rule in $discoveryRules){
        
            if($rule.Profile -match "Domain"){
                if($rule.Enabled -eq "True"){
                    continue
                } else {
                    $networkDiscoveryIsEnabled = $false
                }   
                
            }
        }

        $networkDiscoveryIsEnabled | Should be $true
    }
}

Describe "Windows File and Printer Sharing" {
    It "Windows File and Printer Sharing" {
        $printerRules = Get-NetFirewallRule -DisplayGroup "File and Printer Sharing"
        $printerSharingIsEnabled = $true

        # check network discovery rules all should be true
        # will change to false if one rule is found to be false
        foreach($rule in $printerRules){
            
            # waiting on Juan for which profiles to check
            if($rule.Profile -match "Domain"){
                if($rule.Enabled -eq "True"){
                    continue
                } else {
                    $printerSharingIsEnabled = $false
                }   
                
            }
        }

        $printerSharingIsEnabled | Should be $true
    }
}