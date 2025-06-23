#!/bin/bash

# Setup script for MkDocs pre-commit environment
# This script initializes the pre-commit environment and installs all dependencies

set -e  # Exit on error

echo "🚀 Setting up MkDocs pre-commit environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

print_status "Python version: $(python3 --version)"

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    print_error "pip3 is not installed. Please install pip3."
    exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git."
    exit 1
fi

print_status "Git version: $(git --version)"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "This is not a Git repository. Please run 'git init' first."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    print_status "Creating Python virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created."
else
    print_warning "Virtual environment already exists."
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip

# Install requirements
if [ -f "requirements.txt" ]; then
    print_status "Installing Python dependencies from requirements.txt..."
    pip install -r requirements.txt
    print_success "Python dependencies installed."
else
    print_warning "requirements.txt not found. Installing basic dependencies..."
    pip install pre-commit mkdocs mkdocs-material
fi

# Install Node.js dependencies (if package.json exists)
if [ -f "package.json" ] && command -v npm &> /dev/null; then
    print_status "Installing Node.js dependencies..."
    npm install
    print_success "Node.js dependencies installed."
fi

# Install pre-commit hooks
print_status "Installing pre-commit hooks..."
pre-commit install
print_success "Pre-commit hooks installed."

# Install commit-msg hook if it exists in the config
if grep -q "commit-msg" .pre-commit-config.yaml 2>/dev/null; then
    print_status "Installing commit-msg hook..."
    pre-commit install --hook-type commit-msg
fi

# Run pre-commit on all files to check setup
print_status "Running pre-commit on all files to verify setup..."
if pre-commit run --all-files; then
    print_success "Pre-commit setup verification completed successfully!"
else
    print_warning "Pre-commit found some issues. This is normal for initial setup."
    print_status "You can fix issues by running: pre-commit run --all-files"
fi

# Initialize secrets baseline if detect-secrets is configured
if command -v detect-secrets &> /dev/null && [ -f ".pre-commit-config.yaml" ]; then
    if grep -q "detect-secrets" .pre-commit-config.yaml; then
        if [ ! -f ".secrets.baseline" ]; then
            print_status "Initializing secrets baseline..."
            detect-secrets scan --baseline .secrets.baseline
            print_success "Secrets baseline created."
        else
            print_status "Updating secrets baseline..."
            detect-secrets scan --baseline .secrets.baseline --update
        fi
    fi
fi

# Create initial MkDocs build to test configuration
if [ -f "mkdocs.yml" ]; then
    print_status "Testing MkDocs configuration..."
    if mkdocs build --clean --strict; then
        print_success "MkDocs configuration is valid!"
        # Clean up test build
        rm -rf site/
    else
        print_warning "MkDocs configuration has issues. Please check mkdocs.yml"
    fi
fi

# Setup complete
echo ""
print_success "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Activate the virtual environment: source venv/bin/activate"
echo "2. Start developing: mkdocs serve"
echo "3. Make commits - pre-commit will run automatically"
echo ""
echo "Useful commands:"
echo "  mkdocs serve          # Start development server"
echo "  mkdocs build          # Build documentation"
echo "  pre-commit run        # Run hooks manually"
echo "  pre-commit run --all-files  # Run on all files"
echo ""
print_status "Happy documenting! 📚"
