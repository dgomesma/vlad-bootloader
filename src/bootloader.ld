ENTRY(bootloader2);

SECTIONS
{
	. = 0x7e00;

	.text : {
		*(.text) 
	}
	
	.data : {
		*(.data)
	}
}
