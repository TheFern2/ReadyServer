Param(
    [Parameter(Mandatory=$true)]
    [String[]]
    $configPath
)

# Load modules here
Import-Module "$ScriptDirectory\Winster\Winster.psm1"
Write-Host "Json Configuration:", $configPath

$jsonRoot = Get-JsonData $configPath
$jsonData = $jsonRoot.cases

# Here we decide if the entire json file will be executed on the current machine or skipped entirely
if($jsonRoot.runOnMachines -match 'all' -or
   $jsonRoot.runOnMachines -match $currentHost){

    for($i=0; $i -lt $jsonData.Count; $i++)
    {
        
        # New functionality to skip a test case per vm
        # "testFunction": "Confirm-FileExistsLeaf",
        # "skipMachines": ["Pri-SP-Web", "Sec-SP-Web"],
        # "skipMachines": ["obsolete"] <- Obsolete will skip the test for all VMs
        if($jsonData[$i].skipMachines -match $currentHost){
            continue
        }

        if($jsonData[$i].skipMachines -match "obsolete"){
            continue
        }
        
        Describe $jsonData[$i].testName {
            It $jsonData[$i].testDescription {
               
                $command += $jsonData[$i] | ForEach-Object {
                    $_.testFunction + ' ' + ($_.args.ForEach({ 
                        $_.PSObject.Properties.Value.ForEach({
                            if ($_.contains(' ')) { # contains spaces -> double-quote
                                '"{0}"' -f $_
                            }
                            else {
                                $_
                            }
                        })
                    })) -join ' '
                }     
    
                Write-Host("Command: ", $command)
                Invoke-Expression $command | Should Be $jsonData[$i].expectedResult            
            }
        }
    }
}