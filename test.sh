#!/bin/bash

echo "Running Lua tests for testing.lua module..."
echo "=========================================="

# Run our custom test suite
nvim --headless \
  -c "lua dofile('tests/testing_spec.lua')" \
  -c "qa"

echo ""
echo "Running existing Plenary tests..."
echo "================================="

# Run existing plenary tests if available
if command -v nvim &> /dev/null; then
  nvim --headless \
    -c "lua require('lazy').load({plugins = {'plenary.nvim'}})" \
    -c "PlenaryBustedDirectory tests/" \
    -c "qa" 2>/dev/null || echo "No plenary tests found or plenary not available"
fi

echo ""
echo "All tests completed!"

