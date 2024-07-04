prompt_confirmation=true
# Check if --no-confirm argument is passed
if [[ "$1" == "--no-confirm" ]]; then
    prompt_confirmation=false
fi

# Change to the directory where this script is located
cd "$(dirname "$0")"


# Example: Create a swap file for hibernation
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' | tee -a /etc/fstab
echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet resume=/dev/mapper/$(lsblk -no UUID $DEVICE-crypt)"' | tee -a /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg



declare -A prep_stage=(
    [base-devel]="Base development tools"
    [git]="Version control system"
    [ttf-jetbrains-mono-nerd]="JetBrains Mono Nerd Font"
    [noto-fonts-emoji]="Google Noto emoji fonts"
    [gvfs]="GNOME Virtual File System support for NTFS and other file systems"
    [qt5-wayland]="Qt5 Wayland platform"
    [qt5ct]="Qt5 Configuration Tool"
    [qt6-wayland]="Qt6 Wayland platform"
    [qt6ct]="Qt6 Configuration Tool"
    [qt5-svg]="Qt5 SVG support"
    [qt5-quickcontrols2]="Qt5 Quick Controls 2"
    [qt5-graphicaleffects]="Qt5 Graphical Effects"
    [gtk3]="GTK+ 3 toolkit"
    [polkit-gnome]="Polkit GNOME authentication agent"
    [timeshift]="System restore utility"
    [jq]="JSON processor"
    [wl-clipboard]="Clipboard manager for Wayland"
    [cliphist]="Clipboard history manager"
    [python-requests]="Python HTTP library"
    [pacman-contrib]="Pacman utilities"
    [brightnessctl]="CLI tool to control screen brightness"
    [bluez]="Bluetooth protocol stack for Linux"
    [bluez-utils]="Utilities for Bluetooth development"
    [blueman]="GTK+ Bluetooth Manager"
    [network-manager-applet]="Applet for managing network connections"
    [btop]="Resource monitor that shows usage and stats"
    [xfconf]="xfconf-query library"
)

declare -A audio_stage=(
    [pipewire]="Multimedia server"
    [wireplumber]="PipeWire session manager"
    [pipewire-alsa]="ALSA support for PipeWire"
    [pipewire-jack]="JACK support for PipeWire"
    [pipewire-pulse]="PulseAudio support for PipeWire"
    [alsa-utils]="ALSA utilities"
    [helvum]="GTK patchbay for PipeWire"
    [pamixer]="Pulseaudio command-line mixer like amixer"
    [pavucontrol]="PulseAudio Volume Control"
)

#software for nvidia GPU
declare -A nvidia_stage=(
    [linux-headers]="Header files and scripts for building modules for the Linux kernel"
    [nvidia-dkms]="NVIDIA driver with DKMS support"
    [nvidia-settings]="NVIDIA driver settings utility"
    [libva]="Video Acceleration (VA) API for Linux"
    [libva-nvidia-driver-git]="VA-API implementation for NVIDIA driver"
)

#the main packages
declare -A install_stage=(
    [hyprland]="Desktop manager"
    [sddm]="Simple Desktop Display Manager"
    [waybar]="Highly customizable Wayland bar for Sway and Wlroots based compositors"
    [wofi]="Application launcher for Wayland"
    [kitty]="A fast, feature-rich, GPU-based terminal emulator"
    [starship]="Cross-shell prompt for astronauts"
    [mako]="Lightweight notification daemon for Wayland"
    [xdg-desktop-portal-hyprland]="XDG desktop portal backend for Hyprland"
    [swappy]="A Wayland native snapshot editing tool"
    [grim]="Grab images from a Wayland compositor"
    [slurp]="Select a region in a Wayland compositor"
    [mc]="Midnight commander terminal file manager"
    [thunderbird]="Email client from Mozilla"
    [brave-bin]="Brave browser"
    [mpv]="Media player"
    [fastfetch]="Show system info"
)

declare -A optional_stage=(
    [swww]="Wallpaper setter for Wayland"
    [swaylock-effects]="Swaylock with fancy effects"
    [wlogout]="Wayland logout menu"
    [papirus-icon-theme]="Icon theme for Linux"
    [lxappearance]="GTK+ theme switcher"
    [xfce4-settings]="Settings manager for Xfce"
    [nwg-look-bin]="GTK3 settings editor for wlroots-based compositors"
    [ardour]="Digital audio workstation"    
    [davinci-resolve-studio]="Professional video editing software"
    [firefox]="Web browser from Mozilla"
)

# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
INSTLOG="install.log"

######

# function that would show a progress bar to the user
show_progress() {
    while ps | grep $1 &> /dev/null;
    do
        echo -n "."
        sleep 2
    done
    echo -en "Done!\n"
    sleep 2
}

install_software() {
    declare -n packages=$1  # Use nameref to reference the dictionary passed as argument
    packages_to_install=""
    
    for package in "${!packages[@]}"; do
        packages_to_install+="$package "
        # Print package description
        echo "Installing $package - ${packages[$package]}"
    done
    
    # Install all packages at once, only if they are not already installed
    if [ -n "$packages_to_install" ]; then
        echo -en "$CNT - Now installing $packages_to_install."
        yay -S --needed --noconfirm $packages_to_install &>> $INSTLOG &
        show_progress $!
        
        # Verify installation of each package
        for package in $packages_to_install; do
            if yay -Q "$package" &> /dev/null ; then
                echo -e "\e[1A\e[K$COK - $package was installed."
            else
                echo -e "\e[1A\e[K$CER - $package install failed, please check the install.log"
                exit 1
            fi
        done
    fi
}

# clear the screen
clear


# # starting setup 
# if [ "$prompt_confirmation" = true ]; then
#     read -rep $'[\e[1;33mACTION\e[0m] - Would you like to continue with the install (y,n) ' CONTINST
#     if [[ $CONTINST != "Y" && $CONTINST != "y" ]]; then
#         echo -e "$CNT - This script will now exit, no changes were made to your system."
#         exit 1
#     fi
# fi

echo -e "$CNT - Setup starting..."
sudo touch /tmp/configs.tmp

# attempt to discover if this is a VM or not
echo -e "$CNT - Checking for Physical or VM..."
ISVM=$(hostnamectl | grep Chassis)
echo -e "Using $ISVM"
if [[ $ISVM == *"vm"* ]]; then
    echo -e "$CWR - Please note that VMs are not fully supported and if you try to run this on
    a Virtual Machine there is a high chance this will fail."
    sleep 1
fi

# find the Nvidia GPU
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    ISNVIDIA=true
else
    ISNVIDIA=false
fi

#### Check for package manager ####
if [ ! -f /sbin/yay ]; then  
    echo -en "$CNT - Configuering yay."
    git clone https://aur.archlinux.org/yay.git &>> $INSTLOG
    cd yay
    makepkg -si --noconfirm &>> ../$INSTLOG &
    show_progress $!
    if [ -f /sbin/yay ]; then
        echo -e "\e[1A\e[K$COK - yay configured"
        cd ..
        
        # update the yay database
        echo -en "$CNT - Updating yay."
        yay -Suy --noconfirm &>> $INSTLOG &
        show_progress $!
        echo -e "\e[1A\e[K$COK - yay updated."
    else
        # if this is hit then a package is missing, exit to review log
        echo -e "\e[1A\e[K$CER - yay install failed, please check the install.log"
        exit
    fi
fi

# if [ "$prompt_confirmation" = true ]; then
#     read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install the packages? (y,n) ' INST
#     if [[ $INST != "Y" && $INST != "y" ]]; then
#         echo "Installation cancelled."
#         exit 1
#     fi
# fi

# Call the install function with all package names
echo -e "$CNT - Prep Stage - Installing needed components"
install_software prep_stage

echo -e "$CNT - Audio Stage - Installing audio components"
install_software audio_stage

# Setup Nvidia if it was found
if [[ "$ISNVIDIA" == true ]]; then
    echo -e "$CNT - Nvidia GPU support setup stage..."
    install_software nvidia_stage

    # update config
    sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
    echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>> $INSTLOG
fi

echo -e "$CNT - Installing main components..."
install_software install_stage

# Start the bluetooth service
# echo -e "$CNT - Starting the Bluetooth Service..."
# sudo systemctl enable --now bluetooth.service &>> $INSTLOG
# sleep 2
   
# Clean out other portals
echo -e "$CNT - Cleaning out conflicting xdg portals..."
yay -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk &>> $INSTLOG


echo -e "$CNT - Copying config files..."

# copy the configs directory
cp -R configs ~/.config/

#set the measuring unit for waybar
echo -e "$CNT - Attempring to set mesuring unit..."
if locale -a | grep -q ^en_US; then
    echo -e "$COK - Setting mesuring system to imperial..."
    ln -sf ~/.config/configs/waybar/conf/mesu-imp.jsonc ~/.config/configs/waybar/conf/mesu.jsonc
    sed -i 's/SET_MESU=""/SET_MESU="I"/' ~/.config/configs/hyprv.conf
else
    echo -e "$COK - Setting mesuring system to metric..."
    sed -i 's/SET_MESU=""/SET_MESU="M"/' ~/.config/configs/hyprv.conf
    ln -sf ~/.config/configs/waybar/conf/mesu-met.jsonc ~/.config/configs/waybar/conf/mesu.jsonc
fi

# Setup each appliaction
# check for existing config folders and backup 
for DIR in hypr kitty mako swaylock waybar wlogout wofi 
do 
    DIRPATH=~/.config/$DIR
    if [ -d "$DIRPATH" ]; then 
        echo -e "$CAT - Config for $DIR located, backing up."
        mv $DIRPATH $DIRPATH-back &>> $INSTLOG
        echo -e "$COK - Backed up $DIR to $DIRPATH-back."
    fi

    # make new empty folders
    mkdir -p $DIRPATH &>> $INSTLOG
done

# link up the config files
echo -e "$CNT - Setting up the new config..." 
cp ~/.config/configs/hypr/* ~/.config/hypr/
ln -sf ~/.config/configs/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -sf ~/.config/configs/mako/conf/config ~/.config/mako/config
ln -sf ~/.config/configs/swaylock/config ~/.config/swaylock/config
ln -sf ~/.config/configs/waybar/conf/config.jsonc ~/.config/waybar/config.jsonc
ln -sf ~/.config/configs/waybar/style/style.css ~/.config/waybar/style.css
ln -sf ~/.config/configs/wlogout/layout ~/.config/wlogout/layout
ln -sf ~/.config/configs/wofi/config ~/.config/wofi/config
ln -sf ~/.config/configs/wofi/style/style-dark.css ~/.config/wofi/style.css

sudo cp -f ~/.config/configs/mc/ini ~/.config/mc/ini 
sudo cp -f ~/.config/configs/mc/darkened.ini /usr/share/mc/skins/darkened.ini


mkdir -p ~/.themes
cp -r -f -d ~/.config/configs/gtktheme/Arc-BLACKEST ~/.themes/
xfconf-query -c xsettings -p /Net/ThemeName -s "BWnB-GTK"
xfconf-query -c xsettings -p /Net/IconThemeName -s "BWnB-GTK"
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "BWnB-GTK"


# add the Nvidia env file to the config (if needed)
if [[ "$ISNVIDIA" == true ]]; then
    echo -e "\nsource = ~/.config/hypr/env_var_nvidia.conf" >> ~/.config/hypr/hyprland.conf
fi

WLDIR=/usr/share/wayland-sessions
if [ -d "$WLDIR" ]; then
    echo -e "$COK - $WLDIR found"
else
    echo -e "$CWR - $WLDIR NOT found, creating..."
    sudo mkdir $WLDIR
fi 

# stage the .desktop file, which is used by SDDM to show it during login
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF


# Copy the SDDM theme
# echo -e "$CNT - Setting up the login screen."
# sudo cp -R Extras/sdt /usr/share/sddm/themes/
# sudo chown -R $USER:$USER /usr/share/sddm/themes/sdt
# sudo mkdir /etc/sddm.conf.d
# echo -e "[Theme]\nCurrent=sdt" | sudo tee -a /etc/sddm.conf.d/10-theme.conf &>> $INSTLOG


# setup the first look and feel as dark
# xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
# xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
# gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
# gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
# cp -f ~/.config/configs/backgrounds/background-dark.jpg /usr/share/sddm/themes/sdt/wallpaper.jpg


### Install the starship shell ###
echo -e "$CNT - Install Starship"
echo -e "$CNT - Updating .bashrc..."
echo -e '\neval "$(starship init bash)"' >> ~/.bashrc
echo -e '\neval "$(starship init zsh)"' >> ~/.zshrc
echo -e "$CNT - copying starship config file to ~/.config ..."
mkdir -p ~/.config
cp configs/starship/starship.toml ~/.config/


### Script is done ###
echo -e "$CNT - Script had completed!"
if [[ "$ISNVIDIA" == true ]]; then 
    echo -e "$CAT - Since we attempted to setup an Nvidia GPU the script will now end and you should reboot.
    Please type 'reboot' at the prompt and hit Enter when ready."
    exit
fi

# Enable the sddm login manager service
echo -e "$CNT - Enabling the SDDM Service..."
sudo systemctl enable sddm &>> $INSTLOG
sleep 2

exec sudo systemctl start sddm &>> $INSTLOG