default: start-qemu

KERNEL_SRC=$(wildcard src/*.asm)
KERNEL_UTILS_SRC=$(wildcard src/utils/*.asm)

bootloader.bin: src/bootloader/balecokBaseBootloader.asm
	nasm -f bin -o bootloader.bin src/bootloader/balecokBaseBootloader.asm

micro_kernel.bin: $(KERNEL_SRC) $(KERNEL_UTILS_SRC)
	nasm -f bin -o micro_kernel.bin src/micro_kernel.asm

kernel.o: src/kernel.cpp
	g++ -Wall -Wextra -O2 -fno-exceptions -fno-rtti -ffreestanding -c src/kernel.cpp -o kernel.o

kernel.bin: kernel.o
	ld -e kernel_main -Ttext 0x10000 -o kernel.bin.o kernel.o
	ld -i -e kernel_main -Ttext 0x1000 -o kernel.bin.o kernel.o
	objcopy -R .note -R .comment -S -O binary kernel.bin.o kernel.bin
	
balecok.iso: bootloader.bin micro_kernel.bin kernel.bin
	cat bootloader.bin > balecok.bin
	cat micro_kernel.bin >> balecok.bin
	cat kernel.bin >> balecok.bin
	dd status=noxfer conv=notrunc if=balecok.bin of=balecok.iso

start-qemu: balecok.iso
	qemu-system-x86_64 -fda balecok.iso

start-bochs: balecok.iso
	bochs -q -f .bochsConfig
	
devEnv: src/* src/bootloader/*.asm src/utils/*.asm
	geany src/*.asm src/bootloader/*.asm src/utils/*.asm src/*.cpp
	
clean:
	rm -rf bootloader.bin
	rm -rf balecok.bin
	rm -rf kernel.bin
	rm -rf balecok.iso
	rm -rf kernel.o
	rm -rf kernel.bin.o
	rm -rf kernel.bin
