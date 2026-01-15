     #!/bin/bash

     # FreeAI CLI Installer
     # Installs the freeai function into ~/.zshrc

     ZSHRC="$HOME/.zshrc"

     FREEAI_FUNC='freeai() {
       local hash message ctx
       hash=$(openssl rand -hex 16)
       ctx="$1"

       # Join args 2..n safely
       message="${(j: :)@:2}"

       echo "Creating file $hash.sh"

       curl -sG "http://localhost:5000/generate" \
         --data-urlencode "lang=sh" \
         --data-urlencode "prompt=$message" \
         --data-urlencode "nothink=true" \
         --data-urlencode "head=false" \
         --data-urlencode "model=qwen2.5:3b" \
         --data-urlencode "ctxfile=$ctx" \
         -o "$hash.sh"

       chmod +x "$hash.sh"
       "./$hash.sh"
       rm -f "$hash.sh"

       echo "Deleting file $hash.sh"
     }'

     echo "========================================"
     echo "       FreeAI CLI Installer"
     echo "========================================"
     echo ""
     echo "This will add the 'freeai' function to your ~/.zshrc"
     echo ""
     echo "Usage after installation:"
     echo "  freeai <context_file> <your prompt>"
     echo ""
     echo "Example:"
     echo "  freeai context.txt How do I print hello world in python"
     echo ""
     echo "----------------------------------------"
     echo ""

     read -p "Do you want to install freeai? [y/N] " response

     if [[ "$response" =~ ^[Yy]$ ]]; then
         # Check if function already exists
         if grep -q "freeai()" "$ZSHRC" 2>/dev/null; then
             echo ""
             read -p "freeai function already exists in ~/.zshrc. Replace it? [y/N] " replace
             if [[ "$replace" =~ ^[Yy]$ ]]; then
                 # Remove existing function
                 sed -i '' '/^freeai() {$/,/^}$/d' "$ZSHRC"
                 echo "$FREEAI_FUNC" >> "$ZSHRC"
                 echo ""
                 echo "freeai function replaced in ~/.zshrc"
             else
                 echo "Installation cancelled."
                 exit 0
             fi
         else
             echo "" >> "$ZSHRC"
             echo "# FreeAI CLI function" >> "$ZSHRC"
             echo "$FREEAI_FUNC" >> "$ZSHRC"
             echo ""
             echo "freeai function added to ~/.zshrc"
         fi

         echo ""
         echo "Run 'source ~/.zshrc' or restart your terminal to use freeai."
         echo ""
         echo "Make sure the FreeAI API server is running:"
         echo "  cd $(pwd) && ./start_api.sh"
     else
         echo ""
         echo "Installation cancelled."
     fi

