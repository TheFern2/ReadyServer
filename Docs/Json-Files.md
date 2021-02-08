## Json Files

Json files have a new parameter `runOnMachines` which allows it to run on all machines or just certain ones. There is no more need to call each json file manually on `TS_Main.ps1`

Examples:

```
{
    "runOnMachines": ["all"],
    "runOnOS": "Win32NT",
    "cases":
    [
        ...
    ]
}
```

```
{
    "runOnMachines": ["Workstation-01", "Workstation-02],
    "runOnOS": "Win32NT",
    "cases":
    [
        ...
    ]
}
```

# runOnOS

In order to have grained control over where is the json file ran when running in multiple OSes, a new variable was added.

Allowed values: Win32NT, Unix

```
{
    "runOnMachines": ["MAINTWKST"],
     "runOnOS": "Win32NT",
    "cases":
    [
        ...
    ]
}
```
