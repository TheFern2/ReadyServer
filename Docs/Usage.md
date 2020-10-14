## Framework Introduction

Framework was built to create test cases in an automated fashion. Test cases can be configured in two ways. `TS_AutomatedTest.ps1` gets a json configuration file, then `TS_Main.ps1` runs all those test cases. The second option is to create test cases with pure powershell scripts, and those can be seen in `Manual` directory. They are called manual in a sense that they have to be written manually, but once written, then they are pretty much automated tests as well. Examples of calling both are shown in `TS_Main.ps1`.

Configurations for `TS_AutomatedTest.ps1` go into `AutoConfigs` directory and follow naming convention:

- CASES_SOMEVM_Tests.json

For manual test cases the naming convention is:

- TS_COMPONENT_Tests.ps1 (TS = Test Script)

## Other Input files

- CFG_HOSTS.csv contains all the hosts to check on machines called by `TS_3000_Tests.ps1`
- CFG_MachinesList.csv contains vm settings to check (Might need revision as we go along)

## Running the framework

Launch Powershell ISE or Powershell.exe, and follow `TS_Main.ps1` header to set execution policy, if you're domain doesn't allow powershell execution.

To run the testing framework: 
- run `.\TS_Main.ps1`
- Enter VM IP (IP is entered manually in order to verify IP)

Script should be done in a matter of seconds.
All test cases passed should be green, and fail red through the console.

## Results

Results are saved to `Results` directory with the same name as the json file, and those xml files can also be viewed with the tool inside `ResultsViewer`. XML files need to saved in designated shared folder, and results transcribed to test plan.

## Adding functions to Winster module and historical information

If for whatever reason there is some functionality missing from `Winster.psm1` module the following steps need to be followed:

- Test that one function within powershell ISE, this will ensure it works before adding it to the framework
- Add new function to Winster repository https://github.com/kodaman2/Winster (I have no preference whether args are simple or complex, like `Test-RegistryValue`)
- Copy and paste the updated Winster.psm1 to Winster directory
- Add new test case in json configuration and test new function


Test Case Example:
```
{
        "testName": "Background Services Setting",
        "testDescription": "Verifies Background Services setting",
        "testFunction": "Get-RegistryKey",
        "args": [
          {
              "regKey" : "Registry::HKEY_LOCAL_MACHINE\\System\\ControlSet001\\Control\\PriorityControl",
              "keyPropertyName" : "Win32PrioritySeparation"
          }
        ],
        "expectedResult": "2"
      }
```

## Adding a New Json File

If there are VMs with unique cases is best to create a separate json file, and configure `runOnMachines` variable. See [Getting Started](./Json-Files.md) for more information.


## Finding Registry Paths

For finding registry paths and keys to verify with automated test cases. It is necessary to use `Tools\registrychangesview-x64` take snapshot before making a setting change, then make the change, and compare snapshot with current. Once you find the correct path, change it again to ensure the correct path has been found.

> NB: There are certain keys that change randomly, so be aware of that. Some of those need to be manual checks. Also some keys have one value if is on default value, and another if it was changed manually even if is the exact same setting. Most keys have constant values though.

## A word on GPO policies

Certain gpo policies are difficult to check, so be aware that some test will have to be checked visually sometimes.

## Test Configuration

Most `Winster.psm1` functions have a test case configured in a json file for reference.

## Troubleshooting

