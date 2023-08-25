#!/bin/bash

# V2ray Server Setup Script

# Define Colors
RESET="\e[0m"
BOLD="\e[1m"
YELLOW="\e[93m"
CYAN="\e[96m"

# Stylish Banner
banner() {
  echo -e "${BOLD}${CYAN}"
  cat << "EOF"
███████╗██████╗░███████╗░█████╗░
██╔════╝██╔══██╗╚════██║██╔══██╗
█████╗░░██║░░██║░░░░██╔╝██║░░██║
██╔══╝░░██║░░██║░░██╔╝░██║░░██║
███████╗██████╔╝░██╔╝░░╚█████╔╝
╚══════╝╚═════╝░░╚═╝░░░░╚════╝░
EOF
  echo -e "${RESET}"
  echo ""
}

# Install Dependencies
install_dependencies() {
  echo -e "${YELLOW}Installing required packages...${RESET}"
  sudo apt-get update
  sudo apt-get install -y openssl wget unzip
}

# Generate SSL Certificate
generate_ssl_certificate() {
  echo -e "${YELLOW}Generating SSL certificate...${RESET}"
  sudo openssl req -x509 -newkey rsa:4096 -keyout /etc/v2ray/certs/key.pem -out /etc/v2ray/certs/cert.pem -days 365 -nodes
}

# Configure v2ray
configure_v2ray() {
  config_file="/etc/v2ray/config.json"
  echo -e "${YELLOW}Configuring v2ray...${RESET}"

  read -p "Enter the client UUID: " client_uuid

  cat << EOF | sudo tee $config_file
{
  "inbounds": [
    {
      "port": 443,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$client_uuid",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
            "certificates": [
                {
                    "certificateFile": "/etc/v2ray/certs/cert.pem",
                    "keyFile": "/etc/v2ray/certs/key.pem"
                }
            ]
        }
      }
    }
  ],
  "outbounds": [],
  "routing": {}
}
EOF
}

# Download and Install v2ray
download_install_v2ray() {
  echo -e "${YELLOW}Downloading and installing v2ray...${RESET}"
  latest_release=$(curl -s https://api.github.com/repos/v2fly/v2ray-core/releases/latest | grep "tag_name" | cut -d '"' -f 4)
  wget "https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip"
  unzip v2ray-linux-64.zip
  sudo mv v2ray /usr/local/bin/
  sudo mv v2ctl /usr/local/bin/
}

# Start v2ray Service
start_v2ray_service() {
  echo -e "${YELLOW}Starting v2ray service...${RESET}"
  sudo systemctl start v2ray
  sudo systemctl enable v2ray
}

# Display Completion Message
display_completion_message() {
  echo ""
  echo -e "${BOLD}${CYAN}V2ray server setup completed!${RESET}"
}

# Main Function
main() {
  banner
  install_dependencies
  generate_ssl_certificate
  configure_v2ray
  download_install_v2ray
  start_v2ray_service
  display_completion_message
}

# Execute Main Function
main
