[BITS 16]

jmp second_step

%include "intel_16.asm"

second_step:
    xor ax, ax
    xor ah, ah
    mov dl, 0
    int 0x13

    KERNEL_BASE equ 0x100      
    sectors equ 0x48           
    bootdev equ 0x0

    mov ax, KERNEL_BASE
    mov es, ax
    xor bx, bx

    mov ah, 0x2         
    mov al, sectors     
    xor ch, ch          
    mov cl, 3          
    xor dh, dh          
    mov dl, bootdev    
    int 0x13

    jmp dword KERNEL_BASE:0x0

    times 512-($-$$) db 0
