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

# Restart Supervisor service and update process
sudo systemctl restart supervisord
sleep 3  # Give it a moment to restart

# Reload Supervisor to apply any changes
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart profiles_api

echo "DONE! :)"
