# Ollama Shell Script Generator API

A web API that generates shell scripts to install Ollama and run prompts using the **TeichAI/Qwen3-8B-Gemini-3-Pro-Preview-Distill-GGUF:Q4_K_M** model.

## Features

- Automatically generates shell scripts that:
  - Check and install Ollama if not present
  - Start the Ollama service
  - Pull the specified model if not available
  - Execute your prompt against the model
  - Filter out `<think></think>` tags (optional)
  - Show only model output or full logs (configurable)
- Simple REST API interface
- Cross-platform support (macOS and Linux)

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

### Start the API server

```bash
python app.py
```

The API will start on `http://0.0.0.0:5000`

### API Endpoints

#### GET /

Returns API information and available endpoints.

#### GET /generate

Generates a shell script to run Ollama with your prompt.

**Query Parameters:**
- `prompt` (required): The prompt to send to the model
- `lang` (optional): The script language (default: `sh`)
- `nothink` (optional): If `true`, removes `<think></think>` tags from model output (default: `false`)
- `head` (optional): If `true`, shows all logs; if `false`, shows only model output (default: `true`)

**Examples:**

```bash
# Basic usage with all logs
curl "http://localhost:5000/generate?lang=sh&prompt=Hello!" -o script.sh

# Remove thinking tags from output
curl "http://localhost:5000/generate?prompt=Explain+AI&nothink=true" -o script.sh

# Show only model output (no setup logs)
curl "http://localhost:5000/generate?prompt=Hello&head=false" -o script.sh

# Clean output: no setup logs, no thinking tags
curl "http://localhost:5000/generate?prompt=Explain+AI&nothink=true&head=false" -o script.sh
```

Or in your browser:
```
http://localhost:5000/generate?lang=sh&prompt=Hello!
http://localhost:5000/generate?prompt=Hello&nothink=true&head=false
```

### Running the Generated Script

1. Make the script executable:
```bash
chmod +x script.sh
```

2. Run it:
```bash
./script.sh
```

The script will:
1. Check if Ollama is installed (install if not)
2. Start the Ollama service
3. Pull the model if needed
4. Run your prompt and display the response

## Example Prompts

```bash
# Ask a simple question
curl "http://localhost:5000/generate?prompt=What+is+AI?" -o ai_question.sh

# Generate code
curl "http://localhost:5000/generate?prompt=Write+a+Python+function+to+sort+a+list" -o code_gen.sh

# Get explanations
curl "http://localhost:5000/generate?prompt=Explain+quantum+computing+in+simple+terms" -o quantum.sh
```

## Model Information

This API uses the **TeichAI/Qwen3-8B-Gemini-3-Pro-Preview-Distill-GGUF:Q4_K_M** model from Hugging Face, optimized for efficient inference with Ollama.

## Notes

- First-time model download may take several minutes depending on your internet connection
- The model requires approximately 8GB of disk space
- Ensure you have sufficient RAM to run the model (recommended: 16GB+)
# freeai
