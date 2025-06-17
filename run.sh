#!/bin/bash

# Start Django development server in the background
echo "Starting Django development server..."
python manage.py runserver &

# Store the Django server's PID
DJANGO_PID=$!

# Start Vite dev server in the background
echo "Starting Vite dev server..."
cd /Users/hanshalgoyal/django_test
npm run dev &

# Store the Vite server's PID
VITE_PID=$!

# Function to clean up background processes on script exit
cleanup() {
    echo "Stopping servers..."
    kill $DJANGO_PID $VITE_PID
    exit 0
}

# Set up trap to catch script termination
# trap cleanup SIGINT SIGTERM

# Keep the script running
wait $DJANGO_PID $VITE_PID
