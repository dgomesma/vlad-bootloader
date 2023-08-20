[ORG 0x7c00]
[BITS 16]
	; Interrupts
	VIDEO_INT		EQU 0x10
	VIDEO_WCHAR_FN		EQU 0x0e
	
	DISK_INT		EQU 0x13
	DISK_RESET_FN		EQU 0x00
	DISK_READ_FN		EQU 0x02

	; Memory Layout
	BOOTLD2_BASE_ADDR	EQU 0x07e0

	; Disk Layout
	BOOTLD2_SECTOR		EQU 0x2

initialize_segments:
	mov ax, 0x0
	mov ds, ax

initialize_disk:
	mov ah, DISK_RESET_FN
	mov dl, 0
	int 0x13

; Contents read are buffered into [es:bx]
read:
	mov ax, 0
	mov bx, ax
	mov ax, BOOTLD2_BASE_ADDR
	mov es, ax
	mov ah, DISK_READ_FN		; Function code
	mov al, 0x1			; Number of sectors
	mov ch, 0x0			; Track number
	mov cl, 0x2			; Sector number	
	mov dh, 0x0			; Disk side number
	mov dl, 0x0			; Drive Number (Floppy disk is 0x0)
	int DISK_INT
	jc reading_error
	jmp BOOTLD2_BASE_ADDR:0x0

reading_error:
	mov si, error_msg
	cld

print_error:
	lodsb
	or al, al
	jz hang
	mov bh, 0x0		; Video page
	mov ah, VIDEO_WCHAR_FN
	int VIDEO_INT
	jmp print_error

hang:
	jmp hang

error_msg:
	db 'Error reading from disk', 13, 10, 0
	
signature:
	times 510-($-$$) db 0
	db 0x55
	db 0xaa
