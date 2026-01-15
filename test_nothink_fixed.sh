#!/bin/bash

# Silent setup mode - only show model output
MODEL_NAME="hf.co/TeichAI/Qwen3-8B-Gemini-3-Pro-Preview-Distill-GGUF:Q4_K_M"

# Check and install Ollama if needed
if ! command -v ollama &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        curl -fsSL https://ollama.com/install.sh | sh > /dev/null 2>&1
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -fsSL https://ollama.com/install.sh | sh > /dev/null 2>&1
    fi
fi

# Start Ollama service if not running
if ! pgrep -x "ollama" > /dev/null 2>&1; then
    ollama serve > /dev/null 2>&1 &
    sleep 3
fi

# Pull model if needed
if ! ollama list 2>/dev/null | grep -q "${MODEL_NAME%%:*}"; then
    ollama pull "$MODEL_NAME" > /dev/null 2>&1
fi

ollama run "$MODEL_NAME" Test | perl -0777 -pe 's/<think>.*?<\/think>//gs'
