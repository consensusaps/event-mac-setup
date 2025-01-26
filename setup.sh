#!/usr/bin/env bash

#!/bin/bash

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root using sudo."
  exit
fi

echo "Starting Mac setup process..."

# Wi-Fi credentials
WIFI_SSID="the-wifi"

# Prompt for the Wi-Fi password
read -sp "Enter the password for Wi-Fi network '$WIFI_SSID': " WIFI_PASSWORD
echo

# Install Xcode Command Line Tools if not already installed
if ! xcode-select -p &> /dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install &> /dev/null

  # Wait until the tools are installed
  until xcode-select -p &> /dev/null; do
    sleep 5
  done

  echo "Xcode Command Line Tools installed."
else
  echo "Xcode Command Line Tools are already installed."
fi

# Accept the Xcode license agreement (required for CLT to work properly)
echo "Accepting Xcode license..."
xcodebuild -license accept

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew is already installed."
fi

# Update Homebrew to ensure it's ready
echo "Updating Homebrew..."
brew update

# Check if Google Chrome is already installed
if [ -d "/Applications/Google Chrome.app" ]; then
  echo "Google Chrome is already installed. Skipping installation."
else
  echo "Google Chrome not found. Installing Google Chrome..."
  brew install --cask google-chrome
fi

# Clear the Dock
echo "Clearing the Dock..."
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
killall Dock

# Prevent the display from shutting off while on power
echo "Setting display to never shut off while on power..."
pmset -c displaysleep 0

# Add Google Chrome to the Dock
echo "Adding Google Chrome to the Dock..."
/usr/bin/defaults write com.apple.dock persistent-apps -array-add \
    '{tile-data={}; tile-type="file-tile"; file-data={_CFURLString="file:///Applications/Google%20Chrome.app/"; _CFURLStringType=15;};}'
killall Dock

# Join Wi-Fi network
echo "Joining Wi-Fi network $WIFI_SSID..."
networksetup -setairportnetwork en0 "$WIFI_SSID" "$WIFI_PASSWORD"
if [ $? -eq 0 ]; then
  echo "Successfully connected to Wi-Fi network $WIFI_SSID."
else
  echo "Failed to connect to Wi-Fi network $WIFI_SSID. Please check the password and try again."
fi

echo "Mac setup is complete!"

