
#!/bin/sh

set -e

ANSIBLE_USER="ansible"
SSH_DIR=".ssh"
AUTHORIZED_KEYS="authorized_keys"

# URL to raw public key file (e.g. GitHub raw link)
SSH_KEY_URL="https://raw.githubusercontent.com/Kamil-Herbetko/ansible-scripts/main/ssh_keys/ansible.pub"

echo "===> Preparing remote server for Ansible"

# Root check
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Must be run as root"
    exit 1
fi

# Create ansible user if it does not exist
if ! id "$ANSIBLE_USER" >/dev/null 2>&1; then
    echo "Creating user '$ANSIBLE_USER'"
    useradd -m -s /bin/sh "$ANSIBLE_USER"
else
    echo "User '$ANSIBLE_USER' already exists"
fi

USER_HOME=$(getent passwd "$ANSIBLE_USER" | cut -d: -f6)
SSH_PATH="$USER_HOME/$SSH_DIR"

# Create .ssh directory
mkdir -p "$SSH_PATH"
chmod 700 "$SSH_PATH"
chown "$ANSIBLE_USER":"$ANSIBLE_USER" "$SSH_PATH"

# Download public key
TMP_KEY="/tmp/ansible_key.pub"
echo "Downloading SSH public key"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$SSH_KEY_URL" -o "$TMP_KEY"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$SSH_KEY_URL" -O "$TMP_KEY"
else
    echo "ERROR: curl or wget required"
    exit 1
fi

# Add key if not already present
AUTHORIZED_KEYS_PATH="$SSH_PATH/$AUTHORIZED_KEYS"
touch "$AUTHORIZED_KEYS_PATH"
chmod 600 "$AUTHORIZED_KEYS_PATH"
chown "$ANSIBLE_USER":"$ANSIBLE_USER" "$AUTHORIZED_KEYS_PATH"

if ! grep -qF "$(cat "$TMP_KEY")" "$AUTHORIZED_KEYS_PATH"; then
    echo "Adding SSH key to authorized_keys"
    cat "$TMP_KEY" >> "$AUTHORIZED_KEYS_PATH"
else
    echo "SSH key already present"
fi

rm -f "$TMP_KEY"

# Configure sudo (NOPASSWD)
SUDOERS_FILE="/etc/sudoers.d/ansible"
if [ ! -f "$SUDOERS_FILE" ]; then
    echo "Configuring passwordless sudo for ansible"
    echo "$ANSIBLE_USER ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"
    chmod 440 "$SUDOERS_FILE"
else
    echo "Sudoers file already exists"
fi

echo "===> Remote server ready for Ansible"
