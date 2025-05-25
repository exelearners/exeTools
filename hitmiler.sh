#!/bin/bash

# Hitmiler: Bluetooth Blocker Tool
# Author: exe learners

# Root check
if [[ $EUID -ne 0 ]]; then
   echo -e "\n🔴 Please run as root!\n"
   exit 1
fi

# Banner
clear
echo -e "\e[31m"
cat << "EOF"
       ▄████  ██░ ██ ▄▄▄█████▓ ███▄ ▄███▓ ██▓    ▓█████ ▓█████▄ 
      ██▒ ▀█▒▓██░ ██▒▓  ██▒ ▓▒▓██▒▀█▀ ██▒▓██▒    ▓█   ▀ ▒██▀ ██▌
     ▒██░▄▄▄░▒██▀▀██░▒ ▓██░ ▒░▓██    ▓██░▒██░    ▒███   ░██   █▌
     ░▓█  ██▓░▓█ ░██ ░ ▓██▓ ░ ▒██    ▒██ ▒██░    ▒▓█  ▄ ░▓█▄   ▌
     ░▒▓███▀▒░▓█▒░██▓  ▒██▒ ░ ▒██▒   ░██▒░██████▒░▒████▒░▒████▓ 
      ░▒   ▒  ▒ ░░▒░▒  ▒ ░░   ░ ▒░   ░  ░░ ▒░▓  ░░░ ▒░ ░ ▒▒▓  ▒ 
       ░   ░  ▒ ░▒░ ░    ░     ░ ░      ░░ ░ ▒  ░ ░ ░  ░ ░ ▒  ▒ 
     ░ ░   ░  ░  ░░ ░  ░         ░░    ░   ░ ░      ░    ░ ░  ░ 
           ░  ░  ░  ░              ░       ░  ░   ░  ░   ░    

EOF
echo -e "\e[0m"
figlet HITMILER | lolcat
echo -e "\n🔍 Loading Bluetooth Blocker Tool..."
sleep 2

# Enable Bluetooth
rfkill unblock bluetooth
systemctl start bluetooth

echo -e "\n📡 Scanning for Bluetooth devices... (Wait 10 seconds)\n"
bluetoothctl scan on &>/dev/null &
sleep 10
bluetoothctl scan off &>/dev/null

# List paired devices
echo -e "📱 Connected Devices:\n"
bluetoothctl devices | tee devices.txt

echo -e "\n🛡️  Enter the MAC address of the device you want to block:"
read -p "➡️  MAC Address: " mac

# Confirm before blocking
read -p "Are you sure you want to BLOCK this device? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo -e "❌ Aborted."
    exit 1
fi

# Block device using bluetoothctl
bluetoothctl block $mac
echo -e "✅ Device [$mac] Blocked Successfully!"

# Optional: Also remove it from trusted/paired list
bluetoothctl remove $mac

# Log the blocked MAC
echo "$(date): Blocked MAC - $mac" >> ~/hitmiler_blocked.log

# Exit message
echo -e "\n🔒 Device has been blocked and logged. Exiting...\n"
