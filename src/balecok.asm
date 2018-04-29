	BITS 16

start:
	mov ax, 07C0h		
	add ax, 288		
	mov sp, 4096

	mov ax, 07C0h		
	mov ds, ax

    call nwl ; add new line

	mov si, giristext_1
	call prl ; print line statement

    mov si, giristext_2
	call prl ; print line statement

    mov si, giristext_3
	call prl ; print line statement

    call nwl ; add new line

	jmp $


nwl: ; new line
	mov ah, 0Eh

    mov al, 0Ah
    int 10h

    mov al, 0Dh
    int 10h

    ret

prl: ; print line
	mov ah, 0Eh

.repeat:
	lodsb			
	cmp al, 0
	je .done		
	int 10h			
	jmp .repeat

.done:
    call nwl

    ret

	giristext_1 db 'Yerli Milli ------ Yerli Milli', 0
	giristext_2 db 'Kernel ---  BaLeCoK --- Kernel', 0
	giristext_3 db 'Yerli Milli ------ Yerli Milli', 0

	times 510-($-$$) db 0	
	dw 0xAA55		
