## Getting Started

The setup to start working/viewing with this framework is minimal.

- [vscode](https://code.visualstudio.com/)
- [Git](https://git-scm.com/downloads)

### VSCode Plugins (Optional)

- Powershell
- GitLens
- Themes

## Git Directory

It is recommended to create a dedicated `git` directory to save git projects. It is also recommended to save in a place where you don't need Admin rights to save files, otherwise you will have issues saving if VSCode is not launched as admin. Best to avoid having to do anything as admin altogether. Quick way to know if a directory will always ask for admin rights, is to create a text file in it. If you get a popup asking for elevation, then this is not a desired spot.

Examples of git directories:

```
C:\git
D:\git
C:\Users\Username\Projects\git
```

## Repo test project

Open a browser and create a new repository on your github account, this will be used to test your local machine. Click the + sign, name the repo `test`, toggle private checkbox. Initialize README checkbox, click create repository.

On the repo click the code green button, make sure it says `Clone with HTTPS`, then copy the .git link.

Open a cmd prompt, powershell, or whatever shell you are using, and type the following:

```
cd Path/To/Git
git clone https://github.com/username/test.git
```

A Github popup should be visible, and allow you to enter your credentials. Then the repo will finish cloning.

```
cd test
code .
```

VSCode should now open with your test repo. Note at the bottom left, the branch that you are in. Make one change into the README.md, then save. You should see an M next to the file, and a 1 on the left menu. If you click on the icon showing 1, and click on the file you can see a text diff.

In VSCode go to Terminal menu at the top and open a new terminal within vscode.

Check the status:

```
git status
```

> Note modified is yellow

Add changed files to staging area:
```
git add README.md
# or multiple files
git add .
```

Check the status:

```
git status
```

> Note modified is green

Commit the changes:

```
git commit -m "first-commit"
```

Check the status:

```
git status
```

> Status now says local is ahead of remote by 1 commit

Push to remote:

```
git push
```

Check the status:

```
git status
```

> Up to date

If you've made it this far, your machine is now ready for some git action! Congratulations.

## Winster Submodule

Winster.psm1 should not be edited in this repo, as it is its own repo, its source code is in another repository. 

If you have any functionality that need to be added let me know, or pull a request in the below repository.
https://github.com/kodaman2/Winster