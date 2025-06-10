@echo off
echo 🔧 Starting environment setup (Windows)...

:: Set Python version
set PYTHON_VERSION=3.11

:: Check for Python
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Python not found! Please install Python %PYTHON_VERSION% from https://www.python.org/downloads/
    exit /b 1
)

:: Create venv
if not exist venv (
    echo 🌱 Creating virtual environment...
    python -m venv venv
) else (
    echo ✅ Virtual environment already exists.
)

:: Activate venv and install packages
call venv\Scripts\activate.bat
echo 📦 Installing dependencies...
python -m pip install --upgrade pip
pip install -r requirements.txt

echo ✅ Setup complete! Use venv\Scripts\activate to begin.
