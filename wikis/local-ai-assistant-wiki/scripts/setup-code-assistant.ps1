# setup-code-assistant.ps1
# This script creates a custom code-focused LLM using Ollama

# Check if Ollama is installed
try {
    $ollamaVersion = ollama --version
    Write-Host "Found Ollama: $ollamaVersion" -ForegroundColor Green
} catch {
    Write-Host "Ollama not found. Please install Ollama first: https://ollama.com/download" -ForegroundColor Red
    exit 1
}

# Create the Modelfile
$modelfileContent = @"
FROM codellama:7b-instruct

# Set a system prompt for code-focused interactions
SYSTEM """
You are an AI coding assistant. Your primary goal is to help with programming tasks by providing clear, concise, and correct code. Focus on writing efficient, readable code that follows best practices for the language in question. Provide explanations when helpful.
"""

# Set parameters for better code generation
PARAMETER temperature 0.1
PARAMETER top_p 0.95
"@

# Write the Modelfile
$modelfileContent | Out-File -FilePath .\Modelfile -Encoding ascii
Write-Host "Created Modelfile" -ForegroundColor Green

# Check if the model already exists and remove it if it does
$modelExists = ollama list | Select-String "code-assistant"
if ($modelExists) {
    Write-Host "Removing existing code-assistant model..." -ForegroundColor Yellow
    ollama rm code-assistant
}

# Create the custom model
Write-Host "Creating custom code-assistant model..." -ForegroundColor Cyan
ollama create code-assistant -f Modelfile

# Test the model
Write-Host "`nTesting the model with a simple prompt..." -ForegroundColor Cyan
Write-Host "Prompt: Write a function to check if a string is a palindrome`n" -ForegroundColor Gray
ollama run code-assistant "Write a function to check if a string is a palindrome"

Write-Host "`nSetup complete! You can now use your code assistant with:" -ForegroundColor Green
Write-Host "ollama run code-assistant 'your coding question here'" -ForegroundColor Cyan