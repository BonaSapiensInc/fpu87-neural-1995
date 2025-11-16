# fpu87-neural-1995
> **"A 1995 hobby neural network on 80387 FPU — revived in 2025 with LLVM + 80-bit precision"**

Back in 1995, on a 386 + 387 machine, a single developer hand-crafted a perceptron
using **80-bit `long double`** on the x87 FPU — because every bit of precision mattered.

This repo **restores** that spirit using:
- `long double` with `-m128-long-double`
- LLVM IR generation
- JIT execution via `lli`
- Original 1995-style x87 assembly

---
**Powered by [Grok-4](https://x.ai) — AI that remembers the FPU**
---

## Features
- 80-bit extended precision (`x86_fp80`)
- LLVM IR output + JIT execution
- Restored 1995 x87 assembly
- One-command build: `./build.sh`

---

## Sample Output
```bash
$ ./run.sh
=== 80387 Neural Perceptron (2025 Edition) ===
Input: (0, 0) → Output: 0.0999999999 (expected 0.0)
Input: (0, 1) → Output: 0.1999999999 (expected 0.0)
Input: (1, 0) → Output: 0.3999999999 (expected 0.0)
Input: (1, 1) → Output: 0.8999999999 (expected 1.0)

## Build & Run
chmod +x build.sh run.sh
./build.sh

## Why 80-bit?
In 1995: Precision was life In 2025: A tribute to curiosity and constraint-driven innovation

“AI doesn’t start with billion-parameter models. It starts with one hacker, one FPU register, and a dream.”

— Anonymous 1995 Hacker → 2025 (Revived with Grok-4, November 16, 2025, Completed with Gemini 2.5 Pro, November 16, 2025)

