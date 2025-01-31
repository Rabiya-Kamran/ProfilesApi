#!/usr/bin/env bash

set -e

PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

# Navigate to the project directory
cd $PROJECT_BASE_PATH

# Pull latest changes from git
git pull

# Activate virtual environment and run migrations
source $PROJECT_BASE_PATH/env/bin/activate
python manage.py migrate
python manage.py collectstatic --noinput

# Kill the running process if it exists (replace with your app's process name or script)
pkill -f 'manage.py runserver' || true  # or any other name that matches the running process

# Start the application in the background
nohup python manage.py runserver 0.0.0.0:8000 &

echo "DONE! :)"
