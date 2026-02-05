#!/bin/bash

echo "Starting Sri Murugan Finance API Server..."
echo

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo
    echo "IMPORTANT: Please edit .env file with your PostgreSQL credentials!"
    echo "Press Enter to continue after editing .env file..."
    read
fi

# Initialize database with sample data
echo "Initializing database..."
python init_db.py

# Start the server
echo
echo "Starting FastAPI server..."
echo "Server will be available at: http://localhost:8000"
echo "API Documentation: http://localhost:8000/docs"
echo

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000