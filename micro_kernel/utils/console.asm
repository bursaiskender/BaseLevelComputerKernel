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

current_line dq 0
current_column dq 0
TRAM equ 0x0B8000
VRAM equ 0x0A0000
    
print_string:
    push rax

.repeat:
    mov al, [rbx]

    test al, al
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

        test rax, rax
        jne .loop

    .next:
        test rsi, rsi
        je .exit
        dec rsi

        ; write the char
        pop rax
        stosb

        ; Write style code
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
