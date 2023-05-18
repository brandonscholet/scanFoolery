#!/bin/bash


# Check if running in an elevated context
if [[ $EUID -ne 0 ]]; then
    echo "This script requires elevated privileges. Please run it as root or using sudo."
    exit 1
fi


# Copy the script to /root directory after making executable
chmod +x checkmate.sh
cp checkmate.sh /root


# Create a systemd service file
SERVICE_FILE="/etc/systemd/system/ssh-logging.service"
cat << EOF > $SERVICE_FILE
[Unit]
Description=SSH Logging Service
After=network.target

[Service]
ExecStart=/root/checkmate.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon and start the service
systemctl daemon-reload
systemctl start ssh-logging.service

# Enable the service to start on boot
systemctl enable ssh-logging.service
