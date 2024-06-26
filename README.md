

# *`My fedora environment`*
- `Tolga Erok`
- `2/7/2023`


## My personal fedora tweaks and set-up

My Personal Fedora 39 tweaks and addons.
- Check for new desktop icons:
  
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/setup.sh)"

```

## NEW ( FEDORA 40 )

Horrible move fedora!
- To get X11 back on login screen and in general:

```sh
sudo dnf install plasma-workspace-x11.x86_64 && sudo dnf install kwin-x11
```

- Nvidia installer?
```sh
sudo dnf install dnf-plugins-core -y
sudo dnf copr enable t0xic0der/nvidia-auto-installer-for-fedora -y
sudo dnf install nvautoinstall -y

```

## NEW ( FEDORA 39 )
```sh
My Personal Fedora 39 addins:
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/TolgaFedora39.sh)"
```

<div align="left">
  <table style="border-collapse: collapse; width: 100%; border: none;">
    <td align="center" style="border: none;">
        <a href="https://fedoraproject.org/">
          <img src="https://flathub.org/img/distro/fedora.svg" alt="Debian" style="width: 100%;">
          <br>fedora
        </a>
      </td>
    </tr>
  </table>
</div>

The following script automates various steps for modifying the system configuration, installing the Nvidia driver, and preparing the system for optimal performance. Here's a breakdown of the script's actions:

- Check if the script is run as root.
- Set up variables for user pictures, Samba, and wallpaper directories.
- Update the system and install the "nala" package.
- Install additional software packages, including mpg123, media codecs, and various applications using Flatpak.
- Download and install TeamViewer and Visual Studio Code.
- Install PowerShell and configure system components.
- Speed up DNF package manager and set up RPM Fusion repositories.
- Install Samba and its dependencies.
- Copy custom Samba files and configure Samba user and group.
- Create and configure custom Samba folders and user shares.
- Configure the fstab file to mount network shares on boot.
- Create mount points and set permissions for the shares.
- Mount the shares and start Samba services.
- Test the fstab entries by listing the mounted directories.
- Copy wallpapers to the user's home directory.
- Enable Free and non-free RPM Fusion repositories.
- Update the core system: This step updates the core system packages, including the kernel, and performs necessary upgrades and cleanups.
- Install Nvidia: The script installs the Nvidia driver and related packages, such as kmod-nvidia, akmod-nvidia, and xorg-x11-drv-nvidia-cuda. It also installs additional components for CUDA/nvdec/nvenc support and Vulkan.
- Cleaning up grub and uninstalling the Nouveau driver: The script modifies the grub configuration by appending necessary lines and disabling the Nouveau driver during boot. It also removes the xorg-x11-drv-nouveau package and updates the grub configuration.
- Configure Nvidia: This step launches the Nvidia settings utility for further configuration.
- Defrag or fstrim: The script prompts to perform a defragmentation or fstrim operation.
- Completion and Nvidia version: It displays the Nvidia driver version installed on the system.
- Reboot: The system automatically reboots after a 4-minute countdown.

# *Summary*
*Please note that executing this script may have implications on your system, such as modifying the bootloader configuration and installing or removing packages. Ensure that you have a backup and understand the `consequences` before proceeding.*

*The script provides a comprehensive solution for installing the Nvidia driver and optimizing system performance. It starts by enabling the Free and non-free RPM Fusion repositories, updates the core system, and then proceeds to install the Nvidia driver and its related packages. Additionally, the script takes care of `cleaning up the grub` configuration and uninstalling the `Nouveau` driver.*


## *`How to run?`*

1. Make sure `git` is usable. If not, *install it:*

```sh
sudo dnf install git -y
```

2. Open Terminal, type:

```sh
git clone https://github.com/tolgaerok/fedora-tolga.git
cd ./fedora-tolga
```

3. Run it:

```sh
chmod u+x ./install.sh
sudo ./install.sh
```
## NEW
```sh
My Fedora 39
Tweaks:
https://github.com/tolgaerok/tolga-scripts/tree/main/Fedora39

Fedora 39 addins:
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/TolgaFedora39.sh)"
```

## *Other repositories in my git hub:*

<div align="center">
  <table style="border-collapse: collapse; width: 100%; border: none;">
    <tr>
     <td align="center" style="border: none;">
        <a href="https://github.com/tolgaerok/Debian-tolga">
          <img src="https://flathub.org/img/distro/debian.svg" alt="Fedora" style="width: 100%;">
          <br>Debian
        </a>
      </td>
      <td align="center" style="border: none;">
        <a href="https://github.com/tolgaerok/NixOS-tolga">
          <img src="https://flathub.org/img/distro/nixos.svg" alt="NixOs" style="width: 100%;">
          <br>NixOs 23.05
        </a>
      </td>
    </tr>
  </table>
</div>

## *My Stats:*

<div align="center">

<div style="text-align: center;">
  <a href="https://git.io/streak-stats" target="_blank">
    <img src="http://github-readme-streak-stats.herokuapp.com?user=tolgaerok&theme=dark&background=000000" alt="GitHub Streak" style="display: block; margin: 0 auto;">
  </a>
  <div style="text-align: center;">
    <a href="https://github.com/anuraghazra/github-readme-stats" target="_blank">
      <img src="https://github-readme-stats.vercel.app/api/top-langs/?username=tolgaerok&layout=compact&theme=vision-friendly-dark" alt="Top Languages" style="display: block; margin: 0 auto;">
    </a>
  </div>
</div>
</div>
