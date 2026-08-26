# =====================================================
#  JARVIS - Instalador automatico para Windows
#  Uso: click derecho -> "Ejecutar con PowerShell"
# =====================================================
$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $root) { $root = (Get-Location).Path }
Set-Location $root

function Say($msg, $color = 'Cyan') { Write-Host $msg -ForegroundColor $color }

Clear-Host
Say ""
Say "  =====================================================" Cyan
Say "    J A R V I S  -  Instalacion Automatica" Cyan
Say "  =====================================================" Cyan
Say ""
Say "  Carpeta del proyecto: $root" DarkGray
Say ""

# ── Paso 1: Python ──────────────────────────────────────────────
Say "[1/5] Buscando Python..." White
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) {
    Say "      Python NO esta instalado. Instalando automaticamente..." Yellow
    $wg = Get-Command winget -ErrorAction SilentlyContinue
    if ($wg) {
        winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
        $py = Get-Command python -ErrorAction SilentlyContinue
    }
    if (-not $py) {
        Say "      No se pudo instalar automaticamente." Red
        Say "      1. Se abrira python.org - descarga e instala Python" Yellow
        Say "      2. MARCA la casilla 'Add python.exe to PATH'" Yellow
        Say "      3. Vuelve a ejecutar este instalador" Yellow
        Start-Process 'https://www.python.org/downloads/'
        Read-Host "`nPresiona Enter para salir"
        exit 1
    }
}
$ver = (python --version) 2>&1
Say "      OK: $ver" Green

# ── Paso 2: entorno virtual ─────────────────────────────────────
Say "[2/5] Creando entorno virtual..." White
if (-not (Test-Path "$root\.venv")) {
    python -m venv "$root\.venv"
}
$pybin = "$root\.venv\Scripts\python.exe"
if (-not (Test-Path $pybin)) {
    Say "      ERROR: no se creo el entorno virtual." Red
    Read-Host "`nPresiona Enter para salir"
    exit 1
}
Say "      OK" Green

# ── Paso 3: dependencias ────────────────────────────────────────
Say "[3/5] Instalando dependencias (primera vez tarda 3-5 min)..." White
& $pybin -m pip install --quiet --upgrade pip
& $pybin -m pip install --quiet -r "$root\requirements.txt"
& $pybin -m pip install --quiet fastapi "uvicorn[standard]" cryptography websockets python-multipart
Say "      OK" Green

# ── Paso 4: llave de Gemini ─────────────────────────────────────
Say "[4/5] Verificando llave de Gemini..." White
if (-not (Test-Path "$root\config")) { New-Item -ItemType Directory -Path "$root\config" | Out-Null }
if (-not (Test-Path "$root\config\api_keys.json")) {
    Say ""
    Say "      Necesitas una llave GRATIS de Google Gemini:" Yellow
    Say "      1. Se abrira Google AI Studio en tu navegador" Yellow
    Say "      2. Inicia sesion y click en 'Create API key'" Yellow
    Say "      3. Copia la llave" Yellow
    Say ""
    Start-Process 'https://aistudio.google.com/apikey'
    $key = Read-Host "      Pega tu llave aqui y presiona Enter"
    $key = $key.Trim()
    if ($key.Length -lt 10) {
        Say "      Llave muy corta o vacia. Ejecuta el instalador de nuevo." Red
        Read-Host "`nPresiona Enter para salir"
        exit 1
    }
    "{`"GEMINI_API_KEY`": `"$key`"}" | Set-Content "$root\config\api_keys.json" -Encoding UTF8
}
Say "      OK: llave guardada" Green

# ── Paso 5: icono en el escritorio ──────────────────────────────
Say "[5/5] Creando icono JARVIS en el escritorio..." White
$desktop = [Environment]::GetFolderPath('Desktop')
$Wsh = New-Object -ComObject WScript.Shell
$lnk = $Wsh.CreateShortcut("$desktop\JARVIS.lnk")
$lnk.TargetPath = "$root\launch\JARVIS.bat"
$lnk.WorkingDirectory = $root
$lnk.Description = "JARVIS - Tu asistente de voz"
$lnk.Save()
Say "      OK" Green

Say ""
Say "  =====================================================" Green
Say "    INSTALACION COMPLETA!" Green
Say "  =====================================================" Green
Say ""
Say "  Desde ahora: doble click en el icono JARVIS del escritorio." White
Say "  En el celular: Remote Control -> escanea el QR -> Instalar." White
Say ""
Read-Host "  Presiona Enter para ARRANCAR JARVIS ahora"
& $pybin "$root\main.py"
Read-Host "`nJARVIS se cerro. Presiona Enter para salir"
