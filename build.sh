#!/bin/bash
echo "Building with 64-bit long double (macOS default)..."
mkdir -p bin

# Generate LLVM IR (REMOVED: -m128-long-double)
clang -S -emit-llvm -O3 src/perceptron.c -o src/perceptron.ll

# Native executable (REMOVED: -m128-long-double)
clang -O3 src/perceptron.c -o bin/perceptron

# echo "Running via JIT (lli)..."
# (Skipping lli for now. We will install it later if needed)
# lli src/perceptron.ll 

echo "Build complete! Run: ./run.sh"
