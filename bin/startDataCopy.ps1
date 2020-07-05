function Show-Welcome {

    # messages
    Write-Output "`n"
    Write-Output "==============================================="
    Write-Output "=            Create your data-copy            ="
    Write-Output "=    -> Created by         Adrian Weiss       ="
    Write-Output "=    -> Created on         2020-07-05         ="
    Write-Output "==============================================="

}

function Show-Exit {

    # get date
    $date = ( Get-Date -Format "yyyy-mm-dd HH-mm-ss" )

    # messages
    Write-Output "`n"
    Write-Output "==============================================="
    Write-Output "=       All necesary data were copied!        ="
    Write-Output "=    -> Executed on  $date ="
    Write-Output "=                                             ="
    Write-Output "=  --> Press ENTER-Key to leave the      <--  ="
    Write-Output "=  --> program.                          <--  ="
    Write-Output "===============================================" 

    # Read Host
    Read-Host

    # Exit
    stop-process -Id $PID

}

function Get-InstalledSoftware {

    Param(
        [Parameter(Mandatory)][string]$Folder
    )

    # message
    Write-Output "`nGet installes software"
    Write-Output "    -> Find installed software"

    # relevant paths
    $paths = @(
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
    )

    # create array
    $installedSoftware = @()

    foreach ($path in $paths) {

        # get installes software
        $installedSoftware += Get-ChildItem -Path $path | 
        Get-ItemProperty | 
        Select-Object DisplayName, DisplayVersion, Publisher 

    }

    # message
    Write-Output "    -> Found installed software: $($installedSoftware.Length)"

    # save installed software in file
    $installedSoftware | ForEach-Object { [PSCustomObject]$_ } | Format-Table -AutoSize | Out-File -FilePath "..\programs\$foldername\InstalledSoftware.txt"

    # message
    Write-Output "    -> Saved installed software in 'InstalledSoftware.txt"

}

function Set-Folder {

    Param(
        [Parameter(Mandatory)][string]$Foldername
    )

    # message
    Write-Output "`nInitialize structure"

    # create folder
    New-Item -Path "..\\data-copy" -Name $Foldername -ItemType Directory | Out-Null
    New-Item -Path "..\\programs" -Name $Foldername -ItemType Directory | Out-Null
    New-Item -Path "..\\log-files" -Name $Foldername -ItemType Directory | Out-Null

    # create logfile
    New-Item -Path "..\\log-files\$Foldername" -Name "robocopyLog.log" -ItemType File | Out-Null

    # message
    Write-Output "   -> created folder \\datacopy\$Foldername\"
    Write-Output "   -> created folder \\programs\$Foldername\"
    Write-Output "   -> created folder \\log-files\$Foldername\"
    Write-Output "   -> created file 'robocopyLog.log'"

    # return folder name
    return $Foldername.FullName
}

function Get-Folders {
    
    # get current user
    $currentUser = $env:UserName

    # set foldername
    $folderName = (( Get-Date -Format "yyyyMMdd_HHmmss") + "_user__" + $currentUser )
    
    # message
    Write-Output "`nThe files are copied for this following user -> $currentUser"

    # get folder items
    $folders = Get-ChildItem C:\Users\$currentUser -dir
    $files = Get-ChildItem C:\Users\$currentUser -file

    # create folder in data-copy
    Set-Folder -Foldername $folderName

    # message
    Write-Output "`nCopy folders of user directory"
    Write-Output "    -> Start copying $($folders.Length) folders"

    # process folders
    foreach ($folder in $folders) {

        # calculate percentage
        $percentage = $folder.index / $folders.length

        # write progress
        Write-Progress -Activity "Copying files" -PercentComplete $percentage -CurrentOperation "Copy file $($folder.FullName)"

        # copy folder to target folder
        robocopy $folder.Fullname "..\data-copy\$folderName\$folder" /MIR /R:0 /W:0 /NFL /LOG:"..\log-files\$folderName\robocopyLog.log"

    }

    # message
    Write-Output "    -> Finished copying folders"

    # message
    Write-Output "`nCopy files of user directory"
    Write-Output "    -> Start copying $($files.Length) files"

    # process files
    foreach ($file in $files) {

        # calculate percentage
        $percentage = $file.index / $files.length

        # write progress
        Write-Progress -Activity "Copying files" -PercentComplete $percentage -CurrentOperation "Copy file $($file.FullName)"

        # copy file to target folder
        Copy-Item -Path $file.FullName -Destination "..\data-copy\$folderName\"
    }
    
    # message
    Write-Output "    -> Finished copying files"

    # get installes software
    Get-InstalledSoftware -Folder $folderName
}

# start functions
Show-Welcome
Get-Folders  
Show-Exit