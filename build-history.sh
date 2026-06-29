#!/bin/bash
set -e
echo "🚀 Building debugging practice environment with bugs..."
mkdir -p src
echo "function calculate(a, b) { return a + b; }" > src/calc.js
git add src/calc.js
git commit -m "Add calculator"
echo "function calculate(a, b) { return a - b; } // BUG!" > src/calc.js
git add src/calc.js
git commit -m "Update calculator"
echo "✅ Setup complete! Start with EXERCISES.md"
