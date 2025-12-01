    org 0x7C00
    bits 16
start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; stack just below boot sector

    ; Task 1: Print the digit '1' using BIOS int 10h, AH=0Eh
	mov ah, 0x0E
	mov al, '1'
	int 0x10
	;done
    ; Task 2: Reset floppy drive (int 13h, AH=00h) – do it, ignore return for now
	xor ah, ah
	int 0x13
	;done
    ; Task 3: Read exactly 1 sector from LBA 1 (which is the second sector)
    ;         to memory address 0x0000:0x7E00
    ;         Use int 13h, AH=02h
    ;         Parameters you must fill:
    ;           AL  = number of sectors (1)
    ;           CH  = cylinder   (0)
    ;           CL  = sector      (2)          ; because sector 1 is the boot sector
    ;           DH  = head        (0)
    ;           DL  = drive       (kept from BIOS entry, do NOT hardcode 0)
    ;           ES:BX = 0000:7E00
	mov al, 1
	xor ch, ch
	mov cl, 2
	xor dh, dh
	mov bx, 0x7E00
	mov ah, 0x02
	int 0x13
	;done
    ; Task 4: Check CF. If set (error), print "E" and halt
	jc .disk_err
	;done
    ; Task 5: Far jump to 0x0000:0x7E00
	jmp 0x0000:0x7E00
	;done
    ; Task 6: Add boot signature at byte 510-511
.disk_err:
	mov si, err_msg
	call print_str
	jmp $
	
print_str:
	lodsb
	cmp al, 0
	je .done
	mov ah, 0x0E
	xor	bh, bh
	int 0x10
	jmp print_str
.done
	ret
	
err_msg db 'E', 0

    times 510-($-$$) db 0
    dw 0xAA55