# Cloutik Deployment Suite

Welcome to the official deployment repository for **Cloutik**, the MikroTik Fleet Management Solution.
This repository contains the automated scripts required to install, configure, and launch the Cloutik On-Premise Docker stack.

## 📋 Prerequisites

Before running the installation, ensure your server meets the following requirements:

* **OS:** Ubuntu 20.04/22.04/24.04 (Recommended) or Debian 11/12.
* **Permissions:** Root access or a user with `sudo` privileges.
* **Connectivity:** Public IP address with open ports:
    * `80/443` (HTTP/HTTPS for Web Interface)
    * `1194` (OpenVPN for Devices)
    * `5014` (Logstash / Syslog)

## 🚀 Quick Start

To deploy Cloutik on a fresh server, simply clone this repository and run the installer.

```bash
# 1. Clone the repository
git clone https://github.com/valbray/cloutik-deploy.git
cd cloutik-deploy

# 2. Make scripts executable
chmod +x install.sh start.sh update.sh

# 3. Run the Installation Wizard
./install.sh