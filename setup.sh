#!/bin/bash

set -e
echo "Setting up environment for Mac Mini AI cluster..."

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install Python and other dependencies
brew install python@3.11 cmake

# Install Miniforge (better for Apple Silicon compatibility)
if ! command -v conda &> /dev/null; then
    echo "Installing Miniforge..."
    brew install --cask miniforge
    
    # Initialize conda
    conda init zsh
    
    # Create a new conda environment
    conda create -n ai-cluster python=3.11 -y
fi

# Activate the conda environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate ai-cluster

# Install Ray and other Python dependencies
pip install "ray[default]" torch torchvision

echo "Basic environment setup complete!"
