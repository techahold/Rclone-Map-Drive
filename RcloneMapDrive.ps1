$ErrorActionPreference= 'silentlycontinue'
#Run as administrator and stays in the current directory
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
        Exit;
    }
}

# Get username for logged in user
$username = ((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]

$rclonedir="C:\Program Files\Rclone"
$RemoteName="Techahold Map Drive"
$MapDriveName="\\server\shared"
$tag = (Invoke-WebRequest "https://api.github.com/repos/rclone/rclone/releases/latest" | ConvertFrom-Json)[0].tag_name

#Get and expand programs
new-item $rclonedir -itemtype directory
Invoke-WebRequest -Uri "https://github.com/rclone/rclone/releases/download/$tag/rclone-$tag-windows-amd64.zip" -outfile "$rclonedir\rclone.zip"
Invoke-WebRequest -Uri "https://github.com/winfsp/winfsp/releases/download/v1.11/winfsp-1.11.22176.msi" -outfile "$rclonedir\winfsp.msi"
Expand-Archive -LiteralPath $rclonedir\rclone.zip -DestinationPath $rclonedir -Force
Copy-Item $rclonedir\rclone-$tag-windows-amd64\* -Destination $rclonedir\
Remove-Item "$rclonedir\rclone.zip" -Force
Remove-Item "$rclonedir\rclone-$tag-windows-amd64\" -Force -Recurse

#install winfsp
Start-Process $rclonedir\winfsp.msi -ArgumentList /passive

# Create Start Program Entries 
new-item "C:\Users\$username\AppData\Local\rclone\logs" -itemtype directory
new-item "C:\Users\$username\AppData\Roaming\techahold\" -itemtype directory
new-item "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$RemoteName" -itemtype directory

New-Item "C:\Users\$username\AppData\Roaming\techahold\Setup $RemoteName.bat"
New-Item "C:\Users\$username\AppData\Roaming\techahold\$RemoteName $username.bat"

Set-Content "C:\Users\$username\AppData\Roaming\techahold\Setup $RemoteName.bat" "@echo off `necho Setup your cloud connection now `ncd $rclonedir`nrclone config`npowershell.exe"


Set-Content "C:\Users\$username\AppData\Roaming\techahold\$RemoteName $username.bat" "$rclonedir\rclone mount ${sharepoint}:/ P: --volname $MapDriveName --vfs-cache-mode off --no-console --log-file %LOCALAPPDATA%\rclone\logs\driveP.txt"

$ShortcutPath = "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$RemoteName\Setup $RemoteName.lnk"
$IconLocation = "$rclonedir\rclone.exe"
$Shell = New-Object -ComObject ("WScript.Shell")
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "C:\Users\$username\AppData\Roaming\techahold\Setup $RemoteName.bat"
$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
$Shortcut.Save()

$ShortcutPath = "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$RemoteName\$RemoteName for $username.lnk"
$IconLocation = "$rclonedir\rclone.exe"
$Shell = New-Object -ComObject ("WScript.Shell")
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "C:\Users\$username\AppData\Roaming\techahold\$RemoteName $username.bat"
$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
$Shortcut.Save()

#New-Item "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\rclone - $RemoteName\Setup $RemoteName.bat"

# We probably want this written out after the script above is finished, 



Copy-Item "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\rclone - $RemoteName\$RemoteName $username.bat" -Destination "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\$RemoteName $username.bat" #user startup 

# Open Config Folder
explorer.exe /e,"C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$RemoteName"
