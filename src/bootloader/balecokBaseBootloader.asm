[BITS 16]

jmp rm_start

%include "src/utils/intel_16.asm" ; Include common functions


rm_start: ; Starting process
    
    ; set stack space and segment
    mov ax, 0x7C0
    add ax, 288
    mov ss, ax
    mov sp, 4096
    ; set stack space and segment
    
    ; set data segments
    mov ax, 0x7C0 
    mov ds, ax 
    ; set data segments
    
    mov ah, 0x01
    mov cx, 0x2607
    int 0x10
    
    ; introduce bootloader to user
    call new_line_16

    mov si, header_0
    call print_line_16

    mov si, header_1
    call print_line_16

    call new_line_16

    mov si, press_key_msg
    call print_line_16

    call new_line_16

    ; A20 gate part
    in al, 0x92
    or al, 2
    out 0x92, al
    
    call key_wait ; wait any key for starting process

    mov si, load_kernel
    call print_line_16
        
    xor ax, ax
    xor ah, ah
    mov dl, 0
    int 0x13

    jc reset_failed
    
    ASM_KERNEL_BASE equ 0x100
    asm_sectors equ 0x22
    bootdev equ 0x0
        
    mov ax, ASM_KERNEL_BASE
    mov es, ax
    xor bx, bx

    mov ah, 0x2         ; memory reading for sectors
    mov al, asm_sectors ; determine the total number of sectors for read
    xor ch, ch          ; cylinder 0
    mov cl, 2           ; sector 2
    xor dh, dh          ; head 0
    mov dl, bootdev     ; drive
    int 0x13

    jc read_failed

    cmp al, asm_sectors
    jne read_failed

    jmp dword ASM_KERNEL_BASE:0x0

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

; Defines

    header_0 db 'BaLeCoK -> Base Level Computer Kernel', 0
    header_1 db 'Developed and Maintained by @BTaskaya', 0

    press_key_msg db 'Press any key to boot kernel...', 0
    load_kernel db 'Attempt to boot the kernel...', 0

    reset_failed_msg db 'Disk reseting failed', 0
    read_failed_msg db 'Disk read operation failed', 0
    load_failed db 'Kernel loading failed', 0
    
; Boot Sector
times 510-($-$$) db 0
dw 0xAA55
