.code16

	# Interrupts
	VIDEO_INT = 0x10
	VIDEO_WCHAR_FN = 0x0e

	DISK_INT = 0x13
	DISK_RESET_FN = 0x00
	DISK_READ_FN = 0x02

	# Big Memory Services
	BIG_MEM_SRV_INT = 0x15
	BIG_MEM_SIZE_AH = 0xe8
	SYS_MEM_MAP_AL = 0x20

	# Memory Allocation
	# Memory Map Buffer
	# Physical Address = 0x9e3ff
	MEM_MAP_BUF_PHYS_ADDR = 0x9e3ff
	MEM_MAP_BUF_BEGIN_SEGMENT = 0x9e3f
	MEM_MAP_BUF_BEGIN_OFFSET = 0x000f

	# Physical Address = 0x9fbff
	MEM_MAP_BUF_END_SEGMNET = 0x9fbf
	MEM_MAP_BUF_END_OFFSET = 0x000f

	# Other
	SMAP = 0x534D4150
	SMAP_LOW = 0x4D53
	SMAP_HIGH = 0x5041
	MEM_MAP_STRUCT_SIZE = 24		

.section .text
	call detect_mem
	call print_mem_detected
	call print_testing_a20
	call test_a20
	cmpw $0x0, %ax
	je a20_disabled
	call print_a20_is_enabled	
	call print_newline
	jmp a20_fi

a20_disabled:
	call print_a20_is_disabled
	call print_newline
	call print_enable_a20_bios
	call enable_a20_bios
	call test_a20
	cmpw $0x0, %ax
	je a20_bios_failed
	call print_success
	call print_newline
	jmp a20_fi

a20_bios_failed:
	call print_failed
	call print_newline
	
a20_fi:
	call print_success
	jmp hang

# Function:
#	Verifies if A20 is enabled or not by verifying if
#	memory-wrapping is enabled. If memory-wrapping is
#	enabled, then A20 is disabled.
# Arguments:
#	No Arguments
# Output:
#	AX- 0 if disabled, 1 if enabled
test_a20:
	pushw %bp
	movw %sp, %bp
	pushw %es
	pushw %ds
	pushw %di
	pushw %si
	cli

	# Setup es:di
	xor %ax, %ax
	movw %ax, %es
	movw $0x0500, %di

	# Setup ds:si
	not %ax
	movw %ax, %ds	
	movw $0x0510, %si

	# Save contents at es:di
	movb %es:(%di), %al
	pushw %ax

	# Save contents at ds:si
	movb %ds:(%si), %al
	pushw %ax

	# Verify if address wraps around
	movb $0x00, %es:(%di)
	movb $0xFF, %ds:(%si)
	cmpb $0xFF, %es:(%di)

	# Restore contents at ds:si
	popw %ax
	movb %al, %ds:(%si)

	# Restore contents at es:di
	popw %ax
	movb %al, %es:(%di)

	movw $0x0, %ax
	je test_a20_exit
	movw $0x1, %ax

test_a20_exit:
	sti
	popw %si
	popw %di
	popw %ds
	popw %es
	popw %bp
	ret

# Could not find official documentation for that interrupt subfunction,
# so I was not able to give 0x2401 accurate macro names.
enable_a20_bios:
	pushw %bp
	movw %sp, %bp

	movw $0x2401, %ax
	int $BIG_MEM_SRV_INT 

	popw %bp
	ret

# Arguments
#	No arguments.
# Clobber:

# Arguments:
#	No arguments.
# Clobber:
#	ES, DI, AX, BX, DX, CX
detect_mem:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %es
	pushw %di
	pushw %bx
	pushw %cx
	pushw %dx

detect_mem_loop_entry:
	movl $MEM_MAP_BUF_PHYS_ADDR, mem_map_buf  
	movb $0x0, mem_map_buf_n

	# Set buffer location
	movw $MEM_MAP_BUF_BEGIN_SEGMENT, %ax
	movw %ax, %es
	movw $MEM_MAP_BUF_BEGIN_OFFSET, %ax
	movw %ax, %di

	# Set function
	movb $BIG_MEM_SIZE_AH, %ah
	movb $SYS_MEM_MAP_AL, %al

	xor %bx, %bx
	movw $MEM_MAP_STRUCT_SIZE, %cx
	movl $SMAP, %edx	# 'SMAP' Signature

detect_mem_loop_body:
	int $BIG_MEM_SRV_INT
	incb mem_map_buf_n

detect_mem_loop_check:
	cmpl $SMAP, %eax 
	jne detect_mem_abort
	cmpw $0x0, %bx  
	je detect_mem_loop_exit 

detect_mem_loop_update:
	addw $MEM_MAP_STRUCT_SIZE, %di
	movw $MEM_MAP_STRUCT_SIZE, %cx

	# Set function
	movb $BIG_MEM_SIZE_AH, %ah
	movb $SYS_MEM_MAP_AL, %al
	jmp detect_mem_loop_body

detect_mem_abort:
	movw $0x0, %ax
	movw %ax, %ds
	movw $mem_map_error, %ax
	movw %ax, %si
	call abort

detect_mem_loop_exit:
	popw %dx
	popw %cx
	popw %bx
	popw %di
	popw %es
	popw %ax
	popw %bp
	ret

# Arguments:
#	DS - Segment where error string is located
#	SI - Offset where error string is located
abort:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si


	# Store arguments
	sub $4, %sp
	movw %ds, -4(%bp)
	movw %si, -2(%bp)

	# Print error string prefix
	movw $0x0, %ax
	movw %ax, %ds
	movw $error_prefix_str, %ax
	movw %ax, %si
	call print
	
	# Retrieve arguments
	movw -4(%bp), %ds
	movw -2(%bp), %si
	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	jmp hang

print_newline:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $newline_str, %ax
	movw %ax, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

print_testing_a20:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $testing_a20_str, %ax
	movw %ax, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

print_a20_is_enabled:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $a20_is_enabled_str, %ax
	movw %ax, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

print_a20_is_disabled:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $a20_is_disabled_str, %ax
	movw %ax, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

print_enable_a20_bios:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $trying_a20_bios, %ax
	movw %ax, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

# Arguments:
#	No arguments
print_bootloader2_loaded:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $bootloader2_loaded_str, %ax
	movw %ax, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

# Arguments
#	No arguments
print_mem_detected:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %dx
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $mem_detected_str, %ax
	movw %ax, %si

	call print

	popw %si
	popw %dx
	popw %ax
	popw %bp
	ret

# Arguments:
#	No arguments
print_error:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $error_str, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret
	
# Arguments:
#	No arguments
print_success:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $success_str, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

print_failed:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $failed_str, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

# Arguments:
#	No arguments
print_end:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $end_str, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

# Arguments:
#	DS - Segment where string is located
#	SI - Offset where string is located
print:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %bx

print_loop:
	cld
	lodsb
	or %al, %al
	jz print_loop_exit 
	movb $0x0, %bh
	movb $VIDEO_WCHAR_FN, %ah
	int $VIDEO_INT
	jmp print_loop

print_loop_exit:
	popw %bx
	popw %ax
	pop %bp
	ret

hang:
	jmp hang

.section .data
newline_str:
	.asciz "\n\r"
bootloader2_loaded_str:
	.asciz "Bootloader 2 loaded...\n\r"
mem_detected_str:
	.asciz "Memory detected...\n\r"
testing_a20_str:
	.asciz "Testing A20... "
a20_is_enabled_str:
	.asciz "A20 enabled!"
a20_is_disabled_str:
	.asciz "A20 disabled!"
trying_a20_bios:
	.asciz "Trying to enable A20 through BIOS... "
end_str:
	.asciz "End of execution."	
mem_map_error:
	.asciz "Error detecting memory."
success_str:
	.asciz "Success!"
failed_str:
	.asciz "Failed!"
error_str:
	.asciz "Error!"
error_prefix_str:
	.asciz "Error: "

.section .bss
mem_map_buf:
	.space 8
mem_map_buf_n:
	.space 1
