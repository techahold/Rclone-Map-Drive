# Rclone Map Drive by Techahold

Program using Powershell to map cloud storage as internal drive using Rsync for transmitting and recieving files. </br>
Executable can be used for general install or script can be customised to change installed files location and mapped drive name.</br>
This installs required dependencies and creates a startup entry to map drive on log in.</br>

### Easy Install
Easy install with exe
1. Download exe and run as admin
2. The setup file directory will open automatically.
3. Run `Setup Techahold Map Drive` Rclone config will launch, and create a file which will be copied to your users startup folder.
4. Connect Rclone to cloud platform by selecting the relevant options. Default settings are fine in most cases Specific config details on https://rclone.org/
5. Once configured, run `Techahold Map Drive for $Username` to mount drive

### Easy install with Script
1. Download ps1 file and open powershell as admin
2. cd to directory the script is located.
3. Type `.\RcloneMapDrive.ps1`
4. The setup file directory will open automatically.
5. Run `Setup Techahold Map Drive` Rclone config will launch, and create a file which will be copied to your users startup folder.
6. Connect Rclone to cloud platform by selecting relevant options. Default settings are fine in most cases Specific config details on https://rclone.org/
7. Once configured, run `Techahold Map Drive for $Username` to mount drive

### Custom Install
`$rclonedir` specifies where Rclone installs. This is called numerous times and a holding directory is created to store the installer files during installation.</br>
`$RemoteName` defines which remote service it is connecting to. This can be changed safely without impacting any functions for customer specific customisation etc.</br>
`$MapDriveName` is the name the drive will be listed as in File Explorer.</br>
