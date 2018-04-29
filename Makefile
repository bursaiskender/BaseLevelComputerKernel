default: start

bootloader.bin: src/bootloader/balecokBaseBootloader.asm
	nasm -f bin -o bootloader.bin src/bootloader/balecokBaseBootloader.asm

kernel.bin: src/kernel.asm
	nasm -f bin -o kernel.bin src/kernel.asm
	
balecok.iso: bootloader.bin kernel.bin
	cat bootloader.bin > balecok.bin
	cat kernel.bin >> balecok.bin
	dd status=noxfer conv=notrunc if=balecok.bin of=balecok.iso

start: balecok.iso
	qemu-system-x86_64 -fda balecok.iso

clean:
	rm -rf bootloader.bin
	rm -rf balecok.bin
	rm -rf kernel.bin
	rm -rf balecok.iso
