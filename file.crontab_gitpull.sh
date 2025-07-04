#!/bin/bash

#source conf

cd /home/django/pp || exit 1

# Fetch latest commits without merging
git fetch origin main

# Compare local HEAD with remote
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)  # or whatever your branch is

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Repository has updates. Pulling changes..."
git stash
git pull origin main
git stash pop  # Apply your changes again after pulling
    echo "Running collectstatic..."
    chmod +x /home/django/pp/manage.py
    chown -R django:www-data /home/django/pp/
    chmod -R 770 /home/django/pp/
    source /home/django/venv/bin/activate
    /home/django/pp/manage.py collectstatic --noinput

    echo "Restarting Gunicorn..."
    sudo systemctl restart gunicorn  # or your specific service
else
    echo "No changes detected."
fi
