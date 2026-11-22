"""宣伝動画の音（BGM と効果音）を合成する。

    python3 audio.py <きっかけの JSON> <出力の WAV>

きっかけの JSON は render.mjs が書き出す（場面の時刻から効果音の時刻を決めたもの）。
曲も効果音もここで一から合成するので、外部の音源は使っていない。
"""
import json
import sys

import numpy as np
from scipy import signal
from scipy.io import wavfile

SR = 44100
RNG = np.random.default_rng(20261122)


def tt(dur):
    return np.arange(int(dur * SR)) / SR


def note_hz(name):
    """'C5' や 'F#4' を周波数に。"""
    names = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}
    n = names[name[0]]
    rest = name[1:]
    if rest.startswith('#'):
        n += 1
        rest = rest[1:]
    elif rest.startswith('b'):
        n -= 1
        rest = rest[1:]
    midi = 12 * (int(rest) + 1) + n
    return 440.0 * 2 ** ((midi - 69) / 12)


def expdecay(n, tau):
    return np.exp(-np.arange(n) / (tau * SR))


def attack(x, a=0.004):
    k = max(1, int(a * SR))
    x[:k] *= np.linspace(0, 1, k)
    return x


def fade_out(x, d=0.02):
    k = min(len(x), max(1, int(d * SR)))
    x[-k:] *= np.linspace(1, 0, k)
    return x


def noise(dur):
    return RNG.standard_normal(int(dur * SR))


def band(x, lo, hi, order=2):
    b, a = signal.butter(order, [lo / (SR / 2), hi / (SR / 2)], btype='band')
    return signal.lfilter(b, a, x)


def lowpass(x, f, order=2):
    b, a = signal.butter(order, f / (SR / 2), btype='low')
    return signal.lfilter(b, a, x)


def highpass(x, f, order=2):
    b, a = signal.butter(order, f / (SR / 2), btype='high')
    return signal.lfilter(b, a, x)


def norm(x, peak=1.0):
    m = np.max(np.abs(x)) or 1.0
    return x * (peak / m)


# ---------------- 楽器 ----------------

def marimba(f, dur=0.6, amp=1.0):
    t = tt(dur)
    x = (np.sin(2 * np.pi * f * t) * np.exp(-t / 0.28)
         + 0.35 * np.sin(2 * np.pi * f * 3.93 * t) * np.exp(-t / 0.05)
         + 0.12 * np.sin(2 * np.pi * f * 9.2 * t) * np.exp(-t / 0.015))
    return attack(x, 0.002) * amp


def musicbox(f, dur=1.6, amp=1.0):
    t = tt(dur)
    x = (np.sin(2 * np.pi * f * t) * np.exp(-t / 0.7)
         + 0.45 * np.sin(2 * np.pi * f * 2.0 * t) * np.exp(-t / 0.35)
         + 0.22 * np.sin(2 * np.pi * f * 3.98 * t) * np.exp(-t / 0.18)
         + 0.08 * np.sin(2 * np.pi * f * 6.1 * t) * np.exp(-t / 0.06))
    return attack(x, 0.001) * amp


def pluck(f, dur=1.4, amp=1.0, bright=0.6, decay=0.996):
    """Karplus-Strong の弦（琴の代わり）。"""
    n = int(dur * SR)
    N = max(2, int(SR / f))
    exc = RNG.uniform(-1, 1, N)
    exc = lowpass(exc, 1500 + 6000 * bright)
    x = np.zeros(n)
    x[:N] = exc
    a = np.zeros(N + 2)
    a[0] = 1.0
    a[N] = -0.5 * decay
    a[N + 1] = -0.5 * decay
    y = signal.lfilter([1.0], a, x)
    # 爪の当たる音
    y[:200] += 0.4 * np.sin(2 * np.pi * f * 2 * tt(200 / SR)) * np.linspace(1, 0, 200)
    return fade_out(norm(y) * amp, 0.05)


def bass(f, dur=0.5, amp=1.0):
    t = tt(dur)
    x = np.sin(2 * np.pi * f * t) + 0.25 * np.sin(2 * np.pi * 2 * f * t)
    x *= np.exp(-t / 0.35)
    return fade_out(attack(x, 0.008), 0.03) * amp


def pad(freqs, dur, amp=1.0):
    t = tt(dur)
    x = np.zeros_like(t)
    for f in freqs:
        for det in (-0.004, 0.004):
            ph = RNG.uniform(0, 1)
            x += signal.sawtooth(2 * np.pi * f * (1 + det) * t + ph * 2 * np.pi)
    x = lowpass(x, 1100)
    env = np.minimum(1, t / 0.4) * np.minimum(1, (dur - t) / 0.5)
    return x * np.clip(env, 0, 1) * amp / len(freqs)


def shaker(amp=1.0):
    x = highpass(noise(0.07), 6000) * expdecay(int(0.07 * SR), 0.018)
    return attack(x, 0.003) * amp


def clap(amp=1.0):
    x = np.zeros(int(0.18 * SR))
    for k, d in enumerate((0.0, 0.011, 0.022)):
        b = band(noise(0.15), 900, 3500) * expdecay(int(0.15 * SR), 0.03 if k == 2 else 0.008)
        i = int(d * SR)
        x[i:i + len(b)] += b[: len(x) - i]
    return x * amp


def woodblock(f=880, amp=1.0):
    t = tt(0.25)
    x = np.sin(2 * np.pi * f * t) * np.exp(-t / 0.04) + 0.5 * np.sin(2 * np.pi * f * 2.7 * t) * np.exp(-t / 0.02)
    x[:300] += band(noise(300 / SR), 1500, 6000) * 0.5
    return x * amp


# ---------------- 効果音 ----------------

def sfx_tap():
    t = tt(0.05)
    return (np.sin(2 * np.pi * 1800 * t) * np.exp(-t / 0.006) * 0.5
            + band(noise(0.05), 2000, 8000) * np.exp(-t / 0.004) * 0.2)


def sfx_pop(p=0):
    t = tt(0.12)
    f = np.linspace(520, 980, len(t)) * (1 + 0.06 * p)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.035) * 0.7


def sfx_boing():
    t = tt(0.35)
    f = 320 + 260 * (1 - np.exp(-t / 0.05)) + 18 * np.sin(2 * np.pi * 14 * t)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.12) * 0.5


def sfx_coin(den=100):
    size = {1: 20, 5: 22, 10: 23.5, 50: 21, 100: 22.6, 500: 26.5}.get(int(den), 22)
    f0 = 4300 - size * 85
    out = np.zeros(int(0.6 * SR))
    for k, (delay, a) in enumerate(((0.0, 1.0), (0.065, 0.45), (0.11, 0.2))):
        t = tt(0.45)
        x = np.zeros_like(t)
        for ratio, tau, amp in ((1.0, 0.22, 1.0), (2.76, 0.12, 0.6), (5.4, 0.06, 0.25), (8.93, 0.03, 0.07)):
            x += amp * np.sin(2 * np.pi * f0 * ratio * (1 + 0.004 * k) * t) * np.exp(-t / tau)
        x[:220] += band(noise(220 / SR), 3000, 12000) * 0.6
        i = int(delay * SR)
        out[i:i + len(x)] += x[: len(out) - i] * a
    return out * 0.28


def sfx_bill():
    n = int(0.3 * SR)
    t = tt(0.3)
    env = np.sin(np.pi * np.clip(t / 0.3, 0, 1)) ** 1.5
    x = band(noise(0.3), 1200, 7000) * env
    crackle = np.zeros(n)
    idx = RNG.integers(0, n, 30)
    crackle[idx] = RNG.uniform(-1, 1, 30)
    return x * 0.25 + highpass(crackle, 2000) * 0.5


def sfx_register():
    out = np.zeros(int(1.4 * SR))
    drawer = band(noise(0.12), 300, 2500) * expdecay(int(0.12 * SR), 0.03)
    out[: len(drawer)] += drawer * 0.6
    for d, f in ((0.08, 1568.0), (0.2, 2093.0)):
        t = tt(1.1)
        x = (np.sin(2 * np.pi * f * t) * np.exp(-t / 0.45)
             + 0.4 * np.sin(2 * np.pi * f * 2.4 * t) * np.exp(-t / 0.2)
             + 0.2 * np.sin(2 * np.pi * f * 3.9 * t) * np.exp(-t / 0.1))
        i = int(d * SR)
        out[i:i + len(x)] += x * 0.35
    return out


def sfx_rewind():
    t = tt(0.32)
    f = np.linspace(1100, 180, len(t))
    x = signal.sawtooth(2 * np.pi * np.cumsum(f) / SR)
    return lowpass(x, 2500) * np.sin(np.pi * t / 0.32) * 0.18


def sfx_bad():
    out = np.zeros(int(0.7 * SR))
    for d, f in ((0.0, 392.0), (0.18, 311.0)):
        t = tt(0.35)
        x = signal.sawtooth(2 * np.pi * f * t, 0.5) * np.exp(-t / 0.15)
        i = int(d * SR)
        out[i:i + len(x)] += lowpass(x, 1500) * 0.3
    return out


def sfx_good():
    out = np.zeros(int(1.2 * SR))
    for k, n in enumerate(('C6', 'E6', 'G6', 'C7')):
        x = marimba(note_hz(n), 0.6, 0.35)
        i = int(k * 0.07 * SR)
        out[i:i + len(x)] += x
    place(out, sfx_sparkle(0.6) * 0.5, 0.0)
    return out


def sfx_print(dur=1.5):
    n = int(dur * SR)
    t = tt(dur)
    buzz = signal.square(2 * np.pi * 900 * t) * (0.5 + 0.5 * signal.square(2 * np.pi * 28 * t))
    x = lowpass(buzz, 3000) * 0.07
    x += band(noise(dur), 2000, 6000) * 0.022
    x *= np.clip(np.minimum(t / 0.03, (dur - t) / 0.05), 0, 1)
    return x[:n]


def sfx_msg():
    out = np.zeros(int(0.3 * SR))
    for d, n in ((0.0, 'G5'), (0.07, 'C6')):
        t = tt(0.2)
        x = np.sin(2 * np.pi * note_hz(n) * t) * np.exp(-t / 0.05)
        i = int(d * SR)
        out[i:i + len(x)] += x * 0.35
    return out


def sfx_swoosh(dur=0.35):
    t = tt(dur)
    x = noise(dur)
    lo = np.linspace(300, 3000, len(t))
    y = np.zeros_like(x)
    # 区切って帯域を動かす
    seg = 1024
    for i in range(0, len(x), seg):
        f = lo[i]
        y[i:i + seg] = band(x[i:i + seg + 2048], f, min(f * 3, 18000))[:len(y[i:i + seg])]
    return y * np.sin(np.pi * t / dur) ** 2 * 0.25


def sfx_paper(dur=0.38, bright=1.0):
    n = int(dur * SR)
    t = tt(dur)
    env = np.sin(np.pi * np.clip(t / dur, 0, 1)) ** 0.8
    x = band(noise(dur), 900 * bright, 7000) * env * 0.22
    crackle = np.zeros(n)
    k = int(60 * dur / 0.38)
    idx = RNG.integers(0, n, k)
    crackle[idx] = RNG.uniform(-1, 1, k)
    x += highpass(crackle, 1500) * env * 0.7
    return x


def sfx_snip():
    out = np.zeros(int(0.2 * SR))
    for d in (0.0, 0.045):
        b = highpass(noise(0.05), 3000) * expdecay(int(0.05 * SR), 0.006)
        t = tt(0.05)
        b += np.sin(2 * np.pi * 5200 * t) * np.exp(-t / 0.01) * 0.6
        i = int(d * SR)
        out[i:i + len(b)] += b * 0.5
    return out


def sfx_trace(dur=1.0):
    t = tt(dur)
    x = band(noise(dur), 2500, 9000) * 0.05
    x *= 0.6 + 0.4 * np.sin(2 * np.pi * 7 * t)
    return x * np.clip(np.minimum(t / 0.05, (dur - t) / 0.08), 0, 1)


def sfx_sparkle(dur=0.6):
    out = np.zeros(int((dur + 0.6) * SR))
    notes = ('E7', 'G7', 'C8', 'A7', 'D8', 'E8')
    for k, n in enumerate(notes):
        t = tt(0.5)
        x = np.sin(2 * np.pi * note_hz(n) * t) * np.exp(-t / 0.12)
        i = int(k * dur / len(notes) * SR)
        out[i:i + len(x)] += x * 0.16
    return out


PICK_SCALE = ('C5', 'D5', 'E5', 'G5', 'A5', 'C6', 'D6', 'E6', 'G6', 'A6', 'C7', 'D7', 'E7')


def sfx_pick(p=0):
    return musicbox(note_hz(PICK_SCALE[int(p) % len(PICK_SCALE)]), 0.9, 0.38)


def sfx_pick_decoy():
    return musicbox(note_hz('Bb4'), 0.6, 0.3) + musicbox(note_hz('B4'), 0.6, 0.18)


def sfx_unpick():
    t = tt(0.18)
    f = np.linspace(900, 300, len(t))
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.05) * 0.35


def sfx_fanfare():
    out = np.zeros(int(2.0 * SR))
    for k, n in enumerate(('C5', 'E5', 'G5', 'C6', 'E6', 'G6')):
        x = musicbox(note_hz(n), 1.4, 0.32)
        i = int(k * 0.06 * SR)
        out[i:i + len(x)] += x
    place(out, sfx_sparkle(0.6) * 0.6, 0.3)
    return out


def sfx_type():
    t = tt(0.04)
    return (band(noise(0.04), 1500, 6000) * np.exp(-t / 0.005) * 0.25
            + np.sin(2 * np.pi * 220 * t) * np.exp(-t / 0.01) * 0.15)


def sfx_carve(dur=1.0):
    out = np.zeros(int((dur + 0.2) * SR))
    k = int(dur * 28)
    for i in range(k):
        x = sfx_tap() * 0.35
        j = int((i / k) * dur * SR)
        out[j:j + len(x)] += x
    place(out, sfx_swoosh(dur) * 0.5, 0.0)
    return out


def sfx_envelope():
    return sfx_paper(0.3, 1.2) * 0.8


SFX = {
    'tap': lambda c: sfx_tap(),
    'pop': lambda c: sfx_pop(c.get('p', 0)),
    'boing': lambda c: sfx_boing(),
    'coin': lambda c: sfx_coin(c.get('p', 100)),
    'bill': lambda c: sfx_bill(),
    'register': lambda c: sfx_register(),
    'rewind': lambda c: sfx_rewind(),
    'bad': lambda c: sfx_bad(),
    'good': lambda c: sfx_good(),
    'print': lambda c: sfx_print(c.get('dur', 1.5)),
    'msg': lambda c: sfx_msg(),
    'swoosh': lambda c: sfx_swoosh(),
    'slide': lambda c: sfx_swoosh(0.3) * 0.8,
    'envelope': lambda c: sfx_envelope(),
    'pick': lambda c: sfx_pick(c.get('p', 0)),
    'pickDecoy': lambda c: sfx_pick_decoy(),
    'unpick': lambda c: sfx_unpick(),
    'fanfare': lambda c: sfx_fanfare(),
    'type': lambda c: sfx_type(),
    'carve': lambda c: sfx_carve(c.get('dur', 1.0)),
    'fold': lambda c: sfx_paper(0.36, 0.9),
    'unfold': lambda c: sfx_paper(0.42, 1.2),
    'snip': lambda c: sfx_snip(),
    'trace': lambda c: sfx_trace(c.get('dur', 1.0)),
    'sparkle': lambda c: sfx_sparkle(0.6),
}


# ---------------- 曲 ----------------

def place(buf, x, t):
    i = int(t * SR)
    if i >= len(buf) or i + len(x) <= 0:
        return
    if i < 0:
        x = x[-i:]
        i = 0
    j = min(len(buf), i + len(x))
    buf[i:j] += x[: j - i]


def reverb(x, wet=0.18, length=1.1, tau=0.32):
    n = int(length * SR)
    ir = RNG.standard_normal(n) * np.exp(-np.arange(n) / (tau * SR))
    ir = lowpass(ir, 5000)
    ir /= np.sqrt(np.sum(ir ** 2))
    y = signal.fftconvolve(x, ir)[: len(x)]
    return x * (1 - wet) + y * wet


def song_kozeni(dur, end_t):
    """明るいマリンバの曲（F長調、118 BPM）。"""
    bpm = 118
    beat = 60 / bpm
    buf = np.zeros(int((dur + 2) * SR))
    chords = [('F', ['F4', 'A4', 'C5', 'F5'], 'F2'), ('Dm', ['D4', 'F4', 'A4', 'D5'], 'D2'),
              ('Bb', ['Bb3', 'D4', 'F4', 'Bb4'], 'Bb1'), ('C', ['C4', 'E4', 'G4', 'C5'], 'C2')]
    rhythm = [1, 0, 1, 1, 0, 1, 0, 1]
    motif = [0, 2, 3, 1, 2, 3, 2, 1]
    bar = 0
    t = 0.0
    while t < end_t:
        name, tones, root = chords[bar % 4]
        for s in range(8):
            ts = t + s * beat / 2
            if ts >= end_t:
                break
            if rhythm[s]:
                n = tones[motif[(s + bar) % 8]]
                place(buf, marimba(note_hz(n) * 2, 0.5, 0.32), ts)
            place(buf, shaker(0.05 if s % 2 else 0.08), ts)
        for b in range(4):
            tb = t + b * beat
            if tb >= end_t:
                break
            if b in (0, 2):
                place(buf, bass(note_hz(root), beat * 1.6, 0.5), tb)
            if b in (1, 3):
                place(buf, clap(0.12), tb)
        t += 4 * beat
        bar += 1
    buf[int(end_t * SR):] = 0
    # 終わり：F の和音と駆け上がり
    for k, n in enumerate(('F5', 'A5', 'C6', 'F6')):
        place(buf, marimba(note_hz(n), 1.2, 0.3), end_t + k * 0.06)
    place(buf, bass(note_hz('F2'), 2.0, 0.55), end_t)
    place(buf, pad([note_hz(n) for n in ('F3', 'A3', 'C4', 'F4')], max(0.6, dur - end_t), 0.22), end_t)
    return reverb(buf, 0.12)[: int(dur * SR)]


def song_meirobin(dur, end_t):
    """オルゴールの曲（C長調、100 BPM）。"""
    bpm = 100
    beat = 60 / bpm
    buf = np.zeros(int((dur + 2) * SR))
    chords = [(['C5', 'E5', 'G5', 'C6'], 'C3', ['C4', 'E4', 'G4']),
              (['A4', 'C5', 'E5', 'A5'], 'A2', ['A3', 'C4', 'E4']),
              (['F4', 'A4', 'C5', 'F5'], 'F2', ['F3', 'A3', 'C4']),
              (['G4', 'B4', 'D5', 'G5'], 'G2', ['G3', 'B3', 'D4'])]
    arp = [0, 1, 2, 3, 2, 1, 2, 1]
    melody = [['E6', None, 'D6', None, 'C6', None, 'G5', None],
              ['A5', None, 'C6', None, 'E6', None, None, None],
              ['F6', None, 'E6', None, 'C6', None, 'A5', None],
              ['G5', None, 'B5', None, 'D6', None, None, None]]
    bar = 0
    t = 0.0
    while t < end_t:
        tones, root, padc = chords[bar % 4]
        place(buf, pad([note_hz(n) for n in padc], 4 * beat + 0.3, 0.12), t)
        place(buf, bass(note_hz(root), 2 * beat, 0.35), t)
        for s in range(8):
            ts = t + s * beat / 2
            if ts >= end_t:
                break
            place(buf, musicbox(note_hz(tones[arp[s]]), 1.0, 0.16), ts)
            m = melody[bar % 4][s]
            if m and bar >= 1:
                place(buf, musicbox(note_hz(m), 1.4, 0.24), ts)
            if s % 2 == 1:
                place(buf, shaker(0.035), ts)
        t += 4 * beat
        bar += 1
    buf[int(end_t * SR):] = 0
    for k, n in enumerate(('C5', 'G5', 'C6', 'E6', 'G6', 'C7')):
        place(buf, musicbox(note_hz(n), 2.2, 0.22), end_t + k * 0.08)
    place(buf, pad([note_hz(n) for n in ('C4', 'E4', 'G4')], max(0.6, dur - end_t), 0.14), end_t)
    return reverb(buf, 0.2)[: int(dur * SR)]


def song_monkiri(dur, end_t):
    """琴の曲（D の陽音階、84 BPM）。"""
    bpm = 84
    beat = 60 / bpm
    buf = np.zeros(int((dur + 2) * SR))
    scale = ['D4', 'E4', 'G4', 'A4', 'B4', 'D5', 'E5', 'G5', 'A5', 'B5']
    phrases = [
        [5, None, 4, 3, 4, None, None, None, 3, 2, 3, None, 1, None, None, None],
        [3, 4, 5, None, 7, None, 5, None, 4, 3, 2, None, 3, None, None, None],
        [6, None, 5, 4, 5, None, 7, None, 8, None, 7, 5, 4, None, None, None],
        [4, 3, 2, None, 1, None, 2, 3, 0, None, None, None, None, None, None, None],
    ]
    t = 0.0
    k = 0
    while t < end_t:
        ph = phrases[k % 4]
        place(buf, pluck(note_hz('D2'), 4 * beat * 2, 0.28, 0.3, 0.9993), t)
        place(buf, pluck(note_hz('A2'), 4 * beat * 2, 0.16, 0.3, 0.9993), t + 2 * beat)
        place(buf, woodblock(950, 0.22), t)
        place(buf, woodblock(950, 0.12), t + 4 * beat)
        for s, d in enumerate(ph):
            ts = t + s * beat / 2
            if ts >= end_t:
                break
            if d is not None:
                place(buf, pluck(note_hz(scale[d]), 1.6, 0.42, 0.75), ts)
                if s % 4 == 0:
                    place(buf, pluck(note_hz(scale[max(0, d - 2)]), 1.4, 0.18, 0.6), ts + 0.012)
        t += 8 * beat
        k += 1
    buf[int(end_t * SR):] = 0
    # 終わり：かき鳴らして D で止める
    for i, n in enumerate(('D4', 'G4', 'A4', 'D5', 'E5', 'A5', 'D6')):
        place(buf, pluck(note_hz(n), 2.6, 0.32, 0.7), end_t + i * 0.045)
    place(buf, pluck(note_hz('D2'), 3.0, 0.4, 0.3, 0.9995), end_t)
    place(buf, woodblock(950, 0.3), end_t)
    return reverb(buf, 0.22, 1.4, 0.4)[: int(dur * SR)]


SONGS = {'kozeni': song_kozeni, 'meirobin': song_meirobin, 'monkiri': song_monkiri}


def main():
    cue_file, out = sys.argv[1], sys.argv[2]
    spec = json.load(open(cue_file, encoding='utf-8'))
    dur = float(spec['duration'])
    end_t = next((c['t'] for c in spec['cues'] if c['kind'] == 'end'), dur)
    n = int(dur * SR)

    music = SONGS[spec['app']](dur, end_t)
    music = norm(music, 0.32)

    fx = np.zeros(n + SR * 3)
    for c in spec['cues']:
        if c['kind'] == 'end':
            continue
        make = SFX.get(c['kind'])
        if not make:
            print('unknown cue', c['kind'], file=sys.stderr)
            continue
        place(fx, make(c), c['t'])
    fx = reverb(fx[:n], 0.1, 0.6, 0.15)

    mix = music[:n] + fx[:n] * 0.85
    # 最後の0.9秒で消す
    k = int(0.9 * SR)
    mix[-k:] *= np.linspace(1, 0, k) ** 1.5
    mix[: int(0.01 * SR)] *= np.linspace(0, 1, int(0.01 * SR))
    # 音量をそろえ、強いところはなめらかに抑える
    rms = np.sqrt(np.mean(mix ** 2)) or 1
    mix *= 0.12 / rms
    mix = np.tanh(mix * 1.1) / np.tanh(1.1)
    mix = norm(mix, 0.93) if np.max(np.abs(mix)) > 0.93 else mix
    stereo = np.stack([mix, mix], axis=1)
    wavfile.write(out, SR, (stereo * 32767).astype(np.int16))
    print(f'  audio {out}: {dur:.2f}s, rms {20 * np.log10(np.sqrt(np.mean(mix ** 2))):.1f} dBFS')


if __name__ == '__main__':
    main()
