#!/bin/bash

# Function to detect package manager and install sudo
install_sudo() {
    echo "Checking and installing sudo package..."
    if command -v apt-get &>/dev/null; then
        if ! dpkg -l | grep -q "^ii.*sudo"; then
            apt-get update
            apt-get install -y sudo
        fi
    elif command -v dnf &>/dev/null; then
        if ! rpm -q sudo &>/dev/null; then
            dnf install -y sudo
        fi
    elif command -v yum &>/dev/null; then
        if ! rpm -q sudo &>/dev/null; then
            yum install -y sudo
        fi
    elif command -v zypper &>/dev/null; then
        if ! rpm -q sudo &>/dev/null; then
            zypper install -y sudo
        fi
    elif command -v pacman &>/dev/null; then
        if ! pacman -Q sudo &>/dev/null; then
            pacman -Sy --noconfirm sudo
        fi
    else
        echo "Could not detect package manager. Please install sudo manually."
        exit 1
    fi

    if ! command -v sudo &>/dev/null; then
        echo "Failed to install sudo package"
        exit 1
    fi
}

# Function to check if user exists
check_user_exists() {
    if id "ansible" &>/dev/null; then
        return 0  # User exists
    else
        return 1  # User doesn't exist
    fi
}

# Function to add user with sudo rights
create_ansible_user() {
    echo "Creating ansible user..."
    sudo useradd -m -s /bin/bash ansible || { echo "Failed to create user"; exit 1; }

    # Set random password
    PASS=$(openssl rand -base64 12)
    echo "ansible:$PASS" | sudo chpasswd || { echo "Failed to set password"; exit 1; }

    # Add to sudo group based on distribution
    if [ -f /etc/debian_version ]; then
        sudo usermod -aG sudo ansible
    else
        sudo usermod -aG wheel ansible
    fi

    # Configure sudoers
    echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansible > /dev/null
    sudo chmod 0440 /etc/sudoers.d/ansible
}

# Function to set up SSH
setup_ssh() {
    echo "Setting up SSH directory..."
    sudo mkdir -p /home/ansible/.ssh
    sudo chmod 700 /home/ansible/.ssh
    sudo touch /home/ansible/.ssh/authorized_keys
    sudo chmod 600 /home/ansible/.ssh/authorized_keys

    echo "Enter your public SSH key (or press Enter to skip):"
    read -r ssh_key

    if [ ! -z "$ssh_key" ]; then
        echo "$ssh_key" | sudo tee /home/ansible/.ssh/authorized_keys > /dev/null
        echo "SSH key added successfully"
    else
        echo "No SSH key added"
    fi

    sudo chown -R ansible:ansible /home/ansible/.ssh
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo"
    exit 1
fi

# Main script
echo "Checking and installing sudo package..."
install_sudo

echo "Checking if ansible user exists..."
if check_user_exists; then
    echo "Ansible user already exists"
    read -p "Do you want to proceed with SSH key setup? (y/n): " setup_ssh_answer
    if [[ $setup_ssh_answer =~ ^[Yy]$ ]]; then
        setup_ssh
    fi
else
    echo "Ansible user does not exist"
    read -p "Do you want to create the ansible user? (y/n): " create_user_answer
    if [[ $create_user_answer =~ ^[Yy]$ ]]; then
        create_ansible_user
        read -p "Do you want to set up SSH key? (y/n): " setup_ssh_answer
        if [[ $setup_ssh_answer =~ ^[Yy]$ ]]; then
            setup_ssh
        fi
    else
        echo "Exiting without creating user"
        exit 0
    fi
fi

echo "Script completed successfully"