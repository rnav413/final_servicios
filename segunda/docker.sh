#!/bin/bash

echo "Installing Docker"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker $USER

echo "version: '3.8'

services:
  web:
    build: ./webapp
    container_name: flask_app
    command: flask run --host=0.0.0.0
    volumes:
      - ./webapp:/app
    ports:
      - \"5000:5000\"
    depends_on:
      - db

  db:
    image: mysql:8.0
    container_name: mysql_db
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: mydatabase
    volumes:
      - ./db:/docker-entrypoint-initdb.d
    ports:
      - \"3306:3306\"
    command: --default-authentication-plugin=mysql_native_password" | sudo tee /home/vagrant/docker-compose.yml


echo "FROM python:3.8-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \\
    python3-dev \\
    default-libmysqlclient-dev \\
    build-essential \\
    pkg-config \\
    default-mysql-client \\
    gcc \\
    && apt-get clean

COPY requirements.txt requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV FLASK_APP=run.py

EXPOSE 5000

CMD [\"flask\", \"run\", \"--host=0.0.0.0\"]" | sudo tee /home/vagrant/webapp/Dockerfile


echo "Flask==2.3.3
flask-cors
Flask-MySQLdb
Flask-SQLAlchemy" | sudo tee /home/vagrant/webapp/requirements.txt