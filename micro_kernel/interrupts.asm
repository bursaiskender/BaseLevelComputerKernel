STRING isr0_msg, "Divide by Zero exception "
STRING isr1_msg, "Debug Exception "
STRING isr2_msg, "Non Maskale Interrupt Exception "
STRING isr3_msg, "Breakpoint Exception "
STRING isr4_msg, "Into Detected Overflow Exception "
STRING isr5_msg, "Out Of Bounds Exception "
STRING isr6_msg, "Invalid Opcode Exception "
STRING isr7_msg, "No Coprocessor Exception "
STRING isr8_msg, "Double Fault Exception "
STRING isr9_msg, "Coprocessor Segment Overrun Exception "
STRING isr10_msg, "Bad TSS Exception "
STRING isr11_msg, "Segment Not Present Exception "
STRING isr12_msg, "Stack Fault Exception "
STRING isr13_msg, "General Protection Fault Exception "
STRING isr14_msg, "Page Fault Exception "
STRING isr15_msg, "Unknown Interrupt Exception "
STRING isr16_msg, "Coprocessor Fault Exception "
STRING isr17_msg, "Alignment Check Exception "
STRING isr18_msg, "Machine Check Exception "
STRING isr19_msg, "19: Reserved Exception "
STRING isr20_msg, "20: Reserved Exception "
STRING isr21_msg, "21: Reserved Exception "
STRING isr22_msg, "22: Reserved Exception "
STRING isr23_msg, "23: Reserved Exception "
STRING isr24_msg, "24: Reserved Exception "
STRING isr25_msg, "25: Reserved Exception "
STRING isr26_msg, "26: Reserved Exception "
STRING isr27_msg, "27: Reserved Exception "
STRING isr28_msg, "28: Reserved Exception "
STRING isr29_msg, "29: Reserved Exception "
STRING isr30_msg, "30: Reserved Exception "
STRING isr31_msg, "31: Reserved Exception "

STRING cr2_str, "cr2: "
STRING rsp_str, "rsp: "

%macro CREATE_ISR 1
_isr%1:
    cli

    push r8

    lea rdi, [12 * 8 * 0x14 + 30 * 2 + TRAM]
    mov dl, STYLE(RED_F, WHITE_B)
    call print_string
    
    mov rax, %1
    cmp rax, 14
    jne .end

    .page_fault_exception

    lea rdi, [13 * 8 * 0x14 + 30 * 2 + TRAM]
    mov rbx, cr2_str
    call print_string

    lea rdi, [13 * 8 * 0x14 + 35 * 2 + TRAM]
    mov r8, cr2
    call print_int

    lea rdi, [14 * 8 * 0x14 + 30 * 2 + TRAM]
    mov rbx, rsp_str
    call print_string

    lea rdi, [14 * 8 * 0x14 + 35 * 2 + TRAM]
    mov r8, rsp
    call print_int

    .end
        
    hlt

    pop r8

    iretq
%endmacro

%macro CREATE_IRQ 1
_irq%1:
    cli

    mov rax, [irq_handlers + 8 *%1]
    test rax, rax

    je .eoi
    call rax

    .eoi:

    mov rax, %1 
    test rax, rax
    jl .master


    mov al, 0x20
    out 0xA0, al

    .master:

    mov al, 0x20
    out 0x20, al

    iretq
%endmacro

%macro IDT_SET_GATE 4
    lea rdi, [IDT64 + %1 * 16]

    mov rax, %2
    mov word [rdi], ax 
    mov word [rdi+2], %3 
    mov byte [rdi+4], 0  
    mov byte [rdi+5], %4 

    shr rax, 16
    mov word [rdi+6], ax
    shr rax, 16
    mov dword [rdi+8], eax 
    mov dword [rdi+12], 0  
%endmacro

%assign i 0
%rep 32
CREATE_ISR i
%assign i i+1
%endrep

%assign i 0
%rep 16
CREATE_IRQ i
%assign i i+1
%endrep


install_idt:
    lidt [IDTR64]

    ret

install_isrs:
    IDT_SET_GATE 0, _isr0, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 1, _isr1, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 2, _isr2, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 3, _isr3, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 4, _isr4, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 5, _isr5, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 6, _isr6, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 7, _isr7, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 8, _isr8, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 9, _isr9, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 10, _isr10, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 11, _isr11, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 12, _isr12, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 13, _isr13, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 14, _isr14, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 15, _isr15, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 16, _isr16, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 17, _isr17, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 18, _isr18, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 19, _isr19, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 20, _isr20, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 21, _isr21, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 22, _isr22, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 23, _isr23, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 24, _isr24, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 25, _isr25, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 26, _isr26, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 27, _isr27, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 28, _isr28, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 29, _isr29, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 30, _isr30, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 31, _isr31, LONG_SELECTOR-GDT64, 0x8E

    ret

remap_irqs:
    mov al, 0x11
    out 0x20, al 
    out 0xA0, al 

    mov al, 0x20
    out 0x21, al 
    mov al, 0x28
    out 0xA1, al 

    mov al, 0x04
    out 0x21, al 
    mov al, 0x02
    out 0xA1, al 

    mov al, 0x01
    out 0x21, al 
    out 0xA1, al 

    mov al, 0x0
    out 0x21, al
    out 0xA1, al 

    ret

install_irqs:
    IDT_SET_GATE 32, _irq0, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 33, _irq1, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 34, _irq2, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 35, _irq3, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 36, _irq4, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 37, _irq5, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 38, _irq6, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 39, _irq7, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 40, _irq8, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 41, _irq9, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 42, _irq10, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 43, _irq11, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 44, _irq12, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 45, _irq13, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 46, _irq14, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 47, _irq15, LONG_SELECTOR-GDT64, 0x8E

    ret

install_syscalls:
    IDT_SET_GATE 60, syscall_reboot, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 61, syscall_irq, LONG_SELECTOR-GDT64, 0x8E
    IDT_SET_GATE 62, syscall_mmap, LONG_SELECTOR-GDT64, 0x8E
    
    ret
    
register_irq_handler:
    mov [irq_handlers + r8 * 8], r9

    ret
    
syscall_irq:
    cli

    call register_irq_handler

    iretq
    
syscall_reboot:
    cli

    push rax

    mov al, 0x64
    or al, 0xFE
    out 0x64, al
    mov al, 0xFE
    out 0x64, al

    pop rax

    iretq

syscall_mmap:
    cli

    .e820_failed:

    cmp r8, 0
    jne .entry_count

    movzx rax, byte [e820_failed]
    iretq

    .entry_count:

    cmp r8, 1
    jne .e820_mmap

    movzx rax, word [e820_entry_count]
    iretq

    .e820_mmap:

    mov rax, e820_memory_map
    iretq
    
IDT64:
    times 128 dq 0,0

IDTR64:
    dw (128 * 16) - 1  ; Limit
    dq IDT64           ; Base

irq_handlers:
    times 16 dq 0
