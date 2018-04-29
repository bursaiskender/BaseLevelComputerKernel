balecok.bin: src/balecok.asm
	nasm -f bin -o balecok.bin src/balecok.asm

balecok.iso: balecok.bin
	dd status=noxfer conv=notrunc if=balecok.bin of=balecok.iso

start: balecok.iso
	qemu-system-x86_64 -fda balecok.iso

clean:
	rm -rf balecok.bin
	rm -rf balecok.iso
