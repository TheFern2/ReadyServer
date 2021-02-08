## Test Cases

There are two types of test cases within this framework automated, and manual.

- Automated = configured through json files. using functions from modules already built
- Manual = powershell function built manually, but runs just like automated test cases

## Test Case Execution

Once TS_Main.ps1 is executed, all automated test cases will be ran in the machine, if the current machine hostname is in the runOnMachines, or if runOnMachines is `all`. Manual cases will be ran on all machines as there is no json filtering parameters, if you need to skip or run on certain VMs, see below.

## Skipping Test Cases

If there is a need to skip a test in a json file, add `skipMachines` parameter which takes in an array of strings. See below example, where four hostnames skip that particular test case. `skipMachines` is an optional parameter.

```json
"testFunction": "Find-ProgramVersion",
"skipMachines": ["Workstation-03", "Workstation-04"],
"args": [
```

Skip all machines:

```json
"testFunction": "Find-ProgramVersion",
"skipMachines": ["obsolete"],
"args": [
```

## Manual Cases

Manual cases are designed to run on all VMs, follow below guidelines to skip or run on certain VMs.
For manual test cases, note the # lines to make clear we're skipping a test case:

```powershell
## Logic needed to exclude certain VMs
$skipTest = $false
$skipMachines = @("Workstation-03", "Workstation-04")
if($skipMachines -match (Get-WmiObject Win32_ComputerSystem).Name){
        $skipTest = $true
}
######################################

if($skipTest -eq $false){
    Describe "Test Case Name" {
        It "Test Case Description" {
            # Logic for the test case
            $someVar | Should be $expectedVar
        }
    }
}
$skipTest = $false
######################################
```

## RunOnMachines

This parameter is similar to skipMachines, but it is for the whole json file as explained in [Json Files](./Json-Files.md). The same concept can be done for manual testing. If skipMachines is a large array, then it might be easier to say which machines to run on, rather than to skip.

```powershell
## Example of a manual built test that runs only on some VMs
## Logic needed to execute on certain VMs
$runOnMachines = @("Workstation-03", "Workstation-04")
if($runOnMachines -match (Get-WmiObject Win32_ComputerSystem).Name){
    Describe "Windows Features Installed" {
        It "Verifies Windows Features Installed" {
            # Test logic goes in  here
            $allFeaturesInstalled | Should be $true
        }
    }
}
```

## Test Case Json Parameters

Other than `skipMachines`, the rest of parameters are required for each `Winster` function to work properly. You can see in the json files a test case example for most Winster functions. In `TS_AutomatedTests.ps1`, you can also see in the IF statements all the functions available and the parameters the function is expecting.

## Mark test case results as pass when is failing

If for whatever reason a test case is failing, but it is actually a pass. There is a built-in mechanism for marking a test case as a pass in order to avoid seeing those failures.

In Powershell, run the following command:

```
New-Guid
```

Then place that in the test case you want to mark as pass:

```
{
      "testName": "C:\\Rockwell\\System_Integrator SomeUser Access",
      "testDescription": "Verifies SomeUser access on folder",
      "testFunction": "Confirm-FolderAccess2",
      "guid": "69e3b934-7cd0-466a-97c9-f04820e09784",
      "args": [
        {
          "folderPath": "C:\\Rockwell\\System_Integrator",
          "checkUser": "SomeUSer",
          "accesschkToolPath": "C:\\_QC\\TS_Images\\Tools\\accesschk64.exe"
        }
      ],
      "expectedResult": "No Access"
    },
```

Everything will work same as before if you run `TS_Main.ps1`. If you want to mark those cases with guid as pass, run `TS_Main.ps1 -promptManual`, that will give you the option to say (y/n) for that test case in the VM you are running it. The results will be saved on a temp file within `C:\Windows\Temp\TS_Data.txt` or `/tmp/TS_Data.txt`. In addition you can delete that file with `TS_Main.ps1 -removeData`.
