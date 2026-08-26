@echo off
title JARVIS - Instalador Automatico
color 0B
echo.
echo  =====================================================
echo    J A R V I S  -  Instalacion Automatica para Windows
echo  =====================================================
echo.
cd /d "%~dp0"

REM Paso 1: verificar Python
python --version >nul 2>&1
if errorlevel 1 (
    echo  [X] Python NO esta instalado.
    echo.
    echo  Abriendo la pagina de descarga de Python...
    echo  Instala Python marcando la casilla "Add python.exe to PATH"
    start https://www.python.org/downloads/
    echo.
    echo  Cuando termine de instalarse, CIERRA esta ventana
    echo  y vuelve a ejecutar INSTALAR-JARVIS.bat
    pause
    exit /b 1
)
for /f "tokens=2" %%v in ('python --version') do echo  [OK] Python %%v encontrado

REM Paso 2: crear entorno virtual
if not exist .venv (
    echo  [..] Creando entorno virtual (primera vez, 1 min)...
    python -m venv .venv
)
echo  [OK] Entorno virtual listo

REM Paso 3: instalar dependencias
echo  [..] Instalando dependencias (puede tardar unos minutos)...
.venv\Scripts\pip.exe install --quiet --upgrade pip
.venv\Scripts\pip.exe install --quiet -r requirements.txt
.venv\Scripts\pip.exe install --quiet fastapi "uvicorn[standard]" cryptography websockets python-multipart
echo  [OK] Dependencias instaladas

REM Paso 4: verificar la llave de Gemini
if not exist config mkdir config
if not exist config\api_keys.json (
    echo.
    echo  =====================================================
    echo   FALTA TU LLAVE DE GEMINI (gratis, 1 minuto)
    echo  =====================================================
    echo.
    echo  1. Se abrira Google AI Studio en tu navegador
    echo  2. Inicia sesion con tu cuenta de Google
    echo  3. Click en "Create API key" y copiala
    echo  4. Pegala en el Bloc de notas que se abrira despues
    echo.
    pause
    start https://aistudio.google.com/apikey
    echo { "GEMINI_API_KEY": "PEGA-TU-LLAVE-AQUI" } > config\api_keys.json
    notepad config\api_keys.json
    echo.
    echo  Guarda el archivo (Ctrl+S) y cierra el Bloc de notas.
    pause
)

REM Paso 5: crear icono en el escritorio
if not exist "%USERPROFILE%\Desktop\JARVIS.lnk" (
    echo  [..] Creando icono en el escritorio...
    echo Set WshShell = CreateObject("WScript.Shell") > _mklnk.vbs
    echo Set s = WshShell.CreateShortcut(WshShell.SpecialFolders("Desktop") + "\JARVIS.lnk") >> _mklnk.vbs
    echo s.TargetPath = "%~dp0launch\JARVIS.bat" >> _mklnk.vbs
    echo s.WorkingDirectory = "%~dp0" >> _mklnk.vbs
    echo s.Description = "JARVIS - Tu asistente de voz" >> _mklnk.vbs
    echo s.Save >> _mklnk.vbs
    cscript //nologo _mklnk.vbs
    del _mklnk.vbs
)
echo  [OK] Icono "JARVIS" en tu escritorio

echo.
echo  =====================================================
echo    INSTALACION COMPLETA!
echo  =====================================================
echo.
echo  Desde ahora solo necesitas:
echo.
echo    PC      -  doble click en el icono JARVIS del escritorio
echo    CELULAR -  dentro de JARVIS click "Remote Control",
echo               escanea el QR con tu celular, y toca "Instalar"
echo.
echo  Presiona cualquier tecla para ARRANCAR JARVIS ahora...
pause >nul
call launch\JARVIS.bat
