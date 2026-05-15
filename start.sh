#!/bin/bash
set -e
echo "Linking public storage..."
php artisan storage:link --force || true
echo "Running migrations..."
php artisan migrate --force
echo "Starting server..."
php artisan serve --host=0.0.0.0 --port=$PORT