#!/bin/bash
echo "Setting up dependencies for CodeSpace..."
sudo apt-get update
echo "Installing tools..."
sudo apt-get install -y gcovr pandoc
echo "Done!"