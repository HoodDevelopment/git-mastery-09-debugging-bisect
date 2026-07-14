#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "🚀 Building debugging practice environment with bugs..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if src/ directory already exists
if [ -d "src" ]; then
    echo -e "${YELLOW}⚠️  Warning: Practice environment already exists${NC}"
    read -p "Delete and rebuild? This will reset all practice work. (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting. Run script again when ready to reset."
        exit 1
    fi
    
    echo -e "${BLUE}🧹 Cleaning up existing practice environment...${NC}"
    rm -rf src/
    git reset --hard origin/master 2>/dev/null || git reset --hard HEAD~10 2>/dev/null || true
    git branch | grep -v "^\*" | grep -v "master" | grep -v "main" | xargs -r git branch -D 2>/dev/null || true
    echo -e "${GREEN}✅ Cleanup complete${NC}"
    echo ""
fi

echo -e "${BLUE}📁 Creating project structure...${NC}"
mkdir -p src tests

# Bug hunting scenario - calculator with bug introduced
export GIT_AUTHOR_NAME="Bug Hunter"
export GIT_AUTHOR_EMAIL="hunter@debug.com"
export GIT_COMMITTER_NAME="Bug Hunter"
export GIT_COMMITTER_EMAIL="hunter@debug.com"

# Create 40 commits with a bug introduced partway
for i in {1..40}; do
    export GIT_AUTHOR_DATE="2024-01-$(printf "%02d" $((i/2+1)))T$(printf "%02d" $((i%24))):00:00"
    export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"
    
    # Bug introduced at commit 25
    if [ $i -lt 25 ]; then
        BUG_STATUS="GOOD"
    else
        BUG_STATUS="BAD"
    fi
    
    case $i in
        1)
            cat > src/calc.js << 'EOF'
function add(a, b) {
    return a + b;
}
module.exports = { add };
EOF
            git add src/calc.js
            git commit -m "Add basic calculator"
            ;;
        2-8)
            echo "// Feature $i" >> src/calc.js
            git add src/calc.js
            git commit -m "Calc: Add feature $i"
            ;;
        9)
            cat >> src/calc.js << 'EOF'

function subtract(a, b) {
    return a - b;
}
module.exports = { add, subtract };
EOF
            git add src/calc.js
            git commit -m "Add subtraction"
            ;;
        10-15)
            echo "// Enhancement $i" >> src/calc.js
            git add src/calc.js
            git commit -m "Enhance: Update $i"
            ;;
        16)
            cat >> src/calc.js << 'EOF'

function multiply(a, b) {
    return a * b;
}
module.exports = { add, subtract, multiply };
EOF
            git add src/calc.js
            git commit -m "Add multiplication"
            ;;
        17-24)
            echo "// Improvement $i" >> src/calc.js
            git add src/calc.js
            git commit -m "Improve: Update $i"
            ;;
        25)
            # BUG INTRODUCED HERE!
            cat > src/calc.js << 'EOF'
function add(a, b) {
    return a + b;
}

function subtract(a, b) {
    return a - b;
}

function multiply(a, b) {
    return a * b;
}

function divide(a, b) {
    return a * b; // BUG: Should be a / b
}

module.exports = { add, subtract, multiply, divide };
EOF
            git add src/calc.js
            git commit -m "Add division feature"
            ;;
        26-30)
            echo "// Update $i" >> src/calc.js
            git add src/calc.js
            git commit -m "Update: Feature $i"
            ;;
        31)
            cat > tests/calc.test.js << 'EOF'
const calc = require('../src/calc');
// Tests here
EOF
            git add tests/calc.test.js
            git commit -m "Add tests"
            ;;
        32-36)
            echo "// Test $i" >> tests/calc.test.js
            git add tests/calc.test.js
            git commit -m "Test: Add case $i"
            ;;
        37-39)
            echo "// Polish $i" >> src/calc.js
            git add src/calc.js
            git commit -m "Polish: Refinement $i"
            ;;
        40)
            cat > README.md << 'EOF'
# Calculator Debug Exercise

A bug was introduced in the divide function.
Use git bisect to find it!

The bug: division returns multiplication result.
EOF
            git add README.md
            git commit -m "Add README with bug info"
            ;;
    esac
done

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${BLUE}📊 Created 40 commits with bug at commit 25${NC}"
echo ""
echo "Bug: Division function multiplies instead of dividing"
echo "Use git bisect to find when the bug was introduced!"
echo ""
echo "Next steps:"
echo "  1. Verify: git log --oneline"
echo "  2. Start exercises: open EXERCISES.md"
echo ""
echo "To reset and start over, just run ./build-history.sh again"
