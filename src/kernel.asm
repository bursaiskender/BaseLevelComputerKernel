[BITS 16]
[ORG 0x1000]

jmp _start

_start:
    xor ax, ax
    mov ds, ax

    cli

    lgdt [GDTR64]

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
    or eax, 1 << 5
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
    call install_idt

    call install_isrs

    call remap_irqs

    call install_irqs

    sti

    call shell_start

    jmp $

%include "src/utils/macros.asm"
%include "src/utils/console.asm"

%include "src/interrupts.asm"
%include "src/shell.asm"


GDT64:
    NULL_SELECTOR:
        dq 0

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

GDTR64:
    dw 4 * 8 - 1 
    dd GDT64

   times 16384-($-$$) db 0
