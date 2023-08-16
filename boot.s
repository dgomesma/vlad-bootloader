        BOOTLOAD_ADDRESS EQU 0x07C0
        VIDEO_ISR        EQU 0x10
        W_CHAR_SUBF      EQU 0x0e
        
        mov ax, BOOTLOAD_ADDRESS 
        mov ds, ax
        mov si, msg
        cld

print_loop:  
        lodsb
        or al, al        ; Verify if loaded null terminator
        jz hang

        ; Prepare for BIOS ISR
        mov bh, 0
        mov ah, W_CHAR_SUBF
        int VIDEO_ISR
        jmp print_loop

hang:   
        jmp hang
msg:    db 'Hello World!', 13, 10, 'Eu sou Vladiau.', 13, 10, 0

        times 510-($-$$) db 0
        db 0x55
        db 0xAA
