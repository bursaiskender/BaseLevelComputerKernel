install_timer:
    mov r8, 1193180 / 1000

    mov al, 0x36
    out 0x43, al 

    mov rax, r8
    out 0x40, al

    mov rax, r8
    shr rax, 8
    out 0x40, al

    mov r8, 0
    mov r9, irq_timer_handler
    call register_irq_handler

    ret

irq_timer_handler:
    push rax
    push rbx
    push rcx
    push rdx
    
    mov rax, [timer_ticks]
    inc rax
    mov [timer_ticks], rax

    xor rdx, rdx
    mov rcx, 1000
    div rcx
    test rdx, rdx
    jnz .end

    mov rax, [timer_seconds]
    inc rax
    mov [timer_seconds], rax

    .end:

    pop rdx
    pop rcx
    pop rbx
    pop rax
    
    ret

wait_ms:
    push r9
    push r10

    mov r9, [timer_ticks]
    add r9, r8

    .start:
        cli
        mov r10, [timer_ticks]
        cmp r10, r9
        je .done
        sti
        nop
        nop
        nop
        nop
        nop
        nop
        jmp .start

    .done:

    pop r10
    pop r9

    ret

timer_ticks dq 0
timer_seconds dq 0
