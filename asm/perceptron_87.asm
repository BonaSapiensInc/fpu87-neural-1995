; asm/perceptron_87.asm - 1995 x87 FPU Perceptron (macOS 64-bit)
; *** FIX: Must be the VERY FIRST line for macho64 ***
DEFAULT REL

section .data
    w1        dt 0.7      ; 80-bit TBYTE
    w2        dt 0.3
    bias      dt -0.1
    
    ; printf format string (macOS)
    fmt       db "Input: (%d, %d) → Output: %.10f (expected %.1f)", 10, 0
    
    ; Test case inputs (as 64-bit integers)
    inputs    dq 0, 0, 0, 1, 1, 0, 1, 1
    expected  dq 0, 0, 0, 1
    
    ; Integer 0 and 1 for FILD instruction
    int_one   dq 1
    int_zero  dq 0

section .text
    ; *** FIX: Add '_' for macOS C ABI ***
    extern _printf
    global _main

; Sigmoid approximation: x / (1 + |x|)
; Expects 'z' in ST(0)
ALIGN 16
sigmoid:
    ; *** FIX: Use nasm syntax (st0) ***
    FLD   st0     ; Stack: z, z
    FABS          ; Stack: |z|, z
    FLD1          ; Stack: 1.0, |z|, z
    FADDP st1, st0  ; Stack: 1.0+|z|, z (pop)
    FDIVP st1, st0  ; Stack: z / (1.0+|z|) (pop)
    RET

_main:
    push  rbp
    mov   rbp, rsp
    
    ; *** FIX: Save Callee-Saved Registers (ABI) ***
    push  rbx
    push  r12
    push  r13
    push  r14
    
    ; *** FIX: Align stack for 16-bytes (rsp is ...xe0 after 4 pushes) ***
    sub   rsp, 16     ; rsp is now ...xd0 (aligned)

    ; Use Callee-Saved Registers for loop
    mov   r12, 4      ; Loop counter (r12)
    mov   rbx, 0      ; Input array index (rbx)
    
    lea   r13, [inputs]   ; Load base address of inputs array (r13)
    lea   r14, [expected] ; Load base address of expected array (r14)

loop_start:
    ; Access array via base register (r13)
    mov   rdi, [r13 + rbx*8]     ; x1 (0 or 1)
    mov   rsi, [r13 + rbx*8 + 8] ; x2 (0 or 1)
    
    ; --- 80-bit FPU operations start ---
    FINIT           ; Initialize FPU

    ; z = (w1 * x1)
    cmp   rdi, 0
    je    load_x1_zero
    FILD  qword [int_one]
    jmp   load_x1_done
load_x1_zero:
    FILD  qword [int_zero]
load_x1_done:
    ; Stack: st0 = x1
    ; *** FIX: Use nasm syntax (st1, st0) ***
    lea   rdi, [w1]
    FLD   TWORD [rdi]  ; Stack: st0=w1, st1=x1
    FMULP st1, st0     ; Stack: st0 = x1 * w1
    
    ; z = z + (w2 * x2)
    cmp   rsi, 0
    je    load_x2_zero
    FILD  qword [int_one]
    jmp   load_x2_done
load_x2_zero:
    FILD  qword [int_zero]
load_x2_done:
    ; Stack: st0=x2, st1=(x1*w1)
    ; *** FIX: Use nasm syntax (st1, st0) ***
    lea   rdi, [w2]
    FLD   TWORD [rdi]  ; Stack: st0=w2, st1=x2, st2=(x1*w1)
    FMULP st1, st0     ; Stack: st0=(x2*w2), st1=(x1*w1)
    
    FADDP st1, st0     ; Stack: st0 = (x1*w1) + (x2*w2)
    
    ; z = z + bias
    ; *** FIX: Use nasm syntax (st1, st0) ***
    lea   rdi, [bias]
    FLD   TWORD [rdi]  ; Stack: st0=bias, st1=(sum)
    FADDP st1, st0     ; Stack: st0 = sum + bias (this is 'z')
    
    ; y = sigmoid(z)
    call  sigmoid     ; Stack: st0 = y
    
    ; --- FPU operations end ---
    
    ; *** FIX: 64-bit ABI (arg4 -> xmm0, arg5 -> xmm1, rax=2) ***
    
    ; 1. Store 'y' (arg4) and load into XMM0
    FSTP  QWORD [rbp-40] ; Convert 80-bit y to 64-bit double
    movq  xmm0, [rbp-40] ; Load y into XMM0
    
    ; 2. Prepare 'expected_y' (arg5)
    mov   r9, rbx
    shr   r9, 1
    shl   r9, 3
    mov   r8, [r14 + r9] ; Load 0 or 1 (use r14)
    
    cmp   r8, 0
    je    load_exp_zero
    fild  qword [int_one]
    jmp   load_exp_done
load_exp_zero:
    fild  qword [int_zero]
load_exp_done:
    
    ; 3. Store 'expected_y' and load into XMM1
    FSTP  QWORD [rbp-48] ; Convert 80-bit expected_y to 64-bit double
    movq  xmm1, [rbp-48] ; Load expected_y into XMM1
    
    ; 4. Set float argument count
    mov   rax, 2                 ; We are using 2 XMM registers (xmm0, xmm1)
    
    ; Arguments for printf:
    lea   rdi, [fmt]
    mov   rsi, [r13 + rbx*8]     ; x1 (use r13)
    mov   rdx, [r13 + rbx*8 + 8] ; x2 (use r13)
    
    call  _printf
    
    add   rbx, 2      ; Increment index (rbx is safe)
    
    ; (64-bit safe loop)
    dec   r12         ; Decrement safe loop counter (r12)
    jnz   loop_start

    ; *** FIX: Restore Callee-Saved Registers (ABI) ***
    add   rsp, 16     ; Deallocate local stack
    pop   r14
    pop   r13
    pop   r12
    pop   rbx
    
    xor   eax, eax
    pop   rbp
    ret
