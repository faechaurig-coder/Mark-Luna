"""
Clap detector — wakes JARVIS (or interrupts it) when the user claps their hands.

Works only on the PCM stream the main loop already captures (16 kHz int16 mono).
A clap is a broadband, short transient: the ratio between a chunk's peak and the
ambient level is much more reliable than either alone.
"""
from __future__ import annotations

import time
from typing import Union

import numpy as np

_CHUNK_MS = 64.0          # CHUNK_SIZE=1024 samples @ 16 kHz
_HISTORY_CHUNKS = 30      # ~2 s of ambient history
_DEBOUNCE_S = 1.5         # minimum gap between clap events
_QUIET_MS = 300           # ambience before the clap must stay quiet

# sensitivity presets: (peak_floor, peak/baseline ratio)
_PRESETS = {
    1: (0.30, 3.0),   # light / far mics
    2: (0.40, 4.0),   # default
    3: (0.55, 5.0),   # strict / noisy rooms
}


class ClapDetector:
    """Feeds audio chunks and decides whether a hand clap happened.

    Pure and dependency-free apart from numpy — safe to call from the
    sounddevice callback thread.
    """

    def __init__(self, sensitivity: int = 2):
        self._floor, self._ratio = _PRESETS.get(sensitivity, _PRESETS[2])
        self._history: list[float] = []
        self._last_fire = 0.0

    def feed(self, samples: Union[bytes, np.ndarray]) -> bool:
        """Feed one chunk of 16 kHz int16 mono PCM. Returns True on a clap."""
        if isinstance(samples, bytes):
            samples = np.frombuffer(samples, dtype=np.int16)
        elif samples.dtype != np.int16:
            samples = np.asarray(samples, dtype=np.int16)
        if samples.size == 0:
            return False

        # int32 avoids abs() overflow on the -32768 corner value
        peak = float(np.max(np.abs(samples.astype(np.int32)))) / 32768.0

        # Ambience baseline: average peak of the recent rolling window.
        baseline = float(np.mean(self._history)) if self._history else 0.0
        self._history.append(peak)
        if len(self._history) > _HISTORY_CHUNKS:
            self._history.pop(0)

        now = time.monotonic()
        is_clap = (
            peak >= self._floor
            and (baseline <= 1e-6 or peak / max(baseline, 1e-6) >= self._ratio)
            and now - self._last_fire > _DEBOUNCE_S
        )
        if is_clap:
            self._last_fire = now
        return is_clap
