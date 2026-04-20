#!/usr/bin/env bash

# ProxyUltra Quick Installer
# Developed by Houseassassin

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}    ProxyUltra Framework Installer by Houseassassin ${NC}"
echo -e "${BLUE}====================================================${NC}"

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${GREEN}[INFO] Installing git...${NC}"
    sudo apt-get update && sudo apt-get install -y git
fi

# Define install directory
INSTALL_DIR="/opt/pxu"

if [ -d "$INSTALL_DIR" ]; then
    echo -e "${GREEN}[INFO] ProxyUltra already exists in $INSTALL_DIR. Updating...${NC}"
    cd "$INSTALL_DIR"
    sudo git pull
else
    echo -e "${GREEN}[INFO] Cloning ProxyUltra to $INSTALL_DIR...${NC}"
    sudo git clone https://github.com/houseassassin/proxy-ultra.git "$INSTALL_DIR"
fi

# Set permissions
sudo chmod +x "$INSTALL_DIR/bin/pxu"

# Create symlink if possible
sudo ln -sf "$INSTALL_DIR/bin/pxu" /usr/local/bin/pxu || true

echo -e "${GREEN}[SUCCESS] ProxyUltra installed! Starting menu...${NC}"

# Run the menu
cd "$INSTALL_DIR"
sudo ./bin/pxu menu
