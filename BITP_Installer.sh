#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd -P )"

# Get the path of the script
echo BITP Program Path=\'$DIR\'
cd "$DIR"

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "BITP Installer must be run as root."
    echo "Try 'sudo bash $0'"
    exit 1
fi

echo "This BITP_Installer will reboot after execution."
echo -n "Do you want to continue? [y/[n]] "
read -r REPLY
if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then
    echo "Exit by refusing reboot."
    exit 1
fi

CMDLINE_FILE="/boot/firmware/cmdline.txt"

# install module
sudo python3 -m pip config set global.break-system-packages true
sudo python -m pip install --upgrade pip
sudo pip install --upgrade setuptools
echo "Installing requirement python modules..."
if sudo pip install -r requirements.txt; then
    echo "Python modules installed successfully."
else
    echo
    echo "BITP installation failed."
    exit 1
fi
echo

# install service
echo "Installing service..."
## copy service file
if sudo cp ./src/bitp.service /lib/systemd/system/bitp.service; then
    echo ".service file copied successfully."
else
    echo
    echo "BITP installation failed."
    exit 1
fi
## change permission
if sudo chmod 644 /lib/systemd/system/bitp.service; then
    echo "Service permission changed successfully."
else
    echo
    echo "BITP installation failed."
    exit 1
fi
## reload daemon
if sudo systemctl daemon-reload; then
    echo "Daemon reloaded successfully."
else
    echo
    echo "BITP installation failed."
    exit 1
fi
## enable service
if sudo systemctl enable bitp.service; then
    echo "Service enabled successfully."
else
    echo
    echo "BITP installation failed."
    exit 1
fi
echo "Service installation completed successfully."
echo

# Add isolcpus=3 option to cmdline.txt
if grep -q "isolcpus=3" "$CMDLINE_FILE"; then
    echo "isolcpus=3 option already exists."
else
    echo "Adding isolcpus=3 option to $CMDLINE_FILE..."
    sed -i 's/$/ isolcpus=3/' "$CMDLINE_FILE"
    echo "isolcpus=3 option added successfully."
fi
echo

# install rgb matrix installer
echo "Installing RGB Matrix..."
if sudo bash ./src/rgb-matrix_installer.sh && rm -rf ./rpi-rgb-led-matrix; then
    echo "RGB Matrix installation completed."
else
    echo
    echo "BITP installation failed."
    exit 1
fi
echo RGB Matrix installation completed successfully.
echo

# complete installation
echo "BITP installation completed successfully."
echo

# reboot
for ((i=5; i>=1; i--)); do
    echo "Reboot in $i seconds..."
    sleep 1
done
echo "Reboot process started."
reboot now
