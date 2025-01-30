#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/Rabiya-Kamran/ProfilesApi'
PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

# Set system locale (Amazon Linux does not have locale-gen)
echo "Setting system locale..."
sudo localectl set-locale LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Install required dependencies
echo "Installing dependencies..."
sudo dnf update -y
sudo dnf install -y python3 python3-devel python3-pip python3-virtualenv sqlite nginx git

# Create project directory and clone repo
echo "Setting up project..."
sudo mkdir -p $PROJECT_BASE_PATH
sudo git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH

# Set up Python virtual environment
echo "Creating virtual environment..."
python3 -m venv $PROJECT_BASE_PATH/env
source $PROJECT_BASE_PATH/env/bin/activate

# Install project dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r $PROJECT_BASE_PATH/requirements.txt uwsgi==2.0.21

# Run Django migrations
echo "Running migrations..."
$PROJECT_BASE_PATH/env/bin/python $PROJECT_BASE_PATH/manage.py migrate

# Create systemd service for uWSGI
echo "Setting up uWSGI systemd service..."
cat <<EOT | sudo tee /etc/systemd/system/profiles_api.service
[Unit]
Description=Profiles API uWSGI Service
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=$PROJECT_BASE_PATH
Environment="PATH=$PROJECT_BASE_PATH/env/bin"
ExecStart=$PROJECT_BASE_PATH/env/bin/uwsgi --ini $PROJECT_BASE_PATH/deploy/uwsgi.ini

[Install]
WantedBy=multi-user.target
EOT

# Reload systemd to recognize the new service
sudo systemctl daemon-reload
sudo systemctl enable profiles_api
sudo systemctl start profiles_api

# Setup nginx to serve the application
echo "Configuring Nginx..."
sudo cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/conf.d/profiles_api.conf
sudo systemctl restart nginx

echo "Deployment complete! 🎉"
