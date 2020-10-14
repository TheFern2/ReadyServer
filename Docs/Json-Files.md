## Json Files

Json files have a new parameter `runOnMachines` which allows it to run on all machines or just certain ones. There is no more need to call each json file manually on `TS_Main.ps1`

Examples:

```
{
    "runOnMachines": ["all"],
    "cases":
    [
        ...
    ]
}
```

```
{
    "runOnMachines": ["Workstation-01", "Workstation-02],
    "cases":
    [
        ...
    ]
}
```