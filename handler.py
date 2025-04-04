
import io
import time
import json
from typing import Dict, Any
from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

app = FastAPI()

class TTSRequest(BaseModel):
    text: str
    voice: str = "default"
    format: str = "wav"
    stream: bool = False

@app.post("/generate")
async def generate_speech(request: Dict[str, Any]):
    """
    RunPod serverless handler for TTS generation
    """
    try:
        # Parse input
        tts_request = TTSRequest(**request.get("input", {}))
        
        # Start timer for cold start metrics
        start_time = time.time()
        
        # Initialize TTS engine (this would be replaced with actual Kokoro initialization)
        # For cold start optimization, we might want to keep this warm
        from app.tts_engine import KokoroTTS
        tts_engine = KokoroTTS.get_instance()
        
        # Generate audio
        if tts_request.stream:
            # Stream the audio as it's being generated
            def audio_stream():
                for chunk in tts_engine.generate_stream(
                    text=tts_request.text,
                    voice=tts_request.voice
                ):
                    yield chunk
            
            return {
                "output": {
                    "audio_stream": audio_stream(),
                    "content_type": f"audio/{tts_request.format}",
                    "metrics": {
                        "generation_time": time.time() - start_time,
                        "cold_start": False  # Would need actual detection
                    }
                }
            }
        else:
            # Generate complete audio file
            audio_data = tts_engine.generate(
                text=tts_request.text,
                voice=tts_request.voice,
                format=tts_request.format
            )
            
            return {
                "output": {
                    "audio": audio_data.decode('latin1'),  # For JSON serialization
                    "content_type": f"audio/{tts_request.format}",
                    "metrics": {
                        "generation_time": time.time() - start_time,
                        "cold_start": False  # Would need actual detection
                    }
                }
            }
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}