from flask import Flask, request, Response
import shlex

app = Flask(__name__)

DEFAULT_MODEL = "hf.co/TeichAI/Qwen3-8B-Gemini-3-Pro-Preview-Distill-GGUF:Q4_K_M"

def generate_shell_script(prompt, lang="sh", nothink=False, head=True, model=None, ctxfile=None):
    """
    Generates a shell script that:
    1. Checks if Ollama is installed, installs if not
    2. Pulls the specified model if not already available
    3. Runs the prompt against the model
    4. Optionally filters out <think></think> tags
    5. Optionally shows only model output
    6. Optionally reads context from a file
    """

    # Use provided model or default
    model_name = model if model else DEFAULT_MODEL

    # Escape the prompt for safe shell usage
    escaped_prompt = shlex.quote(prompt)

    # Escape context file path if provided
    escaped_ctxfile = shlex.quote(ctxfile) if ctxfile else None

    # Setup section (conditionally shown)
    if head:
        setup_section = f"""# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m' # No Color

echo -e "${{YELLOW}}Checking Ollama installation...${{NC}}"

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo -e "${{YELLOW}}Ollama not found. Installing Ollama...${{NC}}"

    # Detect OS and install Ollama
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo -e "${{YELLOW}}Installing Ollama on macOS...${{NC}}"
        curl -fsSL https://ollama.com/install.sh | sh
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo -e "${{YELLOW}}Installing Ollama on Linux...${{NC}}"
        curl -fsSL https://ollama.com/install.sh | sh
    else
        echo -e "${{RED}}Unsupported OS. Please install Ollama manually from https://ollama.com${{NC}}"
        exit 1
    fi

    echo -e "${{GREEN}}Ollama installed successfully!${{NC}}"
else
    echo -e "${{GREEN}}Ollama is already installed.${{NC}}"
fi

# Start Ollama service in the background if not running
echo -e "${{YELLOW}}Ensuring Ollama service is running...${{NC}}"
if ! pgrep -x "ollama" > /dev/null; then
    ollama serve > /dev/null 2>&1 &
    sleep 3
    echo -e "${{GREEN}}Ollama service started.${{NC}}"
else
    echo -e "${{GREEN}}Ollama service is already running.${{NC}}"
fi

# Pull the model if not already available
echo -e "${{YELLOW}}Checking if model is available...${{NC}}"
MODEL_NAME="{model_name}"

if ! ollama list | grep -q "${{MODEL_NAME%%:*}}"; then
    echo -e "${{YELLOW}}Pulling model ${{MODEL_NAME}}...${{NC}}"
    echo -e "${{YELLOW}}This may take a while depending on your internet connection...${{NC}}"
    ollama pull "$MODEL_NAME"
    echo -e "${{GREEN}}Model pulled successfully!${{NC}}"
else
    echo -e "${{GREEN}}Model is already available.${{NC}}"
fi

echo -e "${{YELLOW}}\\nRunning prompt...${{NC}}"
echo -e "${{YELLOW}}Prompt: {prompt}${{NC}}\\n"
echo -e "${{GREEN}}Response:${{NC}}"
echo "---"
"""
    else:
        setup_section = f"""# Silent setup mode - only show model output
MODEL_NAME="{model_name}"

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
if ! ollama list 2>/dev/null | grep -q "${{MODEL_NAME%%:*}}"; then
    ollama pull "$MODEL_NAME" > /dev/null 2>&1
fi
"""

    # Build the model execution part with optional context file and think tag filtering
    if escaped_ctxfile:
        # Read context file into variable, then combine with prompt
        context_section = f"""# Read context from file
CTX_CONTENT=$(cat {escaped_ctxfile} 2>/dev/null)
FULL_PROMPT="$CTX_CONTENT

{prompt}"
"""
        if nothink:
            execution = context_section + f"""echo "$FULL_PROMPT" | ollama run "$MODEL_NAME" | perl -0777 -pe 's/<think>.*?<\\/think>//gs'"""
        else:
            execution = context_section + f"""echo "$FULL_PROMPT" | ollama run "$MODEL_NAME" """
    else:
        if nothink:
            execution = f"""ollama run "$MODEL_NAME" {escaped_prompt} | perl -0777 -pe 's/<think>.*?<\\/think>//gs'"""
        else:
            execution = f"""ollama run "$MODEL_NAME" {escaped_prompt}"""

    # Add closing section if head=true
    if head:
        closing = """
echo ""
echo "---"
echo -e "${GREEN}Done!${NC}"
"""
    else:
        closing = ""

    script = f"""#!/bin/bash

{setup_section}
{execution}
{closing}"""

    return script

@app.route('/generate', methods=['GET'])
def generate():
    """
    Endpoint to generate shell scripts for running Ollama with the specified model.

    Query parameters:
    - prompt: The prompt to send to the model (required)
    - lang: The language/format of the script (default: 'sh', currently only 'sh' is supported)
    - nothink: If 'true', filters out <think></think> tags from output (default: 'false')
    - head: If 'true', shows all logs; if 'false', shows only model output (default: 'true')
    - model: Custom Ollama model name to use (default: the HuggingFace Qwen model)
    - ctxfile: Path to a file containing context to prepend to the prompt

    Example: /generate?lang=sh&prompt=Hello!&nothink=true&head=false&model=llama3
    """
    prompt = request.args.get('prompt')
    lang = request.args.get('lang', 'sh')
    nothink = request.args.get('nothink', 'false').lower() == 'true'
    head = request.args.get('head', 'true').lower() == 'true'
    model = request.args.get('model')
    ctxfile = request.args.get('ctxfile')

    if not prompt:
        return {"error": "Missing 'prompt' parameter"}, 400

    if lang != 'sh':
        return {"error": "Only 'sh' (shell script) is currently supported for 'lang' parameter"}, 400

    script = generate_shell_script(prompt, lang, nothink, head, model, ctxfile)

    # Return the script as plain text with proper content type
    return Response(script, mimetype='text/plain', headers={
        'Content-Disposition': 'attachment; filename="ollama_script.sh"'
    })

@app.route('/', methods=['GET'])
def index():
    """
    Root endpoint with API information.
    """
    return {
        "name": "Ollama Shell Script Generator API",
        "default_model": DEFAULT_MODEL,
        "endpoints": {
            "/generate": {
                "method": "GET",
                "parameters": {
                    "prompt": "The prompt to send to the model (required)",
                    "lang": "The language/format (default: 'sh')",
                    "nothink": "If 'true', removes <think></think> tags from output (default: 'false')",
                    "head": "If 'true', shows all logs; if 'false', only model output (default: 'true')",
                    "model": "Custom Ollama model name (default: HuggingFace Qwen model)",
                    "ctxfile": "Path to a file containing context to prepend to the prompt"
                },
                "examples": {
                    "basic": "/generate?lang=sh&prompt=Hello!",
                    "custom_model": "/generate?prompt=Hello&model=llama3",
                    "with_context": "/generate?prompt=Summarize+this&ctxfile=/path/to/context.txt",
                    "no_think_tags": "/generate?prompt=Explain+AI&nothink=true",
                    "output_only": "/generate?prompt=Hello&head=false",
                    "clean_output": "/generate?prompt=Explain+AI&nothink=true&head=false"
                }
            }
        }
    }

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
