#!/bin/sh

set -e

echo "===> Setting up Ansible on local machine"

# Check for root (or sudo)
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        echo "Re-running with sudo..."
        exec sudo sh "$0" "$@"
    else
        echo "ERROR: This script must be run as root."
        exit 1
    fi
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS="$ID"
else
    OS="$(uname -s)"
fi

install_ansible_apt() {
    echo "Installing Ansible using apt..."
    apt update
    apt install -y ansible
}

install_ansible_dnf() {
    echo "Installing Ansible using dnf..."
    dnf install -y ansible
}

install_ansible_yum() {
    echo "Installing Ansible using yum..."
    yum install -y epel-release
    yum install -y ansible
}

install_ansible_pacman() {
    echo "Installing Ansible using pacman..."
    pacman -Sy --noconfirm ansible
}

case "$OS" in
    ubuntu|debian)
        install_ansible_apt
        ;;
    fedora)
        install_ansible_dnf
        ;;
    centos|rhel)
        install_ansible_yum
        ;;
    arch)
        install_ansible_pacman
        ;;
    *)
        echo "WARNING: Unsupported OS ($OS)"
        echo "Please install Ansible manually:"
        echo "https://docs.ansible.com/ansible/latest/installation_guide/"
        exit 1
        ;;
esac

echo "===> Verifying installation"
ansible --version

echo "===> Ansible setup complete"
