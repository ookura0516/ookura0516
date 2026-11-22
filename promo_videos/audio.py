"""動画の背景音と効果音を合成する（録音素材は使わない＝著作権の心配がない）

  python3 audio.py out/<案>_<V|H>.timeline.json out/<案>_<V|H>_bgm.wav

声はあとから mix_voice.py で重ねる。そのため背景音は小さめ（声を邪魔しない音量）に整える。
"""
import json
import sys
import wave

import numpy as np

SR = 48000
RNG = np.random.default_rng(20261122)


def tvec(sec):
    return np.arange(int(SR * sec)) / SR


def add(buf, sig, at, pan=0.0, gain=1.0):
    """buf（2ch）の at 秒の位置に sig（1ch）を足す。pan は -1（左）〜 1（右）"""
    i = int(at * SR)
    if i >= buf.shape[1] or i + len(sig) <= 0:
        return
    if i < 0:
        sig = sig[-i:]
        i = 0
    n = min(len(sig), buf.shape[1] - i)
    lg = gain * np.sqrt((1 - pan) / 2)
    rg = gain * np.sqrt((1 + pan) / 2)
    buf[0, i:i + n] += sig[:n] * lg
    buf[1, i:i + n] += sig[:n] * rg


def lp_fft(x, fc):
    """周波数領域で高い音を落とす（長い信号向け）"""
    n = len(x)
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(n, 1 / SR)
    X *= 1 / np.sqrt(1 + (f / fc) ** 4)
    return np.fft.irfft(X, n)


def hp_fft(x, fc):
    n = len(x)
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(n, 1 / SR)
    X *= 1 - 1 / np.sqrt(1 + (f / fc) ** 4)
    return np.fft.irfft(X, n)


def reverb(buf, sec=1.8, decay=0.55, mix=0.25):
    t = tvec(sec)
    out = np.zeros((2, buf.shape[1] + len(t)))
    for ch in range(2):
        ir = RNG.standard_normal(len(t)) * np.exp(-t / decay)
        ir = lp_fft(ir, 5000)
        ir /= np.sqrt(np.sum(ir ** 2))
        n = buf.shape[1] + len(ir)
        nfft = 1 << (n - 1).bit_length()
        wet = np.fft.irfft(np.fft.rfft(buf[ch], nfft) * np.fft.rfft(ir, nfft), nfft)[:n]
        out[ch, :buf.shape[1]] += buf[ch] * (1 - mix)
        out[ch] += wet * mix
    return out[:, :buf.shape[1]]


# ── オルゴール ──
SEMI = [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24]


def mb_freq(idx):
    return 523.25 * 2 ** (SEMI[idx] / 12)


def mb_note(f, vel=1.0):
    t = tvec(3.0)
    tau = 1.5 * (1000 / f) ** 0.5
    s = np.sin(2 * np.pi * f * t) * np.exp(-t / tau)
    s += 0.30 * np.sin(2 * np.pi * 2.0 * f * t + 0.4) * np.exp(-t / (tau * 0.45))
    s += 0.16 * np.sin(2 * np.pi * 5.43 * f * t) * np.exp(-t / 0.07)
    click = hp_fft(RNG.standard_normal(len(t)) * np.exp(-t / 0.0015), 2500) * 0.35
    s = s + click
    s[: int(SR * 0.0015)] *= np.linspace(0, 1, int(SR * 0.0015))
    return s * vel


def musicbox(tl, buf):
    vel = {'mel': 0.9, 'bass': 0.5, 'tap': 0.95, 'crank': 0.85}
    for c in tl['cues']:
        if c.get('type') != 'note':
            continue
        idx = c['idx']
        add(buf, mb_note(mb_freq(idx), vel.get(c['part'], 0.8)), c['t'], pan=(idx / 14 - 0.5) * 0.7)
    return reverb(buf, 1.6, 0.5, 0.22)


# ── 星（やわらかい和音ときらめき）──
def pad_note(f, sec, amp=1.0):
    t = tvec(sec)
    env = np.minimum(1, t / 1.6) * np.minimum(1, (sec - t) / 1.6)
    s = np.zeros_like(t)
    for det, a in ((1.0, 1.0), (1.003, 0.6), (0.997, 0.6), (2.0, 0.18)):
        s += a * np.sin(2 * np.pi * f * det * t + RNG.uniform(0, 6))
    return s * env * amp


def bell(f, vel=1.0, sec=3.0):
    t = tvec(sec)
    s = np.sin(2 * np.pi * f * t) * np.exp(-t / 1.1)
    s += 0.45 * np.sin(2 * np.pi * f * 2.76 * t) * np.exp(-t / 0.35)
    s += 0.22 * np.sin(2 * np.pi * f * 5.40 * t) * np.exp(-t / 0.12)
    s[: int(SR * 0.003)] *= np.linspace(0, 1, int(SR * 0.003))
    return s * vel


def stars(tl, buf):
    dur = tl['duration']
    chords = [[130.81, 164.81, 196.0, 246.94], [110.0, 130.81, 164.81, 196.0], [87.31, 110.0, 130.81, 164.81], [98.0, 123.47, 146.83, 164.81]]
    t, k = 0.0, 0
    while t < dur:
        for f in chords[k % 4]:
            add(buf, pad_note(f * 2, 5.0, 0.16), t - 0.5, pan=RNG.uniform(-0.4, 0.4))
            add(buf, pad_note(f, 5.0, 0.10), t - 0.5)
        t += 4.0
        k += 1
    penta = [1046.5, 1174.66, 1318.51, 1567.98, 1760.0, 2093.0]
    for c in tl['cues']:
        if c.get('type') == 'chime':
            f = penta[c.get('n', 0) % len(penta)]
            add(buf, bell(f, 0.55), c['t'], pan=RNG.uniform(-0.6, 0.6))
        if c.get('type') == 'sparkle':
            for j in range(4):
                add(buf, bell(penta[(c.get('n', 0) + j * 2) % len(penta)] * 2, 0.18, 1.5), c['t'] + j * 0.07, pan=RNG.uniform(-0.8, 0.8))
    return reverb(buf, 2.6, 0.9, 0.38)


# ── 花火 ──
def boom(size=1.0):
    t = tvec(3.2)
    sweep = np.sin(2 * np.pi * np.cumsum(np.interp(t, [0, 0.35, 3.2], [95, 38, 30])) / SR) * np.exp(-t / 0.55)
    body = lp_fft(RNG.standard_normal(len(t)), 900) * np.exp(-t / 0.35) * 0.7
    tail = lp_fft(RNG.standard_normal(len(t)), 220) * np.exp(-t / 1.6) * 0.9
    s = sweep * 0.9 + body + tail
    s[: int(SR * 0.004)] *= np.linspace(0, 1, int(SR * 0.004))
    return s * size


def crackle(sec=1.6):
    t = tvec(sec)
    s = np.zeros_like(t)
    for _ in range(int(140 * sec)):
        i = RNG.integers(0, len(t) - 200)
        s[i:i + 200] += RNG.standard_normal(200) * np.exp(-np.arange(200) / 25) * RNG.uniform(0.2, 1)
    return hp_fft(s, 1800) * np.exp(-t / (sec * 0.6)) * 0.5


def whistle(sec=0.9):
    t = tvec(sec)
    f = np.interp(t, [0, sec], [700, 1500])
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.minimum(1, t / 0.1) * np.exp(-t / 0.5) * 0.05


def fireworks(tl, buf):
    dur = tl['duration']
    amb = lp_fft(RNG.standard_normal(int(SR * dur) + 10), 300)[: buf.shape[1]]
    amb /= np.max(np.abs(amb)) + 1e-9
    buf[0] += amb * 0.03
    buf[1] += np.roll(amb, 2000) * 0.03
    for f in (73.42, 110.0, 146.83):
        add(buf, pad_note(f, dur + 1, 0.05), -0.5)
    for c in tl['cues']:
        if c.get('type') == 'launch':
            add(buf, whistle(), c['t'], pan=c.get('pan', 0))
        if c.get('type') == 'boom':
            add(buf, boom(c.get('size', 1.0)), c['t'] + 0.35, pan=c.get('pan', 0) * 0.6)
            if c.get('crackle'):
                add(buf, crackle(), c['t'] + 0.5, pan=c.get('pan', 0) * 0.6, gain=0.8)
    return reverb(buf, 2.8, 1.0, 0.3)


# ── すごろく（明るい手拍子とはじく音）──
_PLUCK = {}


def pluck(f, sec=0.9, vel=1.0):
    key = (round(f, 2), sec)
    if key in _PLUCK:
        return _PLUCK[key] * vel
    n = int(SR * sec)
    p = max(2, int(SR / f))
    buf = RNG.uniform(-1, 1, p)
    out = np.empty(n)
    for i in range(n):
        v = buf[i % p]
        out[i] = v
        buf[i % p] = 0.5 * (v + buf[(i + 1) % p]) * 0.996
    _PLUCK[key] = out
    return out * vel


def blip(f0=600, f1=1300, sec=0.12):
    t = tvec(sec)
    f = np.interp(t, [0, sec], [f0, f1])
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.05) * 0.5


def dice(sec=0.8):
    t = tvec(sec)
    s = np.zeros_like(t)
    tt = 0.0
    gap = 0.05
    while tt < sec - 0.05:
        i = int(tt * SR)
        k = np.arange(400)
        s[i:i + 400] += RNG.standard_normal(400) * np.exp(-k / 60) * (1 - tt / sec)
        tt += gap
        gap *= 1.25
    return hp_fft(s, 900) * 0.6


def swoosh(sec=0.35):
    t = tvec(sec)
    return lp_fft(RNG.standard_normal(len(t)), 3000) * np.sin(np.pi * t / sec) * 0.25


def party(tl, buf):
    dur = tl['duration']
    bpm = 116
    e = 60 / bpm / 2  # 8分音符
    C4 = 261.63
    def n(semi): return C4 * 2 ** (semi / 12)
    mel = [4, 7, 9, 7, 4, 2, 0, 2, 4, 7, 9, 12, 9, 7, 4, 7, 9, 12, 14, 12, 9, 7, 9, None, 7, 4, 2, 4, 7, None, 0, None]
    bass = [0, None, 7, None, 9, None, 7, None, 5, None, 0, None, 7, None, 7, None]
    t, k = 0.25, 0
    while t < dur - 0.5:
        m = mel[k % len(mel)]
        if m is not None:
            add(buf, pluck(n(m + 12), 0.7, 0.32), t, pan=0.25)
        if k % 2 == 0:
            b = bass[(k // 2) % len(bass)]
            if b is not None:
                add(buf, pluck(n(b - 12), 1.0, 0.5), t, pan=-0.15)
        if k % 2 == 1:
            add(buf, hp_fft(RNG.standard_normal(1200) * np.exp(-np.arange(1200) / 120), 5000) * 0.12, t, pan=0.4)
        t += e
        k += 1
    for c in tl['cues']:
        ty = c.get('type')
        if ty == 'pop':
            add(buf, blip(500 + 40 * c.get('n', 0), 1100 + 40 * c.get('n', 0)), c['t'], pan=RNG.uniform(-0.5, 0.5), gain=0.8)
        elif ty == 'dice':
            add(buf, dice(), c['t'], gain=1.0)
        elif ty == 'step':
            add(buf, blip(900, 900, 0.06), c['t'], gain=0.6)
        elif ty == 'flip':
            add(buf, swoosh(), c['t'], gain=1.0)
        elif ty == 'ding':
            add(buf, bell(1567.98, 0.5, 2.0), c['t'])
    return reverb(buf, 1.2, 0.35, 0.15)


KINDS = {'musicbox': musicbox, 'stars': stars, 'fireworks': fireworks, 'party': party}


def finish(buf, dur):
    n = buf.shape[1]
    fade_in = int(SR * 0.15)
    fade_out = int(SR * 1.2)
    buf[:, :fade_in] *= np.linspace(0, 1, fade_in)
    buf[:, n - fade_out:] *= np.linspace(1, 0, fade_out)
    rms = np.sqrt(np.mean(buf ** 2)) + 1e-9
    buf *= 10 ** (-21 / 20) / rms  # 声を重ねる前提で小さめ（約 -21dBFS）
    peak = np.max(np.abs(buf))
    if peak > 0.7:
        buf = np.tanh(buf / 0.7) * 0.7
    return buf


def write_wav(path, buf):
    data = (np.clip(buf.T, -1, 1) * 32767).astype('<i2')
    with wave.open(path, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())


def main():
    tl = json.load(open(sys.argv[1], encoding='utf-8'))
    dur = tl['duration']
    buf = np.zeros((2, int(SR * dur)))
    kind = tl.get('audio', {}).get('kind', 'musicbox')
    buf = KINDS[kind](tl, buf)
    buf = finish(buf, dur)
    write_wav(sys.argv[2], buf)
    print(f"{sys.argv[2]}: {dur:.2f}s ({kind})")


if __name__ == '__main__':
    main()
