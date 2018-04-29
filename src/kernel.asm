[BITS 16]
[ORG 0x1000]

jmp _start 


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

%macro PRINT_B 3
    mov rdi, TRAM
    mov rbx, %1
    mov dl, STYLE(%2, %3)
    call print_string
%endmacro

%macro PRINT_P 3
    mov rbx, %1
    mov dl, STYLE(%2, %3)
    call print_string
%endmacro

_start:
    xor ax, ax
    mov ds, ax

    cli

    lgdt [GDT64]

    mov eax, cr0
    or al, 1b
    mov cr0, eax

    mov eax, cr0
    and eax, 01111111111111111111111111111111b
    mov cr0, eax

    jmp (CODE_SELECTOR-GDT64):pm_start



[BITS 32]

pm_start:

    mov ax, DATA_SELECTOR-GDT64
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov eax, cr4
    or eax, 100000b
    mov cr4, eax

    mov edi, 0x70000
    mov ecx, 0x10000
    xor eax, eax
    rep stosd

    mov dword [0x70000], 0x71000 + 7    
    mov dword [0x71000], 0x72000 + 7   
    mov dword [0x72000], 0x73000 + 7    

    mov edi, 0x73000                    
    mov eax, 7
    mov ecx, 256                        

    make_page_entries:
        stosd
        add     edi, 4
        add     eax, 0x1000
        loop    make_page_entries
    
    mov ecx, 0xC0000080
    rdmsr
    or eax, 100000000b
    wrmsr
    
    mov eax, 0x70000    
    mov cr3, eax        


    mov eax, cr0
    or eax, 10000000000000000000000000000000b
    mov cr0, eax

    jmp (LONG_SELECTOR-GDT64):lm_start
    
[BITS 64]
    
lm_start:
    call clear_screen
    mov qword [current_line], 1
    call set_current_position
    mov qword [current_column], 15
    PRINT_P command_line, BLACK_F, WHITE_B

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
        mov rax, [current_line]
        inc rax
        mov [current_line], rax

        mov qword [current_column], 0
        mov r8, [current_input_length]
        mov byte [current_input_str + r8], 0
    
        mov r8, [command_table]
        xor r9, r9

        .start:
            cmp r9, r8
            je .command_not_found
            mov rsi, current_input_str
            mov rdi, r9
            shl rdi, 4
            add rdi, 8
            add rdi, command_table

        .next_char
            mov al, [rsi]
            mov bl, [rdi]

            cmp al, 0
            jne .compare

            cmp bl, 0
            jne .compare

            mov r8, r9
            inc r8
            shl rdi, 4
            add rdi, command_table
            mov r8, [rdi]
            jmp .exec_command

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
                
        .exec_command:
            call r8

            mov rax, [current_line]
            inc rax
            mov [current_line], rax

            mov qword [current_column], 0

            call set_current_position
            PRINT_P command_line, BLACK_F, WHITE_B
            mov qword [current_column], 6

            jmp .end
            
        .command_not_found:
            PRINT_P unknown_command_str_1, BLACK_F, WHITE_B

            mov rax, [current_column]
            add rax, unknown_command_length_1
            mov [current_column], rax

            call set_current_position
            PRINT_P current_input_str, BLACK_F, WHITE_B

            mov rax, [current_column]
            mov rbx, [current_input_length]
            add rax, rbx
            mov [current_column], rax

            call set_current_position
            PRINT_P unknown_command_str_2, BLACK_F, WHITE_B

        .end:
            mov qword [current_input_length], 0
            jmp .start_waiting

set_current_position:
    push rax
    push rbx

    mov rax, [current_line]
    mov rbx, 0x14 * 8
    mul rbx

    mov rbx, [current_column]
    shl rbx, 1

    lea rdi, [rax + rbx + TRAM]


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
    
clear_screen:
    PRINT_B header_title, WHITE_F, BLACK_B

    mov rdi, TRAM + 0x14 * 8

    mov rcx, 0x14 * 24
    mov rax, 0x0720072007200720
    rep stosq

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

sysinfo_command:
    call set_current_position
    PRINT_P sysinfo_command_str, BLACK_F, WHITE_B
    
    ret

reboot_command:
    call set_current_position
    PRINT_P reboot_command_str, BLACK_F, WHITE_B
    
    ret
    
command_table:
    dq 2

    dq sysinfo_command_str
    dq sysinfo_command
    
    dq reboot_command_str
    dq reboot_command
    
; Defines
    current_line dq 0
    current_column dq 0
    current_input_length dq 0
    current_input_str:
        times 32 db 0
    kernel_header_0 db 'BaLeCoK -> Base Level Computer Kernel', 0
    kernel_header_1 db 'Developed and Maintained by @BTaskaya', 0
    kernel_header_2 db 'Welcome to the our Kernel Part', 0
    header_title db "                                    BaLeCoK                                     ", 0
    command_line db "root@balecok $ ", 0
    sysinfo_command_str db 'sysinfo', 0
    reboot_command_str db 'reboot', 0
    unknown_command_str_1 db 'The command "', 0
    unknown_command_length_1 equ $ - unknown_command_str_1 - 1
    unknown_command_str_2 db '" does not exist', 0
    TRAM equ 0x0B8000
    VRAM equ 0x0A0000

qwerty:
    db '0',0xF,'1234567890',0xF,0xF,0xF,0xF
    db 'qwertyuiop'
    db '[]',0xD,0x11
    db 'asdfghjkl;\/()'
    db 'zxcvbnm,./'
    db 0xF,'*',0x12,0x20,0xF,0xF 
    
GDT64:
    NULL_SELECTOR:
        dw GDT_LENGTH   
        dw GDT64        
        dd 0x0

    CODE_SELECTOR:         
        dw 0x0FFFF
        db 0x0, 0x0, 0x0
        db 10011010b
        db 11001111b
        db 0x0

    DATA_SELECTOR:         
        dw  0x0FFFF
        db  0x0, 0x0, 0x0
        db  10010010b
        db  10001111b
        db  0x0

    LONG_SELECTOR:  
        dw  0x0FFFF
        db  0x0, 0x0, 0x0
        db  10011010b       
        db  10101111b
        db  0x0

   GDT_LENGTH:

   ; Boot Sector
   times 2048-($-$$) db 0
