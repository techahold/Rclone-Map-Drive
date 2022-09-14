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

#download files
#unzip 
#create conf
#reg entries
#run mount 
#startup command for machine 
#shortcut in startup and program files in case of crashing
#change data to program files
#invoke web request
#user script , owner of explorer.exe. Run cmd as user
#ask for drive letter

$rclonedir="C:\Program Files\Rclone"
$RemoteName="Sharepoint"
$MapDriveName="\\server\shared"
$tag = (Invoke-WebRequest "https://api.github.com/repos/rclone/rclone/releases/latest" | ConvertFrom-Json)[0].tag_name

#Probably not needed, but still maybe useful, just needs simple setup if its there, could have a load of basic ones setup 
#$rclonecfg_conf = @"
#[$RemoteName]
#type = onedrive
#token = {"access_token":"-","token_type":"Bearer","refresh_token":"-","expiry":"2022-09-13T15:12:11.1298765+01:00"}
#drive_id = b!--
#drive_type = business
#"@

#new-item c:\ProgramData\rclone -itemtype directory

#Get and expand programs
new-item $rclonedir -itemtype directory
Invoke-WebRequest -Uri "https://github.com/rclone/rclone/releases/download/$tag/rclone-$tag-windows-amd64.zip" -outfile "$rclonedir\rclone.zip"
Invoke-WebRequest -Uri "https://github.com/winfsp/winfsp/releases/download/v1.11/winfsp-1.11.22176.msi" -outfile "$rclonedir\winfsp.msi"
Expand-Archive -LiteralPath $rclonedir\rclone.zip -DestinationPath $rclonedir -Force
Copy-Item $rclonedir\rclone-$tag-windows-amd64\* -Destination $rclonedir\
Remove-Item "C:\Program Files\Rclone\rclone.zip" -Force
Remove-Item "C:\Program Files\Rclone\Rclone" -Force

#install winfsp
Start-Process $rclonedir\winfsp.msi -ArgumentList /passive

#generate Rclone config
New-Item "C:\Users\$username\AppData\Roaming\rclone -itemtype directory
New-Item "C:\Users\$username\AppData\Roaming\rclone\rclone.conf"
Set-Content "C:\Users\$username\AppData\Roaming\rclone\rclone.conf" $rclonecfg_conf

#update token for current user, been changed to just setup as update just takes to onedrive. this should be written to the program files folder and a shortcut made ideally with rclone shortcut

# Create Start Program Entries 
new-item "C:\Users\$username\AppData\Local\rclone\logs" -itemtype directory
new-item "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\rclone - $RemoteName" -itemtype directory
New-Item "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\rclone - $RemoteName\Set Token for $RemoteName.bat"
Set-Content "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\rclone - $RemoteName\Set Token for $RemoteName.bat" "echo "Setup your cloud connection now" `ncd $rclonedir`nrclone config"
# We probably want this written out after the script above is finished, 
$MapDriveBat= @"
cd $rclonedir 
rclone mount ${RemoteName}:/ P: --volname $MapDriveName --vfs-cache-mode off --no-console --log-file %LOCALAPPDATA%\rclone\logs\driveP.txt
"@

New-Item "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\rclone - $RemoteName\Map Drive for $RemoteName.bat"
Set-Content "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\rclone - $RemoteName\Map Drive for $RemoteName.bat" $MapDriveBat

Copy-Item "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\rclone - $RemoteName\Map Drive for $RemoteName.bat" -Destination "C:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Map Drive for $RemoteName.bat" #user startup 

