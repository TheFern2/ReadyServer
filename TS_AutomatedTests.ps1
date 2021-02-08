Param(
    [Parameter(Mandatory = $true)]
    [String[]]
    $configPath
)

<#
 manualTestPrompt asks the user to pass a test manually, handy when the result is giving a failure
 and the result should be a pass. It checks if there is a data file, if not it creates one.
 If there is a data file, then it appends the test case guid.
#>
function manualTestPrompt() {
    $prompt = "Do you want to manually pass " + $jsonData[$i].testName + " (y/n)?"
    $yesOrNo = Read-Host -Prompt $prompt

    while ("y", "n" -notcontains $YesOrNo ) {
        $YesOrNo = Read-Host $prompt
    }

    if ($yesOrNo -eq "y") {
        $jsonData[$i].expectedResult | Should Be $jsonData[$i].expectedResult

        if ($OSPlatform -eq "Win32NT" -and !(Test-Path -Path "C:\Windows\Temp\$dataFileName") ) {                            
            New-Item -Path "C:\Windows\Temp\$dataFileName" -ItemType file
        }
        
        if ($OSPlatform -eq "Unix" -and !(Test-Path -Path "/tmp/$dataFileName")) {
            New-Item -Path "/tmp/$dataFileName" -ItemType file
        }
                        
        if ($OSPlatform -eq "Win32NT") {                            
            Add-Content -Path "C:\Windows\Temp\$dataFileName" -Value $jsonData[$i].guid
        }
        
        if ($OSPlatform -eq "Unix") {
            Add-Content -Path "/tmp/$dataFileName" -Value $jsonData[$i].guid
        }
                        
    } 

    if ($yesOrNo -eq "n") {
        Invoke-Expression $command | Should Be $jsonData[$i].expectedResult  
    }
}

# Load modules here
Import-Module "$ScriptDirectory\Winster\Winster.psm1"
Write-Host "Json Configuration:", $configPath

$jsonRoot = Get-JsonData $configPath
$jsonData = $jsonRoot.cases

# Here we decide if the entire json file will be executed on the current machine or skipped entirely
if ($jsonRoot.runOnMachines -match 'all' -or
    $jsonRoot.runOnMachines -match $currentHost) {

    for ($i = 0; $i -lt $jsonData.Count; $i++) {
        
        # New functionality to skip a test case per vm
        # "testFunction": "Confirm-FileExistsLeaf",
        # "skipMachines": ["Pri-SP-Web", "Sec-SP-Web"],
        # "skipMachines": ["obsolete"] <- Obsolete will skip the test for all VMs
        if ($jsonData[$i].skipMachines -match $currentHost) {
            continue
        }

        if ($jsonData[$i].skipMachines -match "obsolete") {
            continue
        }
        
        Describe $jsonData[$i].testName {
            It $jsonData[$i].testDescription {
               
                $command += $jsonData[$i] | ForEach-Object {
                    $_.testFunction + ' ' + ($_.args.ForEach( { 
                                $_.PSObject.Properties.Value.ForEach( {
                                        if ($_.contains(' ')) {
                                            # contains spaces -> double-quote
                                            '"{0}"' -f $_
                                        }
                                        else {
                                            $_
                                        }
                                    })
                            })) -join ' '
                }

                Write-Host("Command: ", $command)

                # If test case has guid
                if ($jsonData[$i].guid) {
                    # Need to check if there is a file on
                    # C:\Windows\Temp for Windows
                    # /tmp for Linux
                    $hasTempData = $false
                    #$dataFileName = "TS_Data.txt"
                    $manualPassedCases = @()
                    if ($OSPlatform -eq "Win32NT" -and (Test-Path -Path "C:\Windows\Temp\$dataFileName") ) {
                        $manualPassedCases = Get-Content -Path "C:\Windows\Temp\$dataFileName"
                    }

                    if ($OSPlatform -eq "Unix" -and (Test-Path -Path "/tmp/$dataFileName")) {
                        $manualPassedCases = Get-Content -Path "/tmp/$dataFileName"
                    }

                    # Write-Host $manualPassedCases
                    if ($manualPassedCases.Length -gt 0) {
                        $hasTempData = $true
                    }
                
                    # file has data, and no prompt flag
                    if ($hasTempData -and $promptManual -eq $false) {
                        # guid is found in data file
                        if ($manualPassedCases -match $jsonData[$i].guid) {
                            $jsonData[$i].expectedResult | Should Be $jsonData[$i].expectedResult
                        }
                        else {
                            # Execute test as normal
                            Invoke-Expression $command | Should Be $jsonData[$i].expectedResult
                        }
                    }

                    # no data, and no prompt flag, execute test as normal
                    if ($hasTempData -eq $false -and $promptManual -eq $false) {
                        Invoke-Expression $command | Should Be $jsonData[$i].expectedResult
                    }

                    # prompt flag
                    if ($promptManual) {
                        if ($hasTempData) {
                            if ($manualPassedCases -match $jsonData[$i].guid) {
                                $jsonData[$i].expectedResult | Should Be $jsonData[$i].expectedResult
                            }
                            else {
                                manualTestPrompt                             
                            }
                        }                        
                        else {
                            manualTestPrompt                           
                        }
                    }                
                } 
                else {
                    Invoke-Expression $command | Should Be $jsonData[$i].expectedResult  
                }            
            }
        }
    }
}