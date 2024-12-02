#!/bin/bash

# Exit on any error
set -e

# Setup Gunicorn as a systemd service
echo "Setting up Gunicorn service..."
sudo bash -c "cat > /etc/systemd/system/flask_app.service <<EOF
[Unit]
Description=Gunicorn instance to serve Flask app
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=$(pwd)
Environment='PATH=$(pwd)/venv/bin'
ExecStart=$(pwd)/venv/bin/gunicorn -w 4 -b 0.0.0.0:5000 app:app  # Reference to the Flask app in app.py

[Install]
WantedBy=multi-user.target
EOF"

# Reload systemd and start the Gunicorn service
echo "Reloading systemd and starting the Gunicorn service..."
sudo systemctl daemon-reload
sudo systemctl start flask_app
sudo systemctl enable flask_app

echo "Setup complete. Flask app is now running on Gunicorn."
