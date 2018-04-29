current_line dq 0
current_column dq 0
TRAM equ 0x0B8000
VRAM equ 0x0A0000

set_current_position:
    push rax
    push rbx
    push rdx
    
    mov rax, [current_line]
    mov rbx, 0x14 * 8
    mul rbx

    mov rbx, [current_column]
    shl rbx, 1

    lea rdi, [rax + rbx + TRAM]

    pop rdx
    pop rbx
    pop rax

    ret
    
print_normal:
    push rax
    push rbx
    push rdx
    push rdi

    call set_current_position
    mov rbx, r8
    mov dl, STYLE(BLACK_F, WHITE_B)
    call print_string

    mov rax, [current_column]
    add rax, r9
    mov [current_column], rax

    pop rdi
    pop rdx
    pop rbx
    pop rax

    ret
    
print_string:
    push rax

.repeat:
    mov al, [rbx]

    cmp al, 0
    je .done

    stosb

    mov al, dl
    stosb

    inc rbx

    jmp .repeat

.done:
    pop rax

    ret
    
print_int:
    push rax
    push rbx
    push rdx
    push r10
    push rsi

    mov rax, r8
    mov r10, rdx

    xor rsi, rsi

    .loop:
        xor rdx, rdx
        mov rbx, 10
        div rbx
        add rdx, 48

        push rdx
        inc rsi

        cmp rax, 0
        jne .loop

    .next:
        cmp rsi, 0
        je .exit
        dec rsi

        pop rax
        stosb

        mov rdx, r10
        mov al, dl
        stosb

        jmp .next

    .exit:
        pop rsi
        pop r10
        pop rdx
        pop rbx
        pop rax

        ret
