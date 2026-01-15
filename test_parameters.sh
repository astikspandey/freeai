#!/bin/bash

# Test script to demonstrate the different parameter combinations

API_URL="http://localhost:5000"

echo "Testing Ollama Shell Script Generator API Parameters"
echo "===================================================="
echo ""

# Test 1: Full verbose output (default)
echo "Test 1: Full output with all logs (head=true, nothink=false)"
curl -s "$API_URL/generate?prompt=Hello" -o test1_full.sh
chmod +x test1_full.sh
echo "Generated: test1_full.sh"
echo ""

# Test 2: Output only (no setup logs)
echo "Test 2: Model output only, no setup logs (head=false)"
curl -s "$API_URL/generate?prompt=Hello&head=false" -o test2_output_only.sh
chmod +x test2_output_only.sh
echo "Generated: test2_output_only.sh"
echo ""

# Test 3: Remove think tags
echo "Test 3: Full logs, but remove <think> tags (nothink=true)"
curl -s "$API_URL/generate?prompt=Explain+AI&nothink=true" -o test3_no_think.sh
chmod +x test3_no_think.sh
echo "Generated: test3_no_think.sh"
echo ""

# Test 4: Clean output (no logs, no think tags)
echo "Test 4: Clean output - no logs, no think tags (head=false, nothink=true)"
curl -s "$API_URL/generate?prompt=Explain+AI&head=false&nothink=true" -o test4_clean.sh
chmod +x test4_clean.sh
echo "Generated: test4_clean.sh"
echo ""

echo "All test scripts generated successfully!"
echo ""
echo "Script comparison:"
echo "  test1_full.sh        - Shows everything (default behavior)"
echo "  test2_output_only.sh - Only model response, no setup logs"
echo "  test3_no_think.sh    - Full logs but filters <think></think> tags"
echo "  test4_clean.sh       - Minimal output (just the answer)"
echo ""
echo "Run any of them with: ./test1_full.sh"
