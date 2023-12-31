#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Update the package list
apt-get update

# Install Tor, Apache and PHP
apt-get install -y tor apache2 php libapache2-mod-php

# Set up a hidden service for the website
# This will automatically create a hostname and private_key under /var/lib/tor/hidden_service/
cat > /etc/tor/torrc << EOL
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:80
EOL

# Restart Tor to generate the hostname and set up the hidden service
systemctl restart tor

# Wait for Tor to restart and generate hidden service files
sleep 5

# Display the onion address to the user
if [ -f "/var/lib/tor/hidden_service/hostname" ]; then
  echo "Your onion address is:"
  cat /var/lib/tor/hidden_service/hostname
else
  echo "Failed to create a hidden service. Check Tor configuration and logs."
  exit 2
fi

# Configure Apache to serve your PHP site
# Note: Make sure your PHP website files are in the appropriate directory

# Restart Apache2 to apply the changes
systemctl restart apache2

echo "Installation complete. Your PHP website should now be accessible over the Tor network."
