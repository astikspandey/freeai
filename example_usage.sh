#!/bin/bash

# Example script showing how to use the Ollama Shell Script Generator API

API_URL="http://localhost:5000"

echo "Ollama Shell Script Generator API - Example Usage"
echo "=================================================="
echo ""

# Example 1: Simple greeting
echo "Example 1: Generating script for simple greeting..."
curl -s "$API_URL/generate?lang=sh&prompt=Hello!" -o example1_hello.sh
chmod +x example1_hello.sh
echo "Generated: example1_hello.sh"
echo ""

# Example 2: Code generation
echo "Example 2: Generating script to write Python code..."
curl -s "$API_URL/generate?lang=sh&prompt=Write%20a%20Python%20function%20to%20calculate%20factorial" -o example2_factorial.sh
chmod +x example2_factorial.sh
echo "Generated: example2_factorial.sh"
echo ""

# Example 3: Explanation request
echo "Example 3: Generating script to explain a concept..."
curl -s "$API_URL/generate?lang=sh&prompt=Explain%20how%20binary%20search%20works" -o example3_binary_search.sh
chmod +x example3_binary_search.sh
echo "Generated: example3_binary_search.sh"
echo ""

echo "All example scripts generated successfully!"
echo "Run any of them with: ./example1_hello.sh"
echo ""
echo "Note: First run will download the Ollama model (may take several minutes)"
