import requests
import json

def query_ollama(prompt, model="code-assistant"):
    """Send a prompt to Ollama and get the response."""
    url = "http://localhost:11434/api/generate"
    data = {
        "model": model,
        "prompt": prompt,
        "stream": False
    }

    response = requests.post(url, json=data)
    return response.json()["response"]

# Test with a simple coding prompt
prompt = "Write a Python function to check if a number is prime."
response = query_ollama(prompt)
print(response)