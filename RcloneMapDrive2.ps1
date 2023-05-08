# Get username for logged in user
$username = ((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]

$rclonedir="C:\Program Files\Rclone"
$RemoteName="Techahold"
$MapDriveName="\\server\shared"
#$tag = (Invoke-WebRequest "https://api.github.com/repos/rclone/rclone/releases/latest" | ConvertFrom-Json)[0].tag_name

#Get and expand programs
new-item $rclonedir -itemtype directory
Invoke-WebRequest -Uri "https://downloads.rclone.org/v1.61.1/rclone-v1.61.1-windows-amd64.zip" -outfile "$rclonedir\rclone.zip"
Invoke-WebRequest -Uri "https://github.com/winfsp/winfsp/releases/download/v1.11/winfsp-1.11.22176.msi" -outfile "$rclonedir\winfsp.msi"
Expand-Archive -LiteralPath $rclonedir\rclone.zip -DestinationPath $rclonedir -Force
Copy-Item $rclonedir\rclone-v1.61.1-windows-amd64\* -Destination $rclonedir\
Remove-Item "$rclonedir\rclone.zip" -Force
Remove-Item "$rclonedir\rclone-v1.61.1-windows-amd64\" -Force -Recurse
Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/nircmd-x64.zip" -outfile "$rclonedir\nircmd.zip"
Expand-Archive -LiteralPath $rclonedir\nircmd.zip -DestinationPath $rclonedir -Force
Remove-Item "$rclonedir\nircmd.zip" -Force
Remove-Item "$rclonedir\nircmd\" -Force -Recurse

#install winfsp
Start-Process $rclonedir\winfsp.msi -ArgumentList /passive

# Create Start Program Entries 
new-item "C:\Users\$username\AppData\Local\rclone\logs" -itemtype directory
new-item "C:\Users\$username\AppData\Roaming\techahold\" -itemtype directory
new-item "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$RemoteName" -itemtype directory

New-Item "C:\Users\$username\AppData\Roaming\techahold\Setup $RemoteName Mapped Drive.bat"
New-Item "C:\Users\$username\AppData\Roaming\techahold\$RemoteName Mapped Drive for $username.bat"

Set-Content "C:\Users\$username\AppData\Roaming\techahold\Setup $RemoteName Mapped Drive.bat" "@echo off `necho Setup your cloud connection now use $RemoteName when asked `ncd ""$rclonedir""`nrclone.exe config`nnircmd exec hide rclone.exe mount ${RemoteName}:/ S: --volname $MapDriveName --vfs-cache-mode full --ignore-checksum --ignore-size --no-console --log-file %LOCALAPPDATA%\rclone\logs\driveS.txt"
Set-Content "C:\Users\$username\AppData\Roaming\techahold\$RemoteName Mapped Drive for $username.bat" "@echo off `ncd ""$rclonedir""`nnircmd exec hide rclone.exe mount ${RemoteName}:/ S: --volname $MapDriveName --vfs-cache-mode full --ignore-checksum --ignore-size --no-console --log-file %LOCALAPPDATA%\rclone\logs\driveS.txt"

$ShortcutPath = "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$RemoteName\Setup $RemoteName.lnk"
$IconLocation = "$rclonedir\rclone.exe"
$Shell = New-Object -ComObject ("WScript.Shell")
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "C:\Users\$username\AppData\Roaming\techahold\Setup $RemoteName Mapped Drive.bat"
$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
$Shortcut.Save()

$ShortcutPath = "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$RemoteName\$RemoteName for $username.lnk"
$IconLocation = "$rclonedir\rclone.exe"
$Shell = New-Object -ComObject ("WScript.Shell")
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "C:\Users\$username\AppData\Roaming\techahold\$RemoteName Mapped Drive for $username.bat"
$Shortcut.IconLocation = "$IconLocation, $IconArrayIndex"
$Shortcut.Save()

Copy-Item "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$RemoteName\$RemoteName for $username.lnk" -Destination "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\"

# Open Config Folder
explorer.exe /e,"C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$RemoteName"
