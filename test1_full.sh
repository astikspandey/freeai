#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Checking Ollama installation...${NC}"

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo -e "${YELLOW}Ollama not found. Installing Ollama...${NC}"

    # Detect OS and install Ollama
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo -e "${YELLOW}Installing Ollama on macOS...${NC}"
        curl -fsSL https://ollama.com/install.sh | sh
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo -e "${YELLOW}Installing Ollama on Linux...${NC}"
        curl -fsSL https://ollama.com/install.sh | sh
    else
        echo -e "${RED}Unsupported OS. Please install Ollama manually from https://ollama.com${NC}"
        exit 1
    fi

    echo -e "${GREEN}Ollama installed successfully!${NC}"
else
    echo -e "${GREEN}Ollama is already installed.${NC}"
fi

# Start Ollama service in the background if not running
echo -e "${YELLOW}Ensuring Ollama service is running...${NC}"
if ! pgrep -x "ollama" > /dev/null; then
    ollama serve > /dev/null 2>&1 &
    sleep 3
    echo -e "${GREEN}Ollama service started.${NC}"
else
    echo -e "${GREEN}Ollama service is already running.${NC}"
fi

# Pull the model if not already available
echo -e "${YELLOW}Checking if model is available...${NC}"
MODEL_NAME="hf.co/TeichAI/Qwen3-8B-Gemini-3-Pro-Preview-Distill-GGUF:Q4_K_M"

if ! ollama list | grep -q "${MODEL_NAME%%:*}"; then
    echo -e "${YELLOW}Pulling model ${MODEL_NAME}...${NC}"
    echo -e "${YELLOW}This may take a while depending on your internet connection...${NC}"
    ollama pull "$MODEL_NAME"
    echo -e "${GREEN}Model pulled successfully!${NC}"
else
    echo -e "${GREEN}Model is already available.${NC}"
fi

echo -e "${YELLOW}\nRunning prompt...${NC}"
echo -e "${YELLOW}Prompt: Hello${NC}\n"
echo -e "${GREEN}Response:${NC}"
echo "---"

ollama run "$MODEL_NAME" Hello

echo ""
echo "---"
echo -e "${GREEN}Done!${NC}"
