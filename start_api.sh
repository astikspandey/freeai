#!/bin/bash

# Script to start the Ollama Shell Script Generator API

echo "Starting Ollama Shell Script Generator API..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "Installing dependencies..."
    source venv/bin/activate
    pip install -r requirements.txt
else
    source venv/bin/activate
fi

echo "Starting Flask server on http://0.0.0.0:5000"
python app.py
