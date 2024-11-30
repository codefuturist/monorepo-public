

# Set your variables here
username="{{username}}"
public_key="{{public-key}}"

# Validate required variables
if [ -z "$username" ] || [ -z "$public_key" ]; then
    echo "Error: username and public_key variables must be set"
    exit 1
fi

# Function to get OS type
get_os_type() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/alpine-release ]; then
        echo "alpine"
    else
        uname -s | tr '[:upper:]' '[:lower:]'
    fi
}

# Get OS type
os_type=$(get_os_type)

# Install sudo if not installed
if ! command -v sudo >/dev/null 2>&1; then
    case "$os_type" in
        "alpine")
            apk add --no-cache sudo || {
                echo "Error: Failed to install sudo"
                exit 1
            }
            ;;
        "ubuntu"|"debian")
            apt-get update && apt-get install -y sudo || {
                echo "Error: Failed to install sudo"
                exit 1
            }
            ;;
        "centos"|"rhel"|"fedora")
            yum install -y sudo || {
                echo "Error: Failed to install sudo"
                exit 1
            }
            ;;
        *)
            echo "Error: Cannot install sudo on this OS"
            exit 1
            ;;
    esac
fi

# Create user if it doesn't exist
if ! id "$username" >/dev/null 2>&1; then
    case "$os_type" in
        "alpine")
            adduser -D "$username" || {
                echo "Error: Failed to create user"
                exit 1
            }
            ;;
        *)
            useradd -m -s /bin/bash "$username" || {
                echo "Error: Failed to create user"
                exit 1
            }
            ;;
    esac
else
    echo "User '$username' already exists."
fi

# Determine sudo group
if getent group sudo >/dev/null; then
    sudo_group="sudo"
elif getent group wheel >/dev/null; then
    sudo_group="wheel"
else
    sudo_group=""
fi

# Add user to sudo group
if [ -n "$sudo_group" ]; then
    if [ "$os_type" = "alpine" ]; then
        adduser "$username" "$sudo_group" || {
            echo "Error: Failed to add user to $sudo_group group"
            exit 1
        }
    else
        usermod -aG "$sudo_group" "$username" || {
            echo "Error: Failed to add user to $sudo_group group"
            exit 1
        }
    fi
else
    echo "Warning: No sudo group found."
fi

# Setup SSH directory and keys
ssh_dir="/home/$username/.ssh"
authorized_keys="$ssh_dir/authorized_keys"

mkdir -p "$ssh_dir" || {
    echo "Error: Failed to create SSH directory"
    exit 1
}

# Add public key
if grep -qF "$public_key" "$authorized_keys" 2>/dev/null; then
    echo "Public key already exists in authorized_keys."
else
    echo "$public_key" >> "$authorized_keys" || {
        echo "Error: Failed to add public key"
        exit 1
    }
fi

# Set correct ownership and permissions
chown -R "$username:$username" "$ssh_dir" || {
    echo "Error: Failed to set ownership"
    exit 1
}
chmod 700 "$ssh_dir"
chmod 600 "$authorized_keys"

# Optionally set a password (uncomment to enable)
# echo "$username:your_password" | chpasswd

echo "=== SSH Key Check ==="
if [ -f "$authorized_keys" ]; then
    echo "File exists: Yes"
else
    echo "File exists: No"
fi
echo "Permissions: $(stat -c "%a" "$authorized_keys") (should be 600)"
echo "Owner: $(stat -c "%U" "$authorized_keys") (should be $username)"
echo "Content of authorized_keys:"
echo "------------------------"
cat "$authorized_keys"
echo "------------------------"

if grep -F "$public_key" "$authorized_keys" > /dev/null 2>&1; then
    echo "Expected key found: Yes"
else
    echo "Expected key found: No"
fi

# Test if key is valid
if ! ssh-keygen -lf "$authorized_keys" > /dev/null 2>&1; then
    echo "Warning: Key file contains invalid SSH keys"
fi

echo "User setup completed successfully."