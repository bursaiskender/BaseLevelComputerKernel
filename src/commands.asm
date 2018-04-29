sysinfo_command:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    push rax
    push rbx
    push rcx
    push rdx

    mov r8, sysinfo_vendor_id
    mov r9, sysinfo_vendor_id_length
    call print_normal

    xor eax, eax
    cpuid

    mov [rsp+0], ebx
    mov [rsp+4], edx
    mov [rsp+8], ecx

    call set_current_position
    mov rbx, rsp
    mov dl, STYLE(BLACK_F, WHITE_B)
    call print_string

    call goto_next_line
    mov r8, sysinfo_stepping
    mov r9, sysinfo_stepping_length
    call print_normal
    

    mov eax, 1
    cpuid

    mov r15, rax

    mov r8, r15
    and r8, 0xF

    call set_current_position
    mov dl, STYLE(BLACK_F, WHITE_B)
    call print_int

    call goto_next_line
    mov r8, sysinfo_model
    mov r9, sysinfo_model_length
    call print_normal

    mov r14, r15
    and r14, 0xF0

    mov r13, r15
    and r13, 0xF00

    mov r12, r15
    and r12, 0xF0000

    mov r11, r15
    and r11, 0xFF00000

    shl r12, 4
    mov r8, r14
    add r8, r12
    call set_current_position
    mov dl, STYLE(BLACK_F, WHITE_B)
    call print_int

    call goto_next_line
    mov r8, sysinfo_family
    mov r9, sysinfo_family_length
    call print_normal

    mov r8, r13
    add r8, r11
    call set_current_position
    mov dl, STYLE(BLACK_F, WHITE_B)
    call print_int

    call goto_next_line
    mov r8, sysinfo_features
    mov r9, sysinfo_features_length
    call print_normal

    mov eax, 1
    cpuid

    .mmx:

    mov r15, rdx
    and r15, 1 << 23
    cmp r15, 0
    je .sse

    mov r8, sysinfo_mmx
    mov r9, sysinfo_mmx_length
    call print_normal

    .sse:

    mov r15, rdx
    and r15, 1 << 25
    cmp r15, 0
    je .sse2

    mov r8, sysinfo_sse
    mov r9, sysinfo_sse_length
    call print_normal

    .sse2:

    mov r15, rdx
    and r15, 1 << 26
    cmp r15, 0
    je .ht

    mov r8, sysinfo_sse2
    mov r9, sysinfo_sse2_length
    call print_normal

    .ht:

    mov r15, rdx
    and r15, 1 << 28
    cmp r15, 0
    je .sse3

    mov r8, sysinfo_ht
    mov r9, sysinfo_ht_length
    call print_normal

    .sse3:

    mov r15, rcx
    and r15, 1 << 9
    cmp r15, 0
    je .sse4_1

    mov r8, sysinfo_sse3
    mov r9, sysinfo_sse3_length
    call print_normal
    
    .sse4_1:

    mov r15, rcx
    and r15, 1 << 19
    cmp r15, 0
    je .sse4_2

    mov r8, sysinfo_sse4_1
    mov r9, sysinfo_sse4_1_length
    call print_normal
    
    .sse4_2:

    mov r15, rcx
    and r15, 1 << 20
    cmp r15, 0
    je .last

    mov r8, sysinfo_sse4_2
    mov r9, sysinfo_sse4_2_length
    call print_normal
    
    .last:

    pop rdx
    pop rcx
    pop rbx
    pop rax

    sub rsp, 16
    leave
    ret

reboot_command:
    in al, 0x64
    or al, 0xFE
    out 0x64, al
    mov al, 0xFE
    out 0x64, al
    
    ret

devinfo_command:
    mov r8, devinfo_author
    mov r9, devinfo_author_length
    call print_normal
    
    call goto_next_line
    
    mov r8, devinfo_repo
    mov r9, devinfo_repo_length
    call print_normal
    
    ret
    
clear_command:
    ; Print top bar
    call set_current_position
    mov rbx, header_title
    mov dl, STYLE(WHITE_F, BLACK_B)
    call print_string

    ; Fill the entire screen with black
    mov rdi, TRAM + 0x14 * 8
    mov rcx, 0x14 * 24
    mov rax, 0x0720072007200720
    rep stosq

    ; Line 0 is for header
    mov qword [current_line], 0
    mov qword [current_column], 0

    ret
    
command_table:
    dq 4

    dq sysinfo_command_str
    dq sysinfo_command
    
    dq reboot_command_str
    dq reboot_command
    
    dq devinfo_command_str
    dq devinfo_command
    
    dq clear_command_str
    dq clear_command
    
sysinfo_command_str db 'sysinfo', 0
reboot_command_str db  'reboot', 0
devinfo_command_str db 'devinfo', 0
STRING sysinfo_vendor_id, "Vendor ID: "
STRING sysinfo_stepping, "Stepping: "
STRING sysinfo_model, "Model: "
STRING sysinfo_family, "Family: "
STRING sysinfo_features, "Features: "
STRING sysinfo_mmx, "mmx "
STRING sysinfo_sse, "sse "
STRING sysinfo_sse2, "sse2 "
STRING sysinfo_sse3, "sse3 "
STRING sysinfo_sse4_1, "sse4_1 "
STRING sysinfo_sse4_2, "sse4_2 "
STRING sysinfo_ht, "ht "
STRING devinfo_author, "Batuhan Osman Taskaya - @BTaskaya on github -"
STRING devinfo_repo, "github.com/BaLeCoK/BaseLevelComputerKernel"
