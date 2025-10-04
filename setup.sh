#!/bin/bash
set -e 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() {
    echo -e "\n${YELLOW}$*${NC}"
}

success() {
    echo -e "${GREEN}✓ $*${NC}\n"
}

error() {
    echo -e "${RED}✗ $*${NC}"
}

GITHUB_REPO="SamiSuhail/ansible_playbooks"  
PLAYBOOK_PATH="ubuntu_dev.yml" 
CLONE_DIR="$HOME/code/ansible_playbooks"
GIT_USERNAME="SamiSuhail"
GIT_EMAIL="sami.suhail.dev@gmail.com"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Ubuntu Dev Environment Setup${NC}"
echo -e "${GREEN}================================${NC}"

while true; do
    if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        success "Internet connection detected"
        break
    else
        error "No internet connection detected"
        echo "Please connect to the internet and press Enter to try again..."
        read
    fi
done

step "Step 1: Installing system updates..."
sudo apt update
sudo apt upgrade -y
sudo apt install -y linux-firmware
sudo ubuntu-drivers autoinstall
success "System updated"

step "Step 2: Installing required packages..."
sudo apt install -y git gh
success "Packages installed"

step "Step 3: Authenticating to GitHub..."
if ! gh auth status &>/dev/null; then
    echo "Please authenticate to GitHub via your browser..."
    gh auth login --web --git-protocol https
    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL"
    success "GitHub authentication complete"
else
    success "Already authenticated to GitHub"
fi

step "Step 4: Cloning Ansible playbook repository..."
if [ -d "$CLONE_DIR" ]; then
    echo "Directory $CLONE_DIR already exists. Removing..."
    rm -rf "$CLONE_DIR"
fi
gh repo clone "$GITHUB_REPO" "$CLONE_DIR"
cd "$CLONE_DIR"
success "Repository cloned to $CLONE_DIR"

step "Step 5: Installing Ansible..."
if ! command -v ansible-playbook &>/dev/null; then
    sudo apt install -y ansible
    success "Ansible installed"
else
    success "Ansible already installed"
fi

step "Step 6: Running Ansible playbook..."
ansible-playbook "$PLAYBOOK_PATH"

step "Step 7: Source dotfiles..."
source ~/.bash_profile
source ~/.bashrc

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo "Your development environment is ready to use."
