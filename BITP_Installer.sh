#!/bin/bash

# Check if the script is running as root
if [ $(id -u) -ne 0 ]; then
    echo "BITP Installer must be run as root."
    echo "Try 'sudo bash $0'"
    exit 1
fi

echo "This BITP_Installer will reboot after execution."
echo -n "Do you want to continue? [y/n] "
read
if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then
    echo "Exit by refusing reboot."
    exit 1
fi

# Get the path of the script
DIR="$( cd "$( dirname "$0" )" && pwd -P )"
echo BITP Program Path=\'$DIR\'
cd $DIR

# install module
echo "Installing requirement python modules..."
if sudo apt install python3-xmltodict && sudo apt install python3-dotenv; && sudo apt install python3-flask; then
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

# # install rgb matrix installer
# echo "Installing RGB Matrix..."
# if sudo bash ./src/rgb-matrix_installer.sh; then
#     echo "RGB Matrix installation completed successfully."
# else
#     echo
#     echo "BITP installation failed."
#     exit 1
# fi
# echo

# complete installation
echo "BITP installation completed successfully."
echo

# reboot
for ((i=5; i>=1; i--)); do
    echo "Reboot in $i seconds..."
    sleep 1
done
echo "Reboot process started..."
reboot
sleep infinity