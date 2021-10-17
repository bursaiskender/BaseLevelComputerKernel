[BITS 16]

new_line_16:
	mov ah, 0Eh

    mov al, 0Ah
    int 10h

    mov al, 0Dh
    int 10h

    ret

print_line_16:
	mov ah, 0Eh

.repeat:
	lodsb
    test al, al
	je .done
	int 10h
	jmp .repeat

.done:
    call new_line_16

    ret

print_16:
	mov ah, 0Eh

.repeat:
	lodsb
    test al, al
	je .done
	int 10h
	jmp .repeat

.done:
    ret

key_wait:
    mov al, 0xD2
    out 64h, al

    mov al, 0x80
    out 60h, al

    .keyup:
        in al, 0x60
        and al, 10000000b
    jnz .keyup

    .keydown:
    in al, 0x60

    ret
