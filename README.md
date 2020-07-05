# Data-Copy #
This program was created to create slim data-copies just by executing the Start-File in the root-folder.

## How to install it ##
Download or clone the repository.

It is recommended to store it on an empty (formatted) external drive (like a USB).

Copy all data into (including the structure) to the target drive/folder.
Do not store and execute this programm in any user-folder. It will create a recursive copying causing a big mess.

**Following structure is needed** <br />
```
root   
+-- /bin   
+---- code.ico   
+---- startDataCopy.bat   
+---- startDataCopy.ps1   
+-- Start.lnk   
```

## How to use it ##

Just execute `Start.lnk / Start` and everything else is done by the program.
When the program is finished you just need to press enter to leave the program.

**The data will be stored in following stucture** <br />
```
root  
+-- /bin  
+---- code.ico  
+---- startDataCopy.bat  
+---- startDataCopy.ps1  
+-- /datacopy  
+---- /[unique key]  
+------- [...] &larr;  
+-- /programs   
+---- /[unique key]  
+------- InstalledPrograms.txt &larr;   
+-- /log-files   
+---- /[unique key]  
+------- robocopyLog.log &larr;  
+-- Start.lnk  
 ```

`root` will be your designated folder (where you 'installed' this program).

After executing the program, you can store the data on another system or drive or just store the drive in a shelf...

## Working platforms ##

Below you will find the verified OS, where the program is working

| OS         | Version | Tested | Result  |
|------------|---------|--------|---------|
| Windows 10 | v1903   | Yes    | Working |

## How does the program work ##

The program is started by 'Start'-File (Start.lnk) in the root-folder. 
This file is linked to 'bin/startDataCopy.bat'.

### start.lnk ###

A link-file was created to enable the function of "run as admin" and set a nice icon : D

### bin/startDataCopy.bat ###

The single purpose of this file is to initiate a powershell-session and load the powershell script.
It will bypass the execution-policy and prevent the powershell-session from closing itself.

### bin/startDataCopy.ps1 ##

Within this file, the complete logic will be handled.

There are several functions to provide these functions, which are described below.

They are triggered by following commands

* Show-Welcome
* Get-Folders  
* Show-Exit

#### function: Show-Welcome ####

This function just displayes a welcome-message. It's pretty (useless) - we need to welcome the customers...

#### function: Show-Exit ####

This function displayes a 'finish'-message and how to terminate the report.

To terminate the report, it's necessary to press `ENTER` . It will terminate the process by `stop-process -Id $PID` .

#### function: Gert-InstalledSoftware ####

**Input-Parameter**
| Paremeter | Import/Export | Required | Type   |
|-----------|---------------|----------|--------|
| Folder    | Import        | X        | String |

**Relevant paths (registry)**

* HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
* HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\

This function extract the installed software from registry based on 'relevant paths'.
After all, this list will be formatted and saved as `\programs\[unique key]\InstalledSoftware.txt`

#### Set-Folder ####

**Input-Parameter**
| Paremeter              | Import/Export | Required | Type   |
|------------------------|---------------|----------|--------|
| Foldername             | Import        | X        | String |
| Foldername. Fullname   | Export        | O        | Object |

This function initializes the complete structure

There are several folders, which are relevant to save the data

* data-copy (stores files)
* programs (stores InstalledSoftware.txt)
* log-files (stores lof-files)

We also need to create some files before we start to execute this program

* robocopy.log (stores all log-data from robocopy-command)

#### Get-Folders ####

This function workes as described below

1. get current user from `$env:UserName` into `$currentUser`
1. create [unique key] by format `yyyyMMdd_HHmmss_user__username`
    2. yyyyMMdd_HHmmss &rarr; `Get-Date` with format
    2. username &rarr; from current user
1. get folders from user-directory `C:\Users\$currentUser`
1. get files from  user-directory `C:\Users\$currentUser`
1. copy folders
    2. calculate progress (percentage)
    2. display `Write-Progress`
    2. copying folder by `robocopy` into `..\\data-copy\[unique key]`
1. copy files
    2. calculate progress (percentage)
    2. display `Write-Progress`
    2. copying folder by `Copy-Item` into `..\\data-copy\[unique key]`
1. get installed software by function `Get-InstalledSoftware`

## Which data are copied ##

All data, which can be found in `C:\Users\$currentUser` will be copied

## Where will it be copied ##

The data will all be saved in the same directory as Start.lnk (root-directory). 
For more information have a look at `How to use it`
