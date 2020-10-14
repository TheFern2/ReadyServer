Import-Module "$ScriptDirectory\Winster\Winster.psm1"

Describe "Screen Resolution" {
    It "Verifies screen resolution setting" {

        # check if Get-displayResolution exists
        if (Get-Command Get-displayResolution -errorAction SilentlyContinue){
            $displayResolution = Get-displayResolution
            $nospaceResolution = [string]$displayResolution -replace '\s',''
            $nospaceResolution | Should Be ($expectedResolutionWidth + "x" + $expectedResolutionHeight)
        } else {
            $displayResolution = Get-WmiObject -Class Win32_DesktopMonitor | Select-Object ScreenWidth,ScreenHeight

            # turn array object to string, and remove spaces
            $screenWidth = [string]$displayResolution.ScreenWidth -replace '\s',''
            $screenHeight = [string]$displayResolution.ScreenHeight -replace '\s',''

            $screenWidth | Should Be $expectedResolutionWidth
            $screenHeight | Should Be $expectedResolutionHeight
        } 
    }
}

Describe "Poweshell upgrade" {
    It "Verifies powershell upgrade version" {
        $psVersion = $PSVersionTable.PSVersion.Major
        $psVersion | Should Be $expectedPsVersion
    }
}

$hostsArr = Get-Hosts

for($i=0; $i -lt $expectedHosts.Count; $i++)
{
    $describeMessage = "host " + $expectedHosts[$i].HostIP
    $shouldMessage = "Verifies " + $expectedHosts[$i].HostIP + " is in host file"
    
    Describe $describeMessage{
        It $shouldMessage {
           $hostsArr.Contains( $expectedHosts[$i].HostIP) | Should be $true
        }
    }
}

## Example of a manual built test that runs only on some VMs
## Logic needed to execute on certain VMs
$runOnMachines = @("Workstation-03", "Workstation-04")
if($runOnMachines -match (Get-WmiObject Win32_ComputerSystem).Name){
    Describe "Windows Features Installed" {
        It "Verifies Windows Features Installed" {
            # Test logic goes in  here

            # $allFeaturesInstalled | Should be $true
        }
    }
}