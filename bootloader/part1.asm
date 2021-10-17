[BITS 16]

jmp rm_start

%include "intel_16.asm"

rm_start:
    mov ax, 0x9C0
    add ax, 288
    mov ss, ax
    mov sp, 4096

    mov ax, 0x7C0
    mov ds, ax

    mov ah, 0x01
    mov cx, 0x2607
    int 0x10

    call new_line_16

    mov si, header_0
    call print_line_16

    mov si, header_1
    call print_line_16

    mov si, header_2
    call print_line_16

    call new_line_16

    mov si, press_key_msg
    call print_line_16

    call new_line_16

    in al, 0x92
    or al, 2
    out 0x92, al

    call key_wait

    mov si, load_kernel
    call print_line_16

    xor ax, ax
    xor ah, ah
    mov dl, 0
    int 0x13

    jc reset_failed

    bootdev equ 0x0
    sectors equ 1

    mov ax, 0x90
    mov es, ax
    xor bx, bx

    mov ah, 0x2         
    mov al, sectors     
    xor ch, ch          
    mov cl, 2           
    xor dh, dh          
    mov dl, bootdev     
    int 0x13

    jc read_failed

    cmp al, sectors
    jne read_failed

    jmp dword 0x90:0x0

reset_failed:
    mov si, reset_failed_msg
    call print_line_16

    jmp error_end

read_failed:
    mov si, read_failed_msg
    call print_line_16

error_end:
    mov si, load_failed
    call print_line_16

    jmp $
    
header_0 db '_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_', 0
header_1 db 'BaLeCoK NEW Bootloader', 0
header_2 db '_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_', 0

press_key_msg db 'Press any key to load the kernel...', 0
load_kernel db 'Attempt to load the part 2...', 0

reset_failed_msg db 'Reset disk failed', 0
read_failed_msg db 'Read disk failed', 0
load_failed db 'Part 2 loading failed', 0


times 510-($-$$) db 0
dw 0xAA55
