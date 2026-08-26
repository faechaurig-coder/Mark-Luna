rem JARVIS launcher — batch for Windows
@echo off
cd /d "%~dp0\.."
if not exist .venv\Scripts\activate.bat (
    python -m venv .venv
    echo Installing dependencies...
    .venv\Scripts\pip.exe install -r requirements.txt --quiet
)
call .venv\Scripts\activate.bat
start "" http://127.0.0.1:8000
python main.py %*
