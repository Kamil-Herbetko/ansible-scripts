# 🛠️ Ansible Workstation & Server Setup

This repository contains a **modular, role-based Ansible configuration** for provisioning:

- personal Linux workstations
- developer environments
- lightweight servers

The focus is on **reproducibility, clarity, and modern tooling**, while avoiding fragile shell hacks and one-off scripts.

---

## ✨ Features

- ✅ Fully role-based Ansible structure
- ✅ Clean separation of concerns
- ✅ Idempotent and repeatable
- ✅ Desktop & server friendly
- ✅ Modern tooling (nix, uv, xonsh, docker, nvm)
- ✅ Per-user configuration support
- ✅ No snap Docker, no magic installers

---

## 📁 Repository Structure

    .
    ├── ansible.cfg
    ├── inventory/
    │   └── hosts.ini
    ├── playbooks/
    │   └── setup.yml
    ├── roles/
    │   ├── base/
    │   ├── docker/
    │   ├── fonts/
    │   ├── git/
    │   ├── gnome_extensions/
    │   ├── nix/
    │   ├── nix_packages/
    │   ├── nvm/
    │   ├── npm_packages/
    │   ├── ssh_hardening/
    │   ├── uv/
    │   ├── xonsh/
    │   ├── ssh_hardening/
    │   ├── ufw/
    │   └── …
    ├── scripts/
    │   ├── setup-ansible-local.sh
    │   └── setup-ansible-remote.sh
    ├── ssh_keys/
    │   └── ansible.pub
    └── README.md

---

## 🧱 Design Principles

### 1. Roles over monolithic playbooks
Each role:
- does one thing
- has clear inputs (defaults / vars)
- can be reused independently

### 2. Explicit over implicit
- No reliance on interactive shells
- No hidden environment assumptions
- Absolute paths when needed
- Dependencies declared explicitly

### 3. Modern toolchain
- **nix** for reproducible packages
- **uv** for Python CLI tooling
- **xonsh** as a modern shell
- **docker** from the official upstream repo

---

## 🚀 Getting Started

### 1️⃣ Bootstrap Ansible (local machine)

    scripts/setup-ansible-local.sh

### 2️⃣ Run the main playbook

    ansible-playbook playbooks/setup.yml

---

## 🧩 Core Roles Overview

### 🔹 base
Common system packages and sane defaults.

### 🔹 git
Installs Git and configures per-user settings:
- name / email
- aliases
- default branch
- optional GPG commit signing

### 🔹 nix
Installs the Nix package manager (multi-user mode).

### 🔹 nix_packages
Installs packages declaratively via Nix.
Depends on: nix

### 🔹 uv
Installs uv, a fast Python package & tool manager.

### 🔹 xonsh
Installs and configures xonsh using uv, including:
- xontribs
- prompt setup
- shell integration
- optional default shell switch

Depends on: uv

### 🔹 nvm
Installs Node Version Manager and sets up Node.js.

### 🔹 npm_packages
Installs global npm packages using nvm.
Depends on: nvm

### 🔹 docker
Installs Docker using the official Docker APT repository.

### 🔹 fonts
Installs Nerd Fonts and Powerline-compatible fonts.

### 🔹 gnome_extensions
Installs GNOME Shell extensions in a headless-safe way.

### 🔹 ssh_hardening
The `ssh_hardening` role secures OpenSSH using safe, modern defaults while avoiding accidental lockouts.

#### Features
- Disables root login
- Disables password authentication
- Enforces key-based access
- Limits brute-force attempts
- Optional user/group allowlists
- Validates configuration before service restart

#### Example configuration

    ssh_allow_users:
      - kamil

    ssh_password_authentication: "no"
    ssh_permit_root_login: "no"

> ⚠️ Always test SSH changes in an existing session before closing it.
---

### 🔥 UFW Firewall

The `ufw` role configures a simple and safe firewall using Uncomplicated Firewall (UFW).

#### Features
- Default deny incoming traffic
- Default allow outgoing traffic
- SSH access allowed by default
- Support for TCP/UDP ports and named services
- Safe ordering to avoid lockout

#### Example configuration

    ufw_allow_ssh: true
    ufw_ssh_port: 22

    ufw_allowed_tcp_ports:
      - 80
      - 443

    ufw_allowed_services:
      - OpenSSH

> ⚠️ Always allow SSH before enabling the firewall on remote systems.


## 🧠 Variables & Configuration

Example host_vars/localhost.yml:

    git_users:
      - name: john
        home: /home/john

    git_user_name: "John Doe"
    git_user_email: "john.doe@example.com"

    git_gpg_sign: true
    git_gpg_key_id: "ABCDEF1234567890"

    docker_users:
      - john

---

## 🔗 Role Dependencies

Dependencies are declared in each role’s meta/main.yml.

- nix_packages → nix
- xonsh → uv
- npm_packages → nvm

---

## ⚠️ Notes

- Some changes require logout/login
- GNOME extensions may require a live session
- GPG signing assumes keys already exist

---

## 📌 Author

Maintained by Kamil Herbetko
