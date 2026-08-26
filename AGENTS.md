# Mark-LI — Conocimiento del Proyecto

Asistente de voz tipo JARVIS: bucle principal en `main.py` sobre la **API Gemini Live** (audio nativo), HUD en PyQt6 (`ui.py`), plugins en `plugins/`, herramientas en `actions/`, y panel web remoto en `dashboard/`.

## Comandos

```bash
pip install -r requirements.txt   # deps incompletas por diseño — el instalador autocompleta
python main.py                    # arranque (usa AsyncEventStream asyncio)
python -m py_compile <archivos>   # verificación rápida de sintaxis
```

## Config (`config/api_keys.json`) — claves soportadas

`gemini_api_key`, `assistant_name`, `user_name`, `ui_color`, `voice_name` (Gemini prebuilt), `morning_brief_enabled`, `plugins_enabled`, `clap_activation` (bool, default true), `clap_sensitivity` (1–3, default 2).

## Convenciones

- Python 3.11/3.12. La mayoria de archivos usan fin de línea CRLF (repo Windows-first) — mantenerlos.
- El readme está en **español** — mantener actualizaciones en español.
- Integración de herramientas: declara en `TOOL_DECLARATIONS` (main.py) + despacha en `JarvisLive._execute_tool`.
- Plugins: copiar `plugins/_template.py`; el motor auto-descubre y aísla fallos (muestra "ROTO" si falla).
- Nunca toques el caché de certificados (`config/certs/`) ni keys en `config/api_keys.json` en commits.
- La interfaz `ui.py` es monolítica (3.4k líneas, Qt6, señales para thread-safety). Usa `_<x>_sig.emit()` para tocar la UI desde hilos.

## Mejoras del fork (documentar en readme)

- `core/clap_detector.py` — detector de aplauso puro (numpy, pico/ambiente) integrado en el callback del mic; despierta/interrumpe/desmutea.
- Voz configurable (`voice_name`) — dropdown en overlay Personalizar + lectura en `_build_config`.
- Reminder recurrente (`recurrence` daily/weekly) — schedulers Windows/mac/Linux en `actions/reminder.py`.
- Vuelta de audio al teléfono — endpoint `/ws/assistant-audio` en `dashboard/server.py`, reproductor WebAudio en `dashboard/static/app.html`, espejo de audio desde `main._receive_audio`.

## Señales por descubrir

- Sin tests formales: los chequeos son sintaxis `py_compile` + scripts ad-hoc temporales (borrar después).
- `requirements.txt` es deliberadamente parcial; `core/installer.py` instala la base + paquetes por motor STT/TTS.
- Las voz/TTS del núcleo se usa para no-Gemini pipelines (EdgeTTS/Kokoro/ElevenLabs en `core/tts.py`).
