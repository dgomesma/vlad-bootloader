[ORG 0x7e00]
[BITS 16]

	; Interrupts
	VIDEO_INT		EQU 0x10
	VIDEO_WCHAR_FN		EQU 0x0e
	
	DISK_INT		EQU 0x13
	DISK_RESET_FN		EQU 0x00
	DISK_READ_FN		EQU 0x02

	; Memory Layout
	BOOTLD2_BASE_ADDR	EQU 0x7e00

print:
	mov ax, 0x0
	mov ds, ax
	mov si, success_msg
	cld

print_loop:
	lodsb
	or al, al
	jz hang
	mov bh, 0x0
	mov ah, VIDEO_WCHAR_FN
	int VIDEO_INT
	jmp print_loop

hang:
	jmp hang

success_msg:
	db 'Success!!', 13, 10, 0
