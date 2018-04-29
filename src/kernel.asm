[BITS 16]

jmp _start 

%include "src/utils/intel_16.asm" ; Include common functions

_start:
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xffff

    mov ax, 0x100
    mov ds, ax

    call new_line_16

    mov si, kernel_header_0
    call print_line_16

    mov si, kernel_header_1
    call print_line_16

    mov si, kernel_header_2
    call print_line_16

    call new_line_16

    jmp $
    
    ; Defines

    kernel_header_0 db 'BaLeCoK -> Base Level Computer Kernel', 0
    kernel_header_1 db 'Developed and Maintained by @BTaskaya', 0
    kernel_header_2 db 'Welcome to the our Kernel Part', 0

; Boot Sector
times 512-($-$$) db 0
