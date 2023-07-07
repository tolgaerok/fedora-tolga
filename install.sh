#!/bin/bash

# My personal fedora installer, tested on: fedora 37 and 38 KDE
# Tolga Erok
# 28/6/2023

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
    echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
    exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

USER_PIC="/home/$username/Pictures/CUSTOM-WALLPAPERS"
SAMBA="/etc/samba"
SMB_DIR="$builddir/SAMBA"
WALLPAPERS_DIR="$builddir/WALLPAPER"

# Update packages list and update system first
sudo dnf update -y
sudo dnf upgrade --refresh
sudo dnf autoremove -y
sudo fwupdmgr refresh --force && sudo fwupdmgr get-updates && sudo fwupdmgr update -y

# Install some apps
echo -e "Install a few useful packages...\n"

sudo dnf install mpg123 rhythmbox python3 python3-pip libffi-devel openssl-devel kate neofetch -y

echo -e "Installing Google Chrome browser...\n"

wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
sudo dnf install -y ./google-chrome-stable_current_x86_64.rpm
rm -f google-chrome-stable_current_x86_64.rpm

sleep 2
clear

echo -e "Installing Tweaks, media codecs, extensions & plugins\n"

sudo dnf groupupdate -y sound-and-video
sudo dnf install -y libdvdcss libdrm-devel gtk3-devel gcc pkg-config --allowerasing --skip-broken
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg --allowerasing --skip-broken
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade -y --with-optional Multimedia
sudo dnf autoremove -y

sleep 2
clear

echo -e "Install Flatpak apps...\n"

## Enable Flatpak
if ! sudo flatpak remote-list | grep -q "flathub"; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Update Flatpak
sudo flatpak update

echo -e "Updating cache, this will take awhile...\n"

# Install flatpak apps
packages=(
    app.drey.Dialect
    com.anydesk.Anydesk
    com.bitwarden.desktop
    com.calibre_ebook.calibre
    com.github.unrud.VideoDownloader
    com.sindresorhus.Caprine
    com.sublimetext.three
    com.transmissionbt.Transmission
    com.wps.Office
    io.github.aandrew_me.ytdn
    io.github.ltiber.Pwall
    io.github.mimbrero.WhatsAppDesktop
    org.audacityteam.Audacity
    org.gimp.GIMP
    org.gnome.Shotwell
    org.gnome.SimpleScan
    org.gnome.gitlab.YaLTeR.VideoTrimmer
    org.kde.krita
    org.kde.kweather
)

# Install each package if not already installed
for package in "${packages[@]}"; do
    if ! sudo flatpak list | grep -q "$package"; then
        echo "Installing $package..."
        sudo flatpak install -y flathub "$package"
    else
        echo "$package is already installed. Skipping..."
    fi
done

# Double check for the latest flatpak updates and remove flatpak cruft
flatpak update --assumeyes
flatpak uninstall --unused --delete-data --assumeyes

echo -e "\nSoftware install complete..."

# Download teamviewer
download_url="https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm?utm_source=google&utm_medium=cpc&utm_campaign=au%7Cb%7Cpr%7C22%7Cjun%7Ctv-core-download-sn%7Cfree%7Ct0%7C0&utm_content=Download&utm_term=teamviewer+download"
download_location="/tmp/teamviewer.x86_64.rpm"

echo "Downloading TeamViewer..."
wget -O "$download_location" "$download_url"

# Install TeamViewer
echo "Installing TeamViewer..."
sudo dnf install "$download_location" -y

# Cleanup
echo "Cleaning up..."
rm "$download_location"

echo "TeamViewer installation completed."

# Download Visual Studio Code
download_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
download_location="/tmp/vscode.rpm"

echo "Downloading Visual Studio Code..."
wget -O "$download_location" "$download_url"

# Install Visual Studio Code
echo "Installing Visual Studio Code..."
sudo dnf install "$download_location" -y

# Cleanup
echo "Cleaning up..."
rm "$download_location"

echo "Installation completed."

# Install system components for PowerShell
sudo dnf install curl gpg -y

# Save the public repository GPG keys
sudo curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor --output /etc/pki/rpm-gpg/microsoft.gpg

# Register the Microsoft Product feed
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/microsoft-rhel8.1-prod.repo

# Install PowerShell
sudo dnf install powershell -y

# Start PowerShell
# pwsh

read -r -p "Setup SAMBA and system tweaks..." -t 2 -n 1 -s

## Update system first
echo -e "\e[94mSpeeding Up DNF and set-up RPM fusions\e[0m\n"

echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf

sleep 3
clear

echo -e "\e[94mInstall SAMBA and dependencies\e[0m\n"

# Install Samba and its dependencies
sudo dnf install samba samba-client samba-common cifs-utils samba-usershares sudo dnf -y

# Enable and start SMB and NMB services
sudo systemctl enable smb.service nmb.service
sudo systemctl start smb.service nmb.service

# Restart SMB and NMB services (optional)
sudo systemctl restart smb.service nmb.service

# Configure the firewall
sudo firewall-cmd --add-service=samba --permanent
sudo firewall-cmd --add-service=samba
sudo firewall-cmd --runtime-to-permanent
sudo firewall-cmd --reload

# Set SELinux booleans
sudo setsebool -P samba_enable_home_dirs on
sudo setsebool -P samba_export_all_rw on
sudo setsebool -P smbd_anon_write 1

sleep 3
clear

read -r -p "Copy custom samba files..." -t 2 -n 1 -s

# Samba configurations files
read -r -p "Copying samba files?
" -t 2 -n 1 -s

# Define the backup folder path
backup_folder="/etc/samba/backup"

# Create the backup folder if it doesn't exist
sudo mkdir -p "$backup_folder"

# Define the original folder path
original_folder="/etc/samba/ORIGINAL"

# Create the original folder if it doesn't exist
sudo mkdir -p "$original_folder"

# Enable extglob option
shopt -s extglob

# Move contents of /etc/samba (excluding ORIGINAL folder) to original folder
sudo mv /etc/samba/!(ORIGINAL) "$original_folder"

# Copy contents of /etc/samba to backup folder
sudo cp -R "$original_folder"/* "$backup_folder"

# Check if the SMB_DIR exists
if [ ! -d "$SMB_DIR" ]; then
    echo "Error: $SMB_DIR directory not found."
    exit 1
fi

# Copy the files from SMB_DIR to TARGET_DIR
cp -R "$SMB_DIR"/* "$SAMBA"

# Check if the copy operation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy files from $SMB_DIR to $SAMBA."
    exit 1
fi

echo ""
echo "Samba Files copied successfully!"
echo "SMB_DIR: $SMB_DIR"
echo "SMB TARGET_DIR: $SAMBA"
echo ""

read -r -p "Continuing...
" -t 1 -n 1 -s

# Create samba user/group
read -r -p "Set-up samba user & group's
" -t 2 -n 1 -s

# Prompt for the desired username for samba
read -p $'\n'"Enter the USERNAME to add to Samba: " sambausername

# Prompt for the desired name for samba
read -p $'\n'"Enter the GROUP name to add username to Samba: " sambagroup

sudo groupadd $sambagroup
sudo useradd -m $sambausername
sudo smbpasswd -a $sambausername
sudo usermod -aG $sambagroup $sambausername

read -r -p "
Continuing..." -t 1 -n 1 -s

# Configure custom samba folder
read -r -p "Create and configure custom samba folder
" -t 2 -n 1 -s

sudo mkdir /home/fedora
sudo chgrp samba /home/fedora
sudo chmod 770 /home/fedora

read -r -p "
Continuing..." -t 1 -n 1 -s

# Configure usershares plugin
read -r -p "Create and configure Samba Filesharing Plugin ...
" -t 3 -n 1 -s

# Prompt for the desired username
read -p $'\n'"Enter the username to configure Samba Filesharing Plugin for: " username

# Set umask value
umask 0002

# Set the shared folder path
shared_folder="/home/$username"

# Set permissions for the shared folder and parent directories (excluding hidden files and .cache directory)
find "$shared_folder" -type d ! -path '/.' ! -path '/.cache' -exec chmod 0757 {} ; 2>/dev/null

# Create the sambashares group if it doesn't exist
sudo groupadd -r sambashares

# Create the usershares directory and set permissions
sudo mkdir -p /var/lib/samba/usershares
sudo chown $username:sambashares /var/lib/samba/usershares
sudo chmod 1770 /var/lib/samba/usershares

# Restore SELinux context for the usershares directory
sudo restorecon -R /var/lib/samba/usershares

# Add the user to the sambashares group
sudo gpasswd sambashares -a $username

# Add the user to the sambashares group (alternative method)
sudo usermod -aG sambashares $username

# Set permissions for the user's home directory
sudo chmod 0757 /home/$username

# Prompt for user to open browser to kde store - share plugin
read -p $'\n'"Press Enter to open Samba Filesharing Plugin website. Please select [ install ] when ready ...  " 

# Check if Firefox is installed
if command -v firefox >/dev/null 2>&1; then
    sudo -u $username firefox "https://apps.kde.org/kdenetwork_filesharing/"
    exit 0
fi

# Check if Chrome is installed
if command -v google-chrome-stable >/dev/null 2>&1; then
    sudo -u $username google-chrome-stable "https://apps.kde.org/kdenetwork_filesharing/"
    exit 0
fi

# If neither Firefox nor Chrome is found, display an error message
echo "Error: Neither Firefox nor Chrome is installed."

read -r -p "
Continuing ... " -t 1 -n 1 -s

read -r -p "Restarting SMB and NMB services
" -t 2 -n 1 -s

# Restart SMB and NMB services (optional)
sudo systemctl restart smb.service nmb.service

read -r -p "
Continuing..." -t 1 -n 1 -s

read -r -p "Checking smb.conf file
" -t 2 -n 1 -s

# Check Samba configuration
sudo testparm -s

read -r -p "
Continuing..." -t 1 -n 1 -s

# Configure fstab
read -r -p "Configure fstab
" -t 2 -n 1 -s

# Backup the original /etc/fstab file
sudo cp /etc/fstab /etc/fstab.backup

# Define the mount entries
mount_entries=(
    "# Custom mount points"
    "//192.168.0.20/LinuxData /mnt/linux-data cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
    "//192.168.0.20/LinuxData/HOME/PROFILES /mnt/home-profiles cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
    "//192.168.0.20/LinuxData/BUDGET-ARCHIVE/ /mnt/Budget-Archives cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
    "//192.168.0.20/WINDOWSDATA /mnt/windows-data cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
)

# Append the mount entries to /etc/fstab
for entry in "${mount_entries[@]}"; do
    echo "$entry" | sudo tee -a /etc/fstab >/dev/null
done

echo "Mount entries added to /etc/fstab.
"
# Refreshes the systemd configuration/fstab
sudo systemctl daemon-reload

read -r -p "
Continuing..." -t 1 -n 1 -s

# Create mount points and set permissions
read -r -p "Create mount points and set permissions
" -t 2 -n 1 -s

sudo mkdir -p /mnt/Budget-Archives
sudo mkdir -p /mnt/home-profiles
sudo mkdir -p /mnt/linux-data
sudo mkdir -p /mnt/smb
sudo mkdir -p /mnt/smb-budget
sudo mkdir -p /mnt/smb-rsync
sudo mkdir -p /mnt/windows-data
sudo chmod 777 /mnt/Budget-Archives
sudo chmod 777 /mnt/home-profiles
sudo chmod 777 /mnt/linux-data
sudo chmod 777 /mnt/smb
sudo chmod 777 /mnt/smb-budget
sudo chmod 777 /mnt/smb-rsync
sudo chmod 777 /mnt/windows-data

# More secure setup, but not necessary for my home usage
#sudo mkdir -p /mnt/{Budget-Archives,home-profiles,linux-data,smb,smb-budget,smb-rsync,windows-data}
#sudo chown tolga:samba /mnt/Budget-Archives /mnt/home-profiles /mnt/linux-data /mnt/smb /mnt/smb-budget /mnt/smb-rsync /mnt/windows-data
#sudo chmod 770 /mnt/Budget-Archives /mnt/home-profiles /mnt/linux-data /mnt/smb /mnt/smb-budget /mnt/smb-rsync /mnt/windows-data
#sudo gpasswd -a tolga usershares
#sudo setfacl -m "g:usershares:rwx" /mnt/Budget-Archives /mnt/home-profiles /mnt/linux-data /mnt/smb /mnt/smb-budget /mnt/smb-rsync /mnt/windows-data
#sudo setfacl -d -m "g:usershares:rwx" /mnt/Budget-Archives /mnt/home-profiles /mnt/linux-data /mnt/smb /mnt/smb-budget /mnt/smb-rsync /mnt/windows-data

read -r -p "
Continuing..." -t 1 -n 1 -s

# Mount the shares and start services
read -r -p "Mount the shares and start services
" -t 2 -n 1 -s && echo ""

sudo mount -a || {
    echo "Mount failed"
    sleep 3
}
sudo systemctl enable smb nmb || {
    echo "Failed to enable services"
    sleep 3
}
sudo systemctl restart smb.service nmb.service || {
    echo "Failed to restart services"
    sleep 3
}

# Refreshes the systemd configuration/fstab
sudo systemctl daemon-reload

read -r -p "
Continuing..." -t 1 -n 1 -s

# Test the fstab entries
read -r -p "Test the fstab entries" -t 2 -n 1 -s

sudo ls /mnt/home-profiles || {
    echo "Failed to list Linux data"
    sleep 3
}
sudo ls /mnt/linux-data || {
    echo "Failed to list Linux data"
    sleep 3
}
sudo ls /mnt/smb || {
    echo "Failed to list SMB share"
    sleep 3
}
sudo ls /mnt/windows-data || {
    echo "Failed to list Windows data"
    sleep 3
}
sudo ls /mnt/Budget-Archives || {
    echo "Failed to list Windows data"
    sleep 3
}
sudo ls /mnt/smb-budget || {
    echo "Failed to list Windows data"
    sleep 3
}
sudo ls /mnt/smb-rsync || {
    echo "Failed to list Windows data"
    sleep 3
}

read -r -p "
Continuing..." -t 1 -n 1 -s

sleep 2
clear

read -r -p "Copy WALLPAPER to user home
" -t 2 -n 1 -s

# Create the TARGET_DIR if it doesn't exist
mkdir -p "$USER_PIC"

# Copy the files from WALLPAPERS to TARGET_DIR
cp -r "$WALLPAPERS_DIR"/fedora37.png "$USER_PIC"
chown -R $username:$username /home/$username

# Check if the copy operation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy files from $WALLPAPERS_DIR to $USER_PIC."
    exit 1
fi

echo ""
echo "Wallpaper Files copied successfully!"
echo "WALLPAPERS_DIR: $WALLPAPERS_DIR"
echo "WALLPAPERTARGET_DIR: $USER_PIC"
echo ""

echo "Continuing..."
sleep 3
clear

## Enable Free and non-free RPM fusions
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y rpmfusion-free-release-tainted --allowerasing --skip-broken

## Update core-system
sudo dnf upgrade -y && sudo dnf autoremove -y
sudo dnf groupupdate -y core
sudo dnf install -y dnf-plugins-core
sudo fwupdmgr refresh --force && sudo fwupdmgr update -y

## Install Nvidia
sudo dnf install -y kmod-nvidia akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs vdpauinfo libva-vdpau-driver libva-utils vulkan
sudo dnf install akmods && sudo akmods
sudo dnf autoremove -y

sleep 2
clear

read -r -p "Cleaning up grub and uninstalling nouveau driver
" -t 2 -n 1 -s

# Path to the grub configuration file
grub_file="/etc/default/grub"

## Append ‘blacklist nouveau’ create file if null
echo "blacklist nouveau" | sudo tee -a /etc/modprobe.d/blacklist.conf >/dev/null

# Comment out the existing GRUB_CMDLINE_LINUX line
sed -i 's/^GRUB_CMDLINE_LINUX=/#&/' "$grub_file"

# Add the new GRUB_CMDLINE_LINUX line after the commented line
sed -i '/^#GRUB_CMDLINE_LINUX=/a GRUB_CMDLINE_LINUX="rhgb quiet rd.driver.blacklist=nouveau"' "$grub_file"

## Update grub2 conf --> BIOS and UEFI ##
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Remove xorg-x11-drv-nouveau
sudo dnf remove xorg-x11-drv-nouveau

## Backup old initramfs nouveau image ##
#sudo mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img

## Create new initramfs image ##
#sudo dracut /boot/initramfs-$(uname -r).img $(uname -r)

## Configure Nvidia while we're here
sudo nvidia-settings

# Installing fonts
sudo dnf install fontawesome-fonts fontawesome-fonts-web
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d /usr/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d /usr/share/fonts
wget https://github.com/tolgaerok/fonts-tolga/raw/main/WPS-FONTS.zip
unzip WPS-FONTS.zip -d /usr/share/fonts

# Reloading Font
sudo fc-cache -vf

# Removing zip Files
rm ./FiraCode.zip ./Meslo.zip ./WPS-FONTS.zip

read -r -p "
..... Complete" -t 1 -n 1 -s

echo -e "Cleaning up and updating the system...\n"

sudo dnf autoremove -y
sudo dnf clean all
sudo dnf check-update
sudo dnf update -y

sleep 2
clear

echo "Done. Time to defrag or fstrim."
sudo fstrim -av
echo -e "\n\n----------------------------------------------"
echo -e "|                                            |"
echo -e "|        Setup Complete! Enjoy fedora!       |"
echo -e "|                                            |"
echo -e "----------------------------------------------\n\n"

# Display Nvidia version installed
driver_version=$(modinfo -F version nvidia 2>/dev/null)
if [ -n "$driver_version" ]; then
    echo -e "\e[33mNVIDIA driver version: $driver_version\e[0m"
else
    echo -e "\e[33mNVIDIA driver not found.\e[0m"
fi

duration=240 # 4 minutes
seconds_remaining=$duration

echo -e "\e[1;33mWaiting\e[0m for 4 minutes before reboot..."

while [ $seconds_remaining -gt 0 ]; do
    echo -ne "\e[1;31mTime remaining: $seconds_remaining seconds\e[0m \r"
    sleep 1
    seconds_remaining=$((seconds_remaining - 1))
done

echo "Time's up! Rebooting now..."

# Reboot the system
reboot

exit 0
