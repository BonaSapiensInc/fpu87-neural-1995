; 1995: 80387 FPU Perceptron (Linux Syscall-based)
section .data
    w1 DT 0.7
    w2 DT 0.3
    b DT -0.1
section .text
    global _start
_start:
    ; (... FPU stack operations ...)
    FLD1
    FMUL [w1]
    FLD1
    FMUL [w2]
    FADDP ST(1), ST(0)
    FADD [b]
    
    ; (... Result handling omitted ...)
    
    ; Linux 64-bit exit
    FINIT
    MOV eax, 60
    XOR edi, edi
    SYSCALL
