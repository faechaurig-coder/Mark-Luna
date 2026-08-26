"""
JARVIS phone-control plugin — sends Smart Intents to the paired phone via
the Dashboard websocket. The phone's browser runs the intent (call, SMS,
WhatsApp, app, copy, timer, alarm, flashlight) with the native Android /
iOS UI.
"""
from __future__ import annotations

import json
import time
from typing import ClassVar

PLUGIN = {
    "name": "phone_intent",
    "description": (
        "Send a quick action (intent) to your paired phone: call/SMS/WhatsApp "
        "a contact, open an app or URL, copy text to the phone clipboard, "
        "start/stop timer, set an alarm, turn the flashlight on/off. "
        "Use when the user wants the PHONE to do anything, never use for PC actions."
    ),
    "parameters": {
        "type": "OBJECT",
        "properties": {
            "phone_command": {
                "type": "STRING",
                "description": (
                    "Action to execute on the phone. Forms:\n"
                    "call:+12345678 | sms:+12345678:Hello | wa:+12345678:Hello there | "
                    "app:instagram | url:https://example.com | copy:some text | "
                    "timer:300 | timerstop | alarm:07:30 | flash:on | flash:off"
                ),
            }
        },
        "required": ["phone_command"],
    },
}

_pending: ClassVar[dict[str, dict]] = {}
TICKET_TTL = 20


def _ticket(phone_command: str) -> str:
    code = f"{int(time.time())}:{hex(hash(phone_command) & 0xFFFF)[2:]}"
    _pending[code] = {"command": phone_command, "ts": time.time(), "result": None}
    now = time.time()
    for k in list(_pending):
        if now - _pending[k]["ts"] > TICKET_TTL:
            del _pending[k]
    return code


def ticket_status(code: str) -> dict | None:
    return _pending.pop(code, None)


def run(parameters: dict, player=None, session_memory=None,
        dashboard_push=None) -> str:
    phone_command = (parameters or {}).get("phone_command", "").strip()
    if not phone_command:
        return "I need a command for the phone. Example: call:+573001234567 or timer:600"
    actions = {
        "call", "sms", "wa", "app", "url", "copy",
        "timer", "timerstop", "alarm", "flash",
    }
    kind = phone_command.split(":", 1)[0].lower()
    if kind not in actions:
        return f"Unknown phone action '{kind}'. Valid: {', '.join(sorted(actions))}"
    if kind in {"call", "sms", "wa", "app", "url", "alarm", "timer"} \
            and ":" not in phone_command:
        return f"'{kind}' requires an argument. Example: {kind}:value"

    # dispatch
    done = None
    if dashboard_push is not None:
        try:
            ticket = _ticket(phone_command)
            done = dashboard_push(
                type="phone_intent",
                ticket=ticket,
                command=phone_command
            )
        except Exception as e:
            return f"Sir, couldn't talk to the phone: {e}"

    if done is None:
        if player:
            try:
                player.write_log(
                    f"JARVIS: phone → {phone_command} (queued — connect a phone to run it)"
                )
            except Exception:
                pass
        return (
            f"Queued '{phone_command}' for the phone. Connect the dashboard on "
            "your phone to execute it."
        )
    if player:
        try:
            player.write_log(f"JARVIS: phone → {phone_command}")
        except Exception:
            pass
    return f"Sent to the phone: {phone_command}"
