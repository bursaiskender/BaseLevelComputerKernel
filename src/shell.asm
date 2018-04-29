%define BLACK_F 0x0
%define BLUE_F 0x1
%define GREEN_F 0x2
%define CYAN_F 0x3
%define RED_F 0x4
%define PINK_F 0x5
%define ORANGE_F 0x6
%define WHITE_F 0x7

%define BLACK_B 0x0
%define BLUE_B 0x1
%define GREEN_B 0x2
%define CYAN_B 0x3
%define RED_B 0x4
%define PINK_B 0x5
%define ORANGE_B 0x6
%define WHITE_B 0x7

%define STYLE(f,b) ((f << 4) + b)

%include "src/utils/macros.asm"
%include "src/commands.asm"

shell_start:
    call clear_command
    call goto_next_line
    mov r8, command_line
    mov r9, command_line_length
    call print_normal
    
    .start_waiting:
        call key_wait
        
        cmp al, 28
        je .new_command
        
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

        jmp .start_waiting

    .new_command:
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

            mov r8, command_line
            mov r9, command_line_length
            call print_normal

            jmp .start_waiting

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

key_to_ascii:
    and eax, 0xFF

    mov al, [eax + qwerty]
    ret

key_wait:
    mov al, 0xD2
    out 0x64, al

    mov al, 0x80
    out 0x60, al

    .key_up:
        in al, 0x60
        and al, 10000000b
    jnz .key_up

        in al, 0x60

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

int_str_length:
    push rbx
    push rdx
    push rsi

    mov rax, r8

    xor rsi, rsi

    .loop:
        xor rdx, rdx
        mov rbx, 10
        div rbx
        add rdx, 48

        inc rsi

        cmp rax, 0
        jne .loop

    .exit:
        mov rax, rsi

        pop rsi
        pop rdx
        pop rbx

        ret
        
goto_next_line:
    push rax
    mov rax, [current_line]
    inc rax
    mov [current_line], rax
    mov qword [current_column], 0
    pop rax
    ret
    
; Defines
    current_line dq 0
    current_column dq 0
    current_input_length dq 0
    current_input_str:
        times 32 db 0
    header_title db "                                    BaLeCoK                                     ", 0
    clear_command_str db 'clear', 0
    STRING command_line,  "root@balecok $ "
    STRING unknown_command_str_1, "The command "
    STRING unknown_command_str_2, " does not exist"
    TRAM equ 0x0B8000
    VRAM equ 0x0A0000

qwerty:
    db '0',0xF,'1234567890',0xF,0xF,0xF,0xF
    db 'qwertyuiop'
    db '[]',0xD,0x11
    db 'asdfghjkl;\/()'
    db 'zxcvbnm,./'
    db 0xF,'*',0x12,0x20,0xF,0xF 
