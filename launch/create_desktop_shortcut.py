#!/usr/bin/env python3
"""Genera un icono en el escritorio que lanza JARVIS.

Uso: python launch/create_desktop_shortcut.py
Añadir a auto-empaquetado en setup.py o correr una sola vez.
"""
from __future__ import annotations
import os, platform, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

def _windows_shortcut() -> None:
    bat = ROOT / "launch" / "JARVIS.bat"
    icon = """\
Set WshShell = CreateObject("WScript.Shell")
Set oFS = CreateObject("Scripting.FileSystemObject")
deskPath = WshShell.SpecialFolders("Desktop")
Set shortcut = WshShell.CreateShortcut(deskPath & "\\JARVIS.lnk")
shortcut.TargetPath = "{bat}"
shortcut.Description = "JARVIS — Asistente de voz"
shortcut.Save
WScript.Echo "Icono 'JARVIS' creado en el escritorio."
""".format(bat=str(bat))
    tmp = ROOT / "launch" / "_mklnk.vbs"
    tmp.write_text(icon, encoding="utf-8")
    tmp_bat = ROOT / "launch" / "_run_vbs.bat"
    tmp_bat.write_text(
        f'cscript //nologo "{tmp}" && del "{tmp}" && del %0\n',
        encoding="utf-8"
    )
    print(f"[OK] Ejecuta: {tmp_bat}")
    print("      o click DERECHO -> 'Crear acceso directo' hacia launch/JARVIS.bat")

def _posix_shortcut(ce: bool = True) -> None:
    sh = ROOT / "launch" / "JARVIS.sh"
    desktop = Path.home() / "Desktop" / "JARVIS.desktop"
    content = f"""[Desktop Entry]
Type=Application
Name=JARVIS
Comment=Asistente de voz JARVIS
Exec={sh}
Icon={ROOT}/dashboard/static/icon.svg
Terminal=true
Categories=Utility
Path={ROOT}
"""
    try:
        desktop.write_text(content, encoding="utf-8")
        print(f"[OK] {desktop}")
    except FileNotFoundError:
        print("[HINT] No existe ~/Desktop — cópialo manualmente:")
        print(content)

def main() -> None:
    if platform.system() == "Windows":
        _windows_shortcut()
    else:
        _posix_shortcut()

if __name__ == "__main__":
    main()
