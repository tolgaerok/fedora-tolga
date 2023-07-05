#!/bin/bash

# Tolga Erok    My personal fedora installer
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
WALLPAPERS_DIR="$builddir/WALLPAPERS"

# Update packages list and update system
sudo dnf autoremove -y
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update -y

# Install nala first
sudo dnf install -y nala

# Install some software
## Install mpg123
echo -e "Install MP3 codec...\n"

sudo dnf install -y mpg123

sleep 2
clear

echo -e "Installing Tweaks, media codecs, extensions & plugins\n"

sudo dnf groupupdate -y sound-and-video
sudo dnf install -y libdvdcss libdrm-devel gtk3-devel gcc pkg-config --allowerasing --skip-broken
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg --allowerasing --skip-broken
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade -y --with-optional Multimedia

sleep 2
clear

# Set-up flatpak and some flatpak software
echo -e "Install Flatpak apps...\n"

## Enable Flatpak
if ! sudo flatpak remote-list | grep -q "flathub"; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

## Update Flatpak
sudo flatpak update

## Install flatpak apps
packages=(
    app.drey.Dialect
    com.anydesk.Anydesk
    com.bitwarden.desktop
    com.calibre_ebook.calibre
    com.getpostman.Postman
    com.github.unrud.VideoDownloader
    com.sindresorhus.Caprine
    com.sublimetext.three
    com.transmissionbt.Transmission
    com.wps.Office
    io.github.aandrew_me.ytdn
    io.github.ltiber.Pwall
    io.github.mimbrero.WhatsAppDesktop
    io.gitlab.o20.word
    org.audacityteam.Audacity
    org.gimp.GIMP
    org.gnome.gitlab.YaLTeR.VideoTrimmer
    org.gnome.Shotwell
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

## End
echo -e "\nSoftware install complete..."

# Download teamviewer
download_url="https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.43.6_amd64.deb?utm_source=google&utm_medium=cpc&utm_campaign=au%7Cb%7Cpr%7C22%7Cjun%7Ctv-core-brand-only-exact-sn%7Cfree%7Ct0%7C0&utm_content=Exact&utm_term=teamviewer&ref=https%3A%2F%2Fwww.teamviewer.com%2Fen-au%2Fdownload%2Flinux%2F%3Futm_source%3Dgoogle%26utm_medium%3Dcpc%26utm_campaign%3Dau%257Cb%257Cpr%257C22%257Cjun%257Ctv-core-brand-only-exact-sn%257Cfree%257Ct0%257C0%26utm_content%3DExact%26utm_term%3Dteamviewer"
download_location="/tmp/teamviewer_15.43.6_amd64.deb"

echo "Downloading teamviewer..."
wget -O "$download_location" "$download_url"

# Install Visual Studio Code
echo "Installing teamviwer..."
sudo dpkg -i "$download_location"
sudo apt-get install -f -y

# Cleanup
echo "Cleaning up..."
rm "$download_location"

# Download Visual Studio Code
download_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
download_location="/tmp/vscode.deb"

echo "Downloading Visual Studio Code..."
wget -O "$download_location" "$download_url"

# Install Visual Studio Code
echo "Installing Visual Studio Code..."
sudo dpkg -i "$download_location"
sudo apt-get install -f -y

# Cleanup
echo "Cleaning up..."
rm "$download_location"

echo "Installation completed."

# Install system components for powershell
sudo apt update && sudo apt install -y curl gnupg apt-transport-https

# Save the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor --output /usr/share/keyrings/microsoft.gpg

# Register the Microsoft Product feed
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'

# Install PowerShell
sudo apt update && sudo apt install -y powershell

# Start PowerShell
# pwsh

read -r -p "Installing Nvidia..." -t 2 -n 1 -s

## Update system
echo -e "\e[94mSpeeding Up DNF before installing Nvidia and RPM fusions\e[0m\n"

echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf

sleep 3
clear

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

# Refresh /etc/samba
sudo systemctl restart smb.service

read -r -p "Continuing...
" -t 1 -n 1 -s

# Create samba user/group
read -r -p "Install samba and create user/group
" -t 2 -n 1 -s

sudo groupadd samba
sudo useradd -m tolga
sudo smbpasswd -a tolga
sudo usermod -aG samba tolga

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

# Configure user shares
read -r -p "Create and configure user shares
" -t 2 -n 1 -s

sudo mkdir /var/lib/samba/usershares
sudo groupadd -r sambashare
sudo chown root:sambashare /var/lib/samba/usershares
sudo chmod 1770 /var/lib/samba/usershares
sudo gpasswd sambashare -a tolga
sudo usermod -aG sambashare tolga

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

read -r -p "
Continuing..." -t 1 -n 1 -s

# Mount the shares and start services
read -r -p "Mount the shares and start services
" -t 2 -n 1 -s && echo ""

sudo mount -a || {
    echo "Mount failed"
    exit 1
}
sudo systemctl enable smb nmb || {
    echo "Failed to enable services"
    exit 1
}
sudo systemctl restart smb.service nmb.service || {
    echo "Failed to restart services"
    exit 1
}
sudo systemctl daemon-reload

read -r -p "
Continuing..." -t 1 -n 1 -s

# Test the fstab entries
read -r -p "Test the fstab entries" -t 2 -n 1 -s

sudo ls /mnt/home-profiles || {
    echo "Failed to list Linux data"
    exit 1
}
sudo ls /mnt/linux-data || {
    echo "Failed to list Linux data"
    exit 1
}
sudo ls /mnt/smb || {
    echo "Failed to list SMB share"
    exit 1
}
sudo ls /mnt/windows-data || {
    echo "Failed to list Windows data"
    exit 1
}
sudo ls /mnt/Budget-Archives || {
    echo "Failed to list Windows data"
    exit 1
}
sudo ls /mnt/smb-budget || {
    echo "Failed to list Windows data"
    exit 1
}
sudo ls /mnt/smb-rsync || {
    echo "Failed to list Windows data"
    exit 1
}

read -r -p "
Continuing..." -t 1 -n 1 -s

read -r -p "Copy WALLPAPER to user home
" -t 2 -n 1 -s

# Create the TARGET_DIR if it doesn't exist
mkdir -p "$USER_PIC"

# Copy the files from WALLPAPERS to TARGET_DIR
cp -r "$WALLPAPERS_DIR"/* "$USER_PIC"
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
sleep 1

echo "Done. Time to defrag or fstrim."
sudo fstrim -av
echo ""
echo "Operation completed."
echo ""

## Enable Free and non-free RPM fusions
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y rpmfusion-free-release-tainted --allowerasing --skip-broken

## Update core-system
sudo dnf groupupdate core -y
sudo dnf update -y # and reboot if you are not on the latest kernel
sudo dnf upgrade --refresh
sudo dnf groupupdate -y core
sudo dnf install -y dnf-plugins-core
sudo dnf autoremove -y
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update -y

## Install Nvidia
sudo dnf -y install kmod-nvidia
sudo dnf install -y akmod-nvidia             # rhel/centos users can use kmod-nvidia instead
sudo dnf install -y xorg-x11-drv-nvidia-cuda #optional for cuda/nvdec/nvenc support
sudo dnf install -y xorg-x11-drv-nvidia-cuda-libs
sudo dnf install -y vdpauinfo libva-vdpau-driver libva-utils
sudo dnf install -y vulkan
sudo dnf autoremove -y

clear

read -r -p "Cleaning up grub and uninstall nouveau driver
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

read -r -p "
..... Complete" -t 1 -n 1 -s

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
