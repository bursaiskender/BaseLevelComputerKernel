%include "src/utils/utils.asm"
%include "src/utils/keyboard.asm"
%include "src/commands.asm"

shell_start:
    call clear_command

    call goto_next_line

    mov r8, command_line
    mov r9, command_line_length
    call print_normal

    mov r8, 1
    mov r9, key_entered
    call register_irq_handler

    ret

key_entered:
    in al, 0x60
    mov dl, al
    and dl, 10000000b

    jnz .end_handler

    ; ENTER key
    cmp al, 0x1C
    je .enter
    
    cmp al, 0x0E
    je .backspace

    call key_to_ascii

    mov r8, [current_input_length]
    mov byte [current_input_str + r8], al
    inc r8
    mov [current_input_length], r8

    call set_current_position
    stosb

    mov r13, [current_column]
    inc r13
    mov [current_column], r13

    jmp .end_handler

    .enter:
        call goto_next_line

        mov r8, [current_input_length]
        mov byte [current_input_str + r8], 0

        mov r8, [command_table] 
        xor r9, r9              

        .start:
            cmp r9, r8
            je .command_not_found

            mov rsi, current_input_str
            mov r10, r9
            shl r10, 4
            mov rdi, [r10 + command_table + 8]

        .next_char:
            mov al, [rsi]
            mov bl, [rdi]

            cmp al, 0
            jne .compare

            cmp bl, 0
            jne .compare

            ; both == 0

            mov r10, r9
            inc r10
            shl r10, 4

            call [command_table + r10]

            jmp .end

            .compare:

            cmp al, 0
            je .next_command

            cmp bl, 0
            je .next_command

            cmp al, bl
            jne .next_command

            inc rsi
            inc rdi

            jmp .next_char

        .next_command:
            inc r9
            jmp .start

        .command_not_found:
            mov r8, unknown_command_str_1
            mov r9, unknown_command_str_1_length
            call print_normal

            call set_current_position

            mov rbx, current_input_str
            mov dl, STYLE(BLACK_F, WHITE_B)
            call print_string

            mov rax, [current_column]
            mov rbx, [current_input_length]
            add rax, rbx
            mov [current_column], rax

            mov r8, unknown_command_str_2
            mov r9, unknown_command_str_2_length
            call print_normal

        .end:
            mov qword [current_input_length], 0

            call goto_next_line

            ;Display the command line
            mov r8, command_line
            mov r9, command_line_length
            call print_normal
            jmp .end_handler

    .backspace:

        mov r8, [current_input_length]
        test r8, r8
        je .end_handler

        dec r8
        mov [current_input_length], r8

        mov r13, [current_column]
        dec r13
        mov [current_column], r13

        call set_current_position
        mov al, ' '
        stosb
    
    .end_handler:

    ret
    
; Defines
    current_input_length dq 0
    current_input_str:
        times 32 db 0
    header_title db "                                    BaLeCoK                                     ", 0
    STRING command_line,  "root@balecok $ "
    STRING unknown_command_str_1, "The command "
    STRING unknown_command_str_2, " does not exist"
