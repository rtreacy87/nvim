#!/usr/bin/env python3
import requests
import time
import json

def test_ollama_performance():
    url = "http://127.0.0.1:11434/api/generate"
    
    # Test prompt
    prompt = "Write a Python function to calculate factorial"
    
    payload = {
        "model": "codellama:13b",
        "prompt": prompt,
        "stream": False
    }
    
    print("Testing Ollama performance...")
    start_time = time.time()
    
    try:
        response = requests.post(url, json=payload, timeout=60)
        end_time = time.time()
        
        if response.status_code == 200:
            result = response.json()
            duration = end_time - start_time
            response_length = len(result.get('response', ''))
            tokens_per_second = response_length / duration if duration > 0 else 0
            
            print(f"✅ Success!")
            print(f"⏱️  Duration: {duration:.2f} seconds")
            print(f"📝 Response length: {response_length} characters")
            print(f"🚀 Speed: ~{tokens_per_second:.1f} chars/second")
            print(f"📊 Model: {result.get('model', 'unknown')}")
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
    
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection error: {e}")
        print("Make sure Ollama is running: ollama serve")

if __name__ == "__main__":
    test_ollama_performance()

