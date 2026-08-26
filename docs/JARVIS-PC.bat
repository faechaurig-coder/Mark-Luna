@echo off
chcp 65001 >nul
title JARVIS para PC
set "URL=https://faechaurig-coder.github.io/Mark-Luna/"

echo.
echo   ===== JARVIS para PC =====
echo   Instalador con autoarranque
echo.

set "B="
for %%P in (
  "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
  "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
  "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
) do if exist %%P if not defined B set "B=%%~fP"

if defined B (
  echo Navegador encontrado: %B%
  echo.
) else (
  echo No encontre Chrome ni Edge; se abrira con tu navegador habitual.
  echo.
)

echo Creando acceso directo en el escritorio...
if defined B (
  powershell -NoProfile -WindowStyle Hidden -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([IO.Path]::Combine($env:USERPROFILE,'Desktop','JARVIS.lnk')); $s.TargetPath='%B%'; $s.Arguments='--app=%URL%'; $s.Description='JARVIS'; $s.Save()" >nul 2>&1
) else (
  powershell -NoProfile -WindowStyle Hidden -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([IO.Path]::Combine($env:USERPROFILE,'Desktop','JARVIS.lnk')); $s.TargetPath='%URL%'; $s.Description='JARVIS'; $s.Save()" >nul 2>&1
)
echo   [OK] Acceso directo creado.
echo.

choice /C SN /N /M "Quieres que JARVIS arranque solo con Windows? (S/N): "
if errorlevel 2 goto NOAUTORUN
copy "%~f0" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\JARVIS-PC.bat" >nul
echo   [OK] Autoarranque activado.
goto ABRIR
:NOAUTORUN
echo   [OK] Sin autoarranque (puedes activarlo despues re-ejecutando este archivo).
:ABRIR
echo.
echo Abriendo JARVIS...
if defined B (
  start "" "%B%" --app="%URL%"
) else (
  start "" "%URL%"
)
echo.
echo Listo. Para actualizar, toca el boton Actualizar dentro de la app.
echo Tus llaves y ajustes NO se borran con las actualizaciones.
timeout /t 4 >nul
