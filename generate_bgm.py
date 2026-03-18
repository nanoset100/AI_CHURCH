import wave
import math
import struct
import os

sample_rate = 44100
duration = 10.0 # 10 seconds

def generate_chord(freqs, duration, sample_rate):
    num_samples = int(sample_rate * duration)
    audio = []
    for i in range(num_samples):
        t = float(i) / sample_rate
        # generate a chord with an envelope (fade in/out)
        envelope = math.sin(math.pi * t / duration)
        sample = 0
        for f in freqs:
            sample += math.sin(2.0 * math.pi * f * t)
        sample = sample / len(freqs) * envelope * 0.3 # 30% volume
        audio.append(sample)
    return audio

# Frequencies for a soothing CMaj9 chord (C4, E4, G4, B4, D5) -> 261.63, 329.63, 392.00, 493.88, 587.33
freqs = [261.63, 329.63, 392.00, 493.88, 587.33]
audio_data = generate_chord(freqs, duration, sample_rate)

os.makedirs('assets/audio', exist_ok=True)
with wave.open('assets/audio/bgm.wav', 'w') as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(sample_rate)
    for sample in audio_data:
        # 16-bit PCM
        wav_file.writeframes(struct.pack('<h', int(sample * 32767.0)))

print('BGM generated successfully at assets/audio/bgm.wav')
