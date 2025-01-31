#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

# TODO: Set to URL of your Git repository
PROJECT_GIT_URL="https://github.com/Rabiya-Kamran/ProfilesApi"
PROJECT_BASE_PATH="/usr/local/apps/profiles-rest-api"

echo "🔹 Installing system dependencies..."
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y gcc gcc-c++ python3-devel make libffi-devel \
                   pcre pcre-devel sqlite nginx git supervisor

# Create project directory if it does not exist
if [ ! -d "$PROJECT_BASE_PATH" ]; then
    echo "📁 Creating project directory..."
    sudo mkdir -p $PROJECT_BASE_PATH
    sudo chown -R ec2-user:ec2-user $PROJECT_BASE_PATH
else
    echo "⚠️ Project directory already exists."
fi

cd $PROJECT_BASE_PATH

# Clone or update the repository
if [ -d "$PROJECT_BASE_PATH/.git" ]; then
    echo "🔄 Repository exists. Pulling latest changes..."
    git reset --hard
    git pull origin main
else
    echo "📥 Cloning repository..."
    git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH
fi

# Set up Python virtual environment
echo "🐍 Setting up Python environment..."
python3 -m venv $PROJECT_BASE_PATH/env
source $PROJECT_BASE_PATH/env/bin/activate

# Upgrade pip and install dependencies
echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r $PROJECT_BASE_PATH/requirements.txt

# Install uWSGI with proper compilation tools
echo "⚙️ Installing uWSGI..."
pip install --no-cache-dir uwsgi==2.0.21

# Run database migrations
echo "🔄 Applying database migrations..."
$PROJECT_BASE_PATH/env/bin/python $PROJECT_BASE_PATH/manage.py migrate

# Setup Supervisor to manage uWSGI process
echo "⚙️ Configuring Supervisor..."
sudo cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisord.d/profiles_api.ini
sudo systemctl enable supervisord
sudo systemctl restart supervisord
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart profiles_api

# Setup Nginx for serving the application
echo "🌍 Configuring Nginx..."
sudo cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/conf.d/profiles_api.conf
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "✅ Deployment complete! 🎉"
