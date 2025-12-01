AS      = nasm
ASFLAGS = -f bin -Wall
TARGET  = boos.bin          # always your 512-byte boot sector / MBR
SOURCE  = boos.asm

# Default = just build the boot sector
all: bootsector

# Assemble
$(TARGET): $(SOURCE)
	$(AS) $(ASFLAGS) $< -o $@ -l boos.lst

# Force exactly 512 bytes + 0x55AA signature
bootsector: $(TARGET)
	truncate -s 512 $(TARGET)
	printf '\x55\xAA' | dd of=$(TARGET) bs=1 seek=510 count=2 conv=notrunc status=none 2>/dev/null

# ——— FLOPPY USE-CASE ———
run-floppy: bootsector
	qemu-system-i386 -fda $(TARGET),format=raw

floppy.img: bootsector
	dd if=/dev/zero of=floppy.img bs=1024 count=1440 status=none
	dd if=$(TARGET) of=floppy.img bs=512 count=1 conv=notrunc status=none

# ——— HARD-DISK USE-CASE ———
run-disk: bootsector disk.img insert
	qemu-system-i386 -drive file=disk.img,format=raw,if=ide,index=0,media=disk

disk.img:
	qemu-img create -f raw disk.img 100M
	dd if=/dev/zero of=disk.img bs=512 count=204800 status=none   # 100 MB exactly

insert: bootsector disk.img
	dd if=$(TARGET) of=disk.img bs=512 count=1 conv=notrunc status=none 2>/dev/null

# ——— CONVENIENCE ———
run: run-disk          
clean:
	rm -f $(TARGET) boos.lst *.img

.PHONY: all bootsector run run-floppy run-disk insert disk.img floppy.img clean