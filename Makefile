default: start-qemu

KERNEL_SRC=$(wildcard src/*.asm)
KERNEL_UTILS_SRC=$(wildcard src/utils/*.asm)

bootloader.bin: src/bootloader/balecokBaseBootloader.asm
	nasm -f bin -o bootloader.bin src/bootloader/balecokBaseBootloader.asm

micro_kernel.bin: $(KERNEL_SRC) $(KERNEL_UTILS_SRC)
	nasm -f bin -o micro_kernel.bin src/micro_kernel.asm
	
balecok.iso: bootloader.bin micro_kernel.bin
	cat bootloader.bin > balecok.bin
	cat micro_kernel.bin >> balecok.bin
	dd status=noxfer conv=notrunc if=balecok.bin of=balecok.iso

start-qemu: balecok.iso
	qemu-system-x86_64 -fda balecok.iso

start-bochs: balecok.iso
	bochs -q -f .bochsConfig
	
devEnv: src/* src/bootloader/*.asm src/utils/*.asm
	geany src/*.asm src/bootloader/*.asm src/utils/*.asm
	
clean:
	rm -rf bootloader.bin
	rm -rf balecok.bin
	rm -rf kernel.bin
	rm -rf balecok.iso
