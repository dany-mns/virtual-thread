BITS 64

section .data
    newline db 0xA
    buffer  times 20 db 0   ; buffer to store converted number (max 20 digits)

section .text
    global _start

; Function: print_number
; Input: RDI = number to print
; Clobbers: RAX, RCX, RDX, RSI
print_number:
    mov rcx, buffer + 20     ; RCX points to the end of buffer
    mov rax, rdi             ; RAX = number

    cmp rax, 0
    jne .convert
    mov byte [rcx - 1], '0'
    lea rsi, [rcx - 1]
    mov rdx, 1
    jmp .print

.convert:
    ; Convert number to ASCII digits in reverse
.next_digit:
    xor rdx, rdx
    mov rbx, 10
    div rbx                  ; RAX /= 10, RDX = RAX % 10
    dec rcx
    add dl, '0'
    mov [rcx], dl
    test rax, rax
    jnz .next_digit

    ; Now RCX points to start of number string
    lea rsi, [rcx]
    mov rdx, buffer + 20
    sub rdx, rcx             ; RDX = length

.print:
    mov rax, 1               ; syscall write
    mov rdi, 1               ; stdout
    syscall

    ; print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ret

counter:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    mov QWORD [rsp + 8], 0

.repeat:

    mov rdi, QWORD [rsp + 8]
    cmp rdi, 10
    jge .done
     
    call print_number
    inc QWORD [rsp + 8]

    jmp .repeat

.done:
    add rsp, 8
    pop rbp
    ret

; --- Entry Point ---
_start:
    mov rcx, 10

    call counter

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; nasm -f elf64 hello.asm -o hello.o && ld hello.o -o hello && ./hello
