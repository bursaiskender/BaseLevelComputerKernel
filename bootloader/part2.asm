[BITS 16]

jmp second_step

%include "intel_16.asm"

KERNEL_BASE equ 0x100     
sectors equ 0x48          
bootdev equ 0x0

second_step:
    mov ax, 0x90
    mov ds, ax

    mov si, load_kernel
    call print_line_16

    xor ax, ax
    mov dl, bootdev
    int 0x13

    jc reset_failed

    mov ax, KERNEL_BASE
    mov es, ax

    xor di, di

.next:
    xor bx, bx

    mov ah, 0x2         
    mov al, 1          
    mov ch, [cylinder]  
    mov cl, [sector]    
    mov dh, [head]      
    mov dl, bootdev    
    int 0x13

    jc read_failed

    test ah, ah
    jne read_failed

    cmp al, 1
    jne read_failed

    mov si, star
    call print_16

    inc di
    cmp di, sectors
    jne .continue

    mov si, kernel_loaded
    call print_line_16

    jmp dword KERNEL_BASE:0x0

.continue:
    mov cl, [sector]
    inc cl
    mov [sector], cl

    cmp cl, 19
    jne .next_sector

    mov cl, 1
    mov [sector], cl

    mov dh, [head]
    inc dh
    mov [head], dh

    cmp dh, 2
    jne .next_sector

    mov dh, 0
    mov [head], dh

    mov ch, [cylinder]
    inc ch
    mov [cylinder], ch

.next_sector:
    mov ax, es
    add ax, 0x20   
    mov es, ax

    jmp .next

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

sector db 1
head db 0
cylinder db 1


load_kernel db 'Attempt to load the kernel...', 0
kernel_loaded db 'Kernel fully loaded', 0
star db '*', 0

reset_failed_msg db 'Reset disk failed', 0
read_failed_msg db 'Read disk failed', 0
load_failed db 'Kernel loading failed', 0

times 512-($-$$) db 0
