	[BITS 16]

start: ; Starting process
    
    ; set stack space and segment
	mov ax, 07C0h
	add ax, 288
	mov ss, ax
	mov sp, 4096
    ; set stack space and segment
    
    ; set data segments
	mov ax, 07C0h 
	mov ds, ax 
    ; set data segments
    
    
    ; introduce bootloader to user
    call new_line

	mov si, header_0
	call print_line

    mov si, header_1
	call print_line

    call new_line

    mov si, press_key_msg
    call print_line

    call new_line

    ; A20 gate part
    in 		al, 0x92
    or 		al, 2
    out		 0x92, al
    
    call key_wait ; wait any key for starting process

    mov si, load_kernel
        call print_line
    ; introduce bootloader to user
    
	jmp $ ; fucking infinite loop


new_line:
	mov ah, 0Eh
    mov al, 0Ah
    int 10h
    mov al, 0Dh
    int 10h
    
    ret

print_line:
	mov ah, 0Eh

.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat

.done:
    call new_line
    ret

key_wait:
    mov		al, 0xD2
    out		64h, al
    mov		al, 0x80
	out		60h, al
    keyup:
		in		al, 0x60
		and	 	al, 10000000b
	jnz		keyup
	Keydown:
	in		al, 0x60

    ret

; Defines

	header_0 db 'BaLeCoK -> Base Level Computer Kernel', 0
	header_1 db 'Developed and Maintained by @BTaskaya', 0

    press_key_msg db 'Press any key to boot kernel...', 0
    load_kernel db 'Attempt to boot the kernel...', 0

; Boot Sector
times 510-($-$$) db 0
dw 0xAA55
