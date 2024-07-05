prompt_confirmation=true
# Check if --no-confirm argument is passed
if [[ "$1" == "--no-confirm" ]]; then
    prompt_confirmation=false
fi

# Change to the directory where this script is located
cd "$(dirname "$0")"


# TODO: how to make brave dark?
# How to lock system with win+L
# how to control volume and brigtness
#how to show wifi and bluetooth and airplane mode
# how to auto mount usb
# how to change SDDM to dark theme
# set background
# how to show windows title
# invoke hybernation
# set computer so it goes to sleep hybernaes after some time
# set background swww img ~/.config/configs/backgrounds/$VER'-background-dark.jpg'
# auto detect surface 
# auto detect and install intel video
# auto detect and install amd video
# test screen sharing with teams and obs
# test screen capture
# figure out hyprv.conf local how to set and how it works
# figure out how to switch keyboards by keypress


# Example: Create a swap file for hibernation
# fallocate -l 2G /swapfile
# chmod 600 /swapfile
# mkswap /swapfile
# swapon /swapfile
# echo '/swapfile none swap defaults 0 0' | tee -a /etc/fstab
# echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet resume=/dev/mapper/$(lsblk -no UUID $DEVICE-crypt)"' | tee -a /etc/default/grub
# grub-mkconfig -o /boot/grub/grub.cfg

# sudo usermod -a -G audio $USER

pkill waybar

# https://wiki.hyprland.org/Useful-Utilities/Must-have/
# for XDPH doesn’t implement a file picker. For that, I recommend installing xdg-desktop-portal-gtk alongside XDPH.
# The most basic way of seeing if everything is OK is by trying to screenshare anything, or by opening OBS and selecting the PipeWire source. If XDPH is running, a Qt menu will pop up asking you what to share.
declare -A prep_stage=(
    [base-devel]="Base development tools"
    [git]="Version control system"
    [ttf-jetbrains-mono-nerd]="JetBrains Mono Nerd Font"
    [ttf-font-awesome]="Font awesome"
    [ttf-dejavu]="Dejavu fonts"
    [noto-fonts-emoji]="Google Noto emoji fonts"
    [gvfs]="GNOME Virtual File System support for NTFS and other file systems"
    [qt5-wayland]="Qt5 Wayland platform"
    [qt5ct]="Qt5 Configuration Tool"
    [qt6-wayland]="Qt6 Wayland platform"
    [qt6ct]="Qt6 Configuration Tool"
    [qt5-svg]="Qt5 SVG support"
    [qt5-quickcontrols2]="Qt5 Quick Controls 2"
    [qt5-graphicaleffects]="Qt5 Graphical Effects"
    [xdg-desktop-portal-hyprland]="XDG desktop portal backend for Hyprland"
    [swaylock]="Locking utility"
    [wlogout]="Wayland logout menu"
    [gtk3]="GTK+ 3 toolkit"
    [gtk2-engines-murrine]="GTK+ theme tools for custom theme support "
    [gnome-themes-extra ]="All gnome themes that don't come with arch"
    [polkit-gnome]="Polkit GNOME authentication agent"
    [timeshift]="System restore utility"
    [jq]="JSON processor"
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

declare -A hyprpaper_stage=(
    [hyprpaper]="Wall paper support"
    [gcc]="GNU Compiler Collection"
    [ninja]="Small build system with a focus on speed"
    [wayland-protocols]="Wayland protocols"
    [libjpeg-turbo]="JPEG image library"
    [libwebp]="WebP image library"
    [pango]="Text layout and rendering library"
    [cairo]="2D graphics library"
    [pkgconf]="Package compiler and linker metadata toolkit"
    [cmake]="Cross-platform make"
    [libglvnd]="The GL Vendor-Neutral Dispatch library"
    [wayland]="Wayland display server protocol"
)

declare -A swww_stage=(
    [swww]="Change background"
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
    [swaylock-effects]="Swaylock with fancy effects"
    [wl-clipboard]="Clipboard manager for Wayland"
    [cliphist]="Clipboard history manager"
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
function setup_dark_theme() {
    # Environment Variables
    PROFILE_FILE="$HOME/.profile"
    XPROFILE_FILE="$HOME/.xprofile"
    
    # GTK Settings
    GTK3_SETTINGS_FILE="$HOME/.config/gtk-3.0/settings.ini"
    GTK4_SETTINGS_FILE="$HOME/.config/gtk-4.0/settings.ini"
    GTK_THEME="Matrix_OLED"
    
    # Qt Settings
    QT5CT_CONFIG_FILE="$HOME/.config/qt5ct/qt5ct.conf"
    
    # Add environment variables to .profile and .xprofile
    for file in "$PROFILE_FILE" "$XPROFILE_FILE"; do
        grep -qxF "export GTK_THEME=$GTK_THEME" "$file" || echo "export GTK_THEME=$GTK_THEME" >> "$file"
        grep -qxF "export QT_QPA_PLATFORMTHEME=qt5ct" "$file" || echo "export QT_QPA_PLATFORMTHEME=qt5ct" >> "$file"
        grep -qxF "export QT_STYLE_OVERRIDE=$GTK_THEME" "$file" || echo "export QT_STYLE_OVERRIDE=$GTK_THEME" >> "$file"
        grep -qxF "export XDG_CURRENT_DESKTOP=Unity:Unity7:GNOME" "$file" || echo "export XDG_CURRENT_DESKTOP=Unity:Unity7:GNOME" >> "$file"
    done
    
    # GTK Settings
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/gtk-4.0"
    
    echo -e "[Settings]\ngtk-application-prefer-dark-theme=1\ngtk-theme-name=$GTK_THEME" > "$GTK3_SETTINGS_FILE"
    echo -e "[Settings]\ngtk-application-prefer-dark-theme=1\ngtk-theme-name=$GTK_THEME" > "$GTK4_SETTINGS_FILE"
    
    # Qt Settings
    mkdir -p "$(dirname "$QT5CT_CONFIG_FILE")"
    if [ ! -f "$QT5CT_CONFIG_FILE" ]; then
        echo -e "[Appearance]\nstyle=$GTK_THEME" > "$QT5CT_CONFIG_FILE"
    else
        sed -i "s/^style=.*/style=$GTK_THEME/" "$QT5CT_CONFIG_FILE"
    fi
    
    # Call function to install custom GTK theme
    install_custom_theme
    
    echo "Dark theme setup completed. Please log out and log back in to apply the changes."
}

function install_custom_theme() {
    THEME_NAME="Matrix_OLED"
    THEME_DIR="$HOME/.themes/$THEME_NAME"
    CONFIGS_DIR="$HOME/.config/configs/gtk"

    # Create directories for GTK themes
    mkdir -p "$THEME_DIR/gtk-3.0"
    mkdir -p "$THEME_DIR/gtk-4.0"
    mkdir -p "$THEME_DIR/gtk-2.0"

    # Copy gtk30.css to GTK3 directory
    cp -f "$CONFIGS_DIR/gtk30.css" "$THEME_DIR/gtk-3.0/gtk.css"

    # Copy gtk40.css to GTK4 directory
    cp -f "$CONFIGS_DIR/gtk40.css" "$THEME_DIR/gtk-4.0/gtk.css"

    # Copy gtkrc20 to GTK2 directory
    cp -f "$CONFIGS_DIR/gtkrc20" "$THEME_DIR/gtk-2.0/gtkrc"

    # Create directories for GTK settings
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/gtk-4.0"

    # Copy settings.ini to GTK3 settings directory
    cp -f "$CONFIGS_DIR/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"

    # Copy settings.ini to GTK4 settings directory
    cp -f "$CONFIGS_DIR/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

    # Set GTK_THEME environment variable
    echo "export GTK_THEME=$THEME_NAME" >> "$HOME/.profile"
    echo "export GTK_THEME=$THEME_NAME" >> "$HOME/.bashrc" # or ~/.zshrc, depending on your shell

    echo "Created and applied the $THEME_NAME theme."
}

# function that would show a progress bar to the user
function show_progress() {
    while ps | grep $1 &> /dev/null;
    do
        echo -n "."
        sleep 2
    done
    echo -en "Done!\n"
    sleep 2
}

function install_software() {
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

# Function to make all files in the specified directory executable
function make_scripts_executable() {
    local script_dir="$1"

    # Check if the directory exists
    if [ ! -d "$script_dir" ]; then
        echo "Directory $script_dir does not exist."
        return 1
    fi

    # Loop through all files in the directory and apply chmod +x
    for file in "$script_dir"/*; do
        if [ -f "$file" ]; then
            chmod +x "$file"
            echo "Made executable: $file"
        fi
    done
}

function setup_darktheme_gtk_qt() {
export GTK_THEME=Adwaita:dark

}

# clear the screen
clear

echo -e "$CNT - Setup starting..."
# sudo touch /tmp/configs.tmp

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

# Call the install function with all package names
echo -e "$CNT - Prep Stage - Installing needed components"
install_software prep_stage

echo -e "$CNT - Prep Stage - Installing hypprpaper components"
install_software swww_stage

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
cp -R -u configs ~/.config/

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

# link up the config files
echo -e "$CNT - Setting up the new config..." 
cp -R -u -f ~/.config/configs/hypr/* ~/.config/hypr/
ln -sf ~/.config/configs/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -sf ~/.config/configs/mako/conf/config ~/.config/mako/config
ln -sf ~/.config/configs/swaylock/config ~/.config/swaylock/config
ln -sf ~/.config/configs/waybar/conf/config.jsonc ~/.config/waybar/config.jsonc
ln -sf ~/.config/configs/waybar/style/style.css ~/.config/waybar/style.css
ln -sf ~/.config/configs/wlogout/layout ~/.config/wlogout/layout
ln -sf ~/.config/configs/wofi/config ~/.config/wofi/config
ln -sf ~/.config/configs/wofi/style/style.css ~/.config/wofi/style.css

sudo cp -f -u ~/.config/configs/mc/ini ~/.config/mc/ini 
sudo cp -f -u ~/.config/configs/mc/darkened.ini /usr/share/mc/skins/darkened.ini


mkdir -p ~/.themes
cp -r -f -d -u ~/.config/configs/gtktheme/Arc-BLACKEST ~/.themes/
xfconf-query -c xsettings -p /Net/ThemeName -s "BWnB-GTK"
xfconf-query -c xsettings -p /Net/IconThemeName -s "BWnB-GTK"
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "BWnB-GTK"

setup_dark_theme
install_custom_theme


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
echo -e "$CNT - Setting up the login screen."
sudo cp -R -u sddm/TerminalStyleLogin /usr/share/sddm/themes/
sudo chown -R $USER:$USER /usr/share/sddm/themes/TerminalStyleLogin
sudo mkdir /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=TerminalStyleLogin" | sudo tee -a /etc/sddm.conf.d/10-theme.conf &>> $INSTLOG


# setup the first look and feel as dark
# xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
# xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
# gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
# gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
# cp -f ~/.config/configs/backgrounds/background-dark.jpg /usr/share/sddm/themes/sdt/wallpaper.jpg

make_scripts_executable "$HOME/.config/configs/waybar/scripts"
make_scripts_executable "$HOME/.config/configs/hypr/scripts"

### Install the starship shell ###
echo -e "$CNT - Install Starship"
echo -e "$CNT - Updating .bashrc..."
echo -e '\neval "$(starship init bash)"' >> ~/.bashrc
echo -e '\neval "$(starship init zsh)"' >> ~/.zshrc
echo -e "$CNT - copying starship config file to ~/.config ..."
mkdir -p ~/.config
cp -f -u configs/starship/starship.toml ~/.config/


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