#!/usr/bin/env bash

set -e

PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

cd $PROJECT_BASE_PATH
git pull

# Activate virtual environment and run migrations
source $PROJECT_BASE_PATH/env/bin/activate
python manage.py migrate
python manage.py collectstatic --noinput

# Restart Supervisor service
sudo systemctl restart supervisord

echo "DONE! :)"
