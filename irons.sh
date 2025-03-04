#!/bin/bash

# Start a new tmux session
tmux new-session -d -s mysession

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Cloning repository..."
git clone --depth 1 https://gitea.com/l657k65jyhjr/ironn

cd ironn || exit

echo "Running setup script..."
./setup.sh

# Wait for the setup process to complete
echo "Setup complete. Activating..."
npm run activate

# Extract the license from the .env file
LICENSE=$(grep "^LICENSE=" .env | cut -d '=' -f2)

echo "Entering license..."
echo "$LICENSE" | npm run activate

echo "Starting the application..."
npm run start

# Open the configuration file
CONFIG_FILE="nkp/config/user.json"
echo "Opening configuration file: $CONFIG_FILE"

# Extract values from .env file
TELEGRAM_BOT_TOKEN=$(grep "^TELEGRAM_BOT_TOKEN=" .env | cut -d '=' -f2)
TELEGRAM_USER_ID=$(grep "^CHATID=" .env | cut -d '=' -f2)
SRC_KEY=$(tr -dc 'a-z' </dev/urandom | head -c 8)

# Write the new configuration
echo "Writing new configuration..."
echo "{
  \"BOT_REDIRECT\": \"https://example.com\",
  \"TELEGRAM_BOT_TOKEN\": \"$TELEGRAM_BOT_TOKEN\",
  \"TELEGRAM_USER_ID\": \"$TELEGRAM_USER_ID\",
  \"CURRENT_PROJECT\": \"office\",
  \"SRC_KEY\": \"$SRC_KEY\",
  \"GATE_KEY\": \"\",
  \"TDS_URL\": \"http://127.0.0.1:5000\",
  \"EXIT_URL\": \"\",
  
  \"ENABLE_PROXY\": false\"CF_WORKER_URL\": \"\",
  \"SALT_KEY\": \"\",,
  \"GLOBAL_AGENT_HTTP_PROXY\": \"\"
}" > $CONFIG_FILE

echo "Restarting application..."
npm run restart

echo "Process completed successfully."
