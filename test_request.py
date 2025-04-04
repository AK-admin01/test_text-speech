
import requests
import json

# Test complete audio generation
complete_audio_payload = {
    "input": {
        "text": "This is a test of the Kokoro TTS system.",
        "voice": "default",
        "format": "wav",
        "stream": False
    }
}

# Test streaming audio
streaming_audio_payload = {
    "input": {
        "text": "This is a streaming test of the Kokoro TTS system.",
        "voice": "default",
        "format": "mp3",
        "stream": True
    }
}

# Replace with your endpoint URL
ENDPOINT_URL = "https://api.runpod.io/serverless/your-endpoint-id/run"

def test_complete_audio():
    response = requests.post(
        ENDPOINT_URL,
        headers={"Authorization": "Bearer YOUR_API_KEY"},
        json=complete_audio_payload
    )
    result = response.json()
    audio_data = result["output"]["audio"]
    # Save or process audio_data
    print(f"Generation time: {result['output']['metrics']['generation_time']}s")

def test_streaming_audio():
    response = requests.post(
        ENDPOINT_URL,
        headers={"Authorization": "Bearer YOUR_API_KEY"},
        json=streaming_audio_payload,
        stream=True
    )
    # Process streamed audio chunks
    for chunk in response.iter_content(chunk_size=1024):
        # Handle audio chunks
        pass