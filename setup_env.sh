#!/bin/bash

echo "🔧 Starting environment setup (macOS/Linux)..."

PYTHON_VERSION=3.11.9
PYENV_ROOT=$(pyenv root 2>/dev/null)

# Check for pyenv
if ! command -v pyenv &> /dev/null; then
    echo "❌ pyenv not found. Please install pyenv:"
    echo "👉 https://github.com/pyenv/pyenv#installation"
    exit 1
fi

# Install Python version if missing
if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
    echo "📥 Installing Python $PYTHON_VERSION with pyenv..."
    pyenv install $PYTHON_VERSION
fi

# Set project-local Python version
echo "📌 Setting Python $PYTHON_VERSION as local version..."
pyenv local $PYTHON_VERSION

# Create venv if it doesn't exist
if [ ! -d "venv" ]; then
    echo "🌱 Creating virtual environment..."
    $PYENV_ROOT/versions/$PYTHON_VERSION/bin/python -m venv venv
else
    echo "✅ Virtual environment already exists."
fi

# Activate and install dependencies
echo "🚀 Activating virtual environment..."
source venv/bin/activate

echo "⬆️  Upgrading pip..."
pip install --upgrade pip

echo "📦 Installing dependencies..."
pip install -r requirements.txt

echo "✅ Setup complete! Use source venv/bin/activate to begin if not activated yet."