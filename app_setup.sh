#!/bin/bash

# Clone the repository
git clone git@github.com:howchihlee/webapp.git
cd webapp

# Create virtual environment and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt || { echo "Dependency installation failed"; exit 1; }

# Install Nginx
sudo yum install nginx -y

# Configure Nginx
EC2_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
sudo bash -c "echo \"server {
    listen 80;
    server_name $EC2_PUBLIC_IP;
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}\" > /etc/nginx/conf.d/flask_app.conf"
sudo systemctl reload nginx

# Setup Gunicorn as a systemd service
sudo bash -c "echo \"[Unit]
Description=Gunicorn instance to serve Flask app
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=$(pwd)
Environment=\"PATH=$(pwd)/venv/bin\"
ExecStart=$(pwd)/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 app:app

[Install]
WantedBy=multi-user.target
\" > /etc/systemd/system/flask_app.service"
sudo systemctl daemon-reload
sudo systemctl start flask_app
sudo systemctl enable flask_app