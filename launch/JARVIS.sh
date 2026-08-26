#!/usr/bin/env bash
# JARVIS launcher — Linux/macOS
cd "$(dirname "$0")/.."
if [ ! -d .venv ]; then
  python3 -m venv .venv
  echo "Instalando dependencias..."
  .venv/bin/pip install -r requirements.txt --quiet
fi
. .venv/bin/activate
python main.py "$@"
