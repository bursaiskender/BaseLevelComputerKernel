balecokBootloader.bin: src/bootloader/balecok.asm
	nasm -f bin -o balecokBootloader.bin src/bootloader/balecok.asm

balecokBootloader.iso: balecokBootloader.bin
	dd status=noxfer conv=notrunc if=balecokBootloader.bin of=balecokBootloader.iso

start: balecokBootloader.iso
	qemu-system-x86_64 -fda balecokBootloader.iso

clean:
	rm -rf balecokBootloader.bin
	rm -rf balecokBootloader.iso
