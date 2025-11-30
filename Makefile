AS		= nasm
ASFLAGS = -f bin -Wall
TARGET  = boos.bin
SOURCE = boos.asm

all: bootsector

$(TARGET): $(SOURCE)
	$(AS) $(ASFLAGS) $< -o $@ -l boos.lst
	
bootsector: $(TARGET)
	@# Ensure exactly 512 bytes and ends with 0xAA55
	truncate -s 512 $(TARGET)
	@# Add boot signature if not already present
	printf '\x55\xAA' | dd of=$(TARGET) bs=1 seek=510 count=2 conv=notrunc status=none
	
run: bootsector
	qemu-system-i386 -fda $(TARGET)
	
run-bios: bootsector
	qemu-system-i386 -fda $(TARGET) -boot a

floppy.img: bootsector
	dd if=/dev/zero of=floppy.img bs=1024 count=1440
	dd if=$(TARGET) of=floppy.img bs=512 count=1 conv=notrunc

clean:
	rm -f $(TARGET) boos.lst *.img *.bin *.o

.PHONY: all clean run run-bios bootsector floppy.img