#!/bin/bash

# Step 1 - Update System Packages
sudo apt update -y

# Step 2 - Create a System User for Prometheus
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus

# Step 3 - Create Directories for Prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

# Step 4 - Download Prometheus and Extract Files
wget https://github.com/prometheus/prometheus/releases/download/v2.43.0/prometheus-2.43.0.linux-amd64.tar.gz
tar vxf prometheus-2.43.0.linux-amd64.tar.gz

# Step 5 - Move the Binary Files & Set Owner
sudo mv prometheus-2.43.0.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-2.43.0.linux-amd64/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Step 6 - Move the Configuration Files & Set Owner
sudo mv prometheus-2.43.0.linux-amd64/consoles /etc/prometheus
sudo mv prometheus-2.43.0.linux-amd64/console_libraries /etc/prometheus
sudo mv prometheus-2.43.0.linux-amd64/prometheus.yml /etc/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Step 7 - Create Prometheus Systemd Service
echo "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file /etc/prometheus/prometheus.yml \\
    --storage.tsdb.path /var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/prometheus.service

# Step 8 - Reload Systemd
sudo systemctl daemon-reload

# Step 9 - Start Prometheus Service
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Step 10 - Allow port 9090 through the firewall
sudo ufw allow 9090/tcp
