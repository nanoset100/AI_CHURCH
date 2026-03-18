import os
import requests

api_key = os.environ.get("OPENAI_API_KEY")
if not api_key:
    print("No OPENAI_API_KEY")
    exit(1)

file_path = r"m:\MyProject777\test009AICHURCH\1.mp3"

headers = {
    "Authorization": f"Bearer {api_key}"
}

with open(file_path, "rb") as f:
    files = {
        "file": ("1.mp3", f, "audio/mpeg"),
        "model": (None, "whisper-1")
    }
    
    response = requests.post(
        "https://api.openai.com/v1/audio/transcriptions",
        headers=headers,
        files=files
    )

    if response.status_code == 200:
        print("Transcription:")
        print(response.json()["text"])
    else:
        print("Error:", response.status_code)
        print(response.text)
