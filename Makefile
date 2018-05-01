default: start-qemu

KERNEL_SRC=$(wildcard src/*.asm)
KERNEL_UTILS_SRC=$(wildcard src/utils/*.asm)

bootloader.bin: src/bootloader/balecokBaseBootloader.asm
	nasm -w+all -f bin -o bootloader.bin src/bootloader/balecokBaseBootloader.asm

micro_kernel.bin: $(KERNEL_SRC) $(KERNEL_UTILS_SRC)
	nasm -w+all -f bin -o micro_kernel.bin src/micro_kernel.asm
	nasm -D DEBUG -g -w+all -f elf64 -o micro_kernel.g src/micro_kernel.asm

kernel.o: kernel/src/kernel.cpp
	g++ -masm=intel -Ikernel/include/ -O2 -std=c++11 -Wall -Wextra -fno-exceptions -fno-rtti -ffreestanding -c kernel/src/kernel.cpp -o kernel.o 
 
kernel.bin: kernel.o
	g++ -std=c++11 -T linker.ld -o kernel.bin.o -ffreestanding -O2 -nostdlib kernel.o
	objcopy -R .note -R .comment -S -O binary kernel.bin.o kernel.bin
	
filler.bin: kernel.bin
	bash prepForLoading.sh
	
balecok.iso: bootloader.bin micro_kernel.bin kernel.bin filler.bin
	cat bootloader.bin > balecok.bin
	cat micro_kernel.bin >> balecok.bin
	cat kernel.bin >> balecok.bin
	dd status=noxfer conv=notrunc if=balecok.bin of=balecok.iso

start-qemu: balecok.iso
	qemu-system-x86_64 -fda balecok.iso

start-bochs: balecok.iso
	bochs -q -f .bochsConfig
	
devEnv: src/* src/bootloader/*.asm src/utils/*.asm
	geany src/*.asm src/bootloader/*.asm src/utils/*.asm kernel/src/*.cpp
	
clean:
	rm -rf bootloader.bin
	rm -rf balecok.bin
	rm -rf kernel.bin
	rm -rf balecok.iso
	rm -rf kernel.o
	rm -rf kernel.bin.o
	rm -rf kernel.bin
