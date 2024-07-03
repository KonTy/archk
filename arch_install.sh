#!/bin/bash

# Ensure jq and archinstall are installed
pacman -Sy --noconfirm jq archinstall git

# Find the largest SSD/NVMe device
DEVICE=$(lsblk -d -o NAME,TYPE,SIZE | grep -E 'ssd|nvme' | sort -k3 -rh | head -n 1 | awk '{print $1}')

if [ -z "$DEVICE" ]; then
  echo "No SSD or NVMe drive found."
  exit 1
fi

DEVICE="/dev/$DEVICE"

# Ask for LUKS2 password
read -s -p "Enter LUKS2 password: " LUKS_PASSWORD
echo
read -s -p "Confirm LUKS2 password: " LUKS_PASSWORD_CONFIRM
echo

if [ "$LUKS_PASSWORD" != "$LUKS_PASSWORD_CONFIRM" ]; then
  echo "Passwords do not match."
  exit 1
fi

# Create the archinstall configuration file
CONFIG_FILE="archinstall-config.json"

cat > $CONFIG_FILE <<EOF
{
  "disk": {
    "device": "$DEVICE",
    "partitions": [
      {
        "mountpoint": "/boot",
        "size": "+512M",
        "type": "primary",
        "filesystem": "vfat"
      },
      {
        "mountpoint": "unencrypted",
        "size": "100%",
        "type": "primary",
        "encrypted": {
          "password": "$LUKS_PASSWORD",
          "encryption_type": "luks2"
        },
        "partitions": [
          {
            "mountpoint": "/",
            "size": "100%",
            "filesystem": "btrfs"
          }
        ]
      }
    ]
  },
  "bootloader": {
    "install": true,
    "location": "$DEVICE",
    "install_grub": true
  },
  "filesystem": "btrfs",
  "swap": {
    "enabled": true,
    "size": "2G",
    "hibernate": true
  },
  "hostname": "archlinux",
  "locale": "en_US.UTF-8",
  "timezone": "UTC",
  "user": {
    "name": "alya",
    "password": "$LUKS_PASSWORD",
    "autologin": true
  },
  "root_password": "$LUKS_PASSWORD",
  "packages": [
    "base",
    "linux",
    "linux-firmware",
    "vim",
    "grub",
    "os-prober",
    "efibootmgr",
    "git"
  ],
  "services": [
    "NetworkManager"
  ],
  "post_install_script": {
    "path": "/root/post_install.sh",
    "run_in_chroot": true
  }
}
EOF

# Create a post-install script that clones the repository and runs the actual post-install script
cat > /root/post_install.sh <<EOF
#!/bin/bash
git clone https://github.com/KonTy/archk /root/archk
cd /root/archk
./arch_post_install.sh
EOF

chmod +x /root/post_install.sh

# Run archinstall with the generated configuration file
archinstall --config $CONFIG_FILE