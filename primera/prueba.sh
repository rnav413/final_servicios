#!/bin/bash

# Variables
HOST_IP="192.168.1.3"
VM_IP="192.168.50.3"

echo "global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'metrica'
    static_configs:
      - targets: ['$HOST_IP:8000']" | sudo tee /etc/prometheus/prometheus.yml

sudo systemctl daemon-reload

sudo systemctl restart prometheus

sudo ufw allow 8000/tcp
