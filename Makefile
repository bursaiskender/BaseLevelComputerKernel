default: start-qemu

MICRO_KERNEL_SRC=$(wildcard micro_kernel/*.asm)
MICRO_KERNEL_UTILS_SRC=$(wildcard micro_kernel/utils/*.asm)

bootloader.bin: bootloader/balecokBaseBootloader.asm
	nasm -w+all -f bin -o bootloader.bin bootloader/balecokBaseBootloader.asm

micro_kernel.bin: $(MICRO_KERNEL_SRC) $(MICRO_KERNEL_UTILS_SRC)
	nasm -w+all -f bin -o micro_kernel.bin micro_kernel/micro_kernel.asm
	
KERNEL_FLAGS=-masm=intel -Ikernel/include/ -O1 -std=c++11 -Wall -Wextra -fno-exceptions -fno-rtti -ffreestanding
KERNEL_LINK_FLAGS=-std=c++11 -T linker.ld -ffreestanding -O1 -nostdlib
KERNEL_O_FILES=kernel.o keyboard.o console.o kernel_utils.o

kernel.o: kernel/src/kernel.cpp
	g++ $(KERNEL_FLAGS) -c kernel/src/kernel.cpp -o kernel.o

keyboard.o:	kernel/src/keyboard.cpp
	g++ $(KERNEL_FLAGS) -c kernel/src/keyboard.cpp -o keyboard.o
 
console.o: kernel/src/console.cpp
	g++ $(KERNEL_FLAGS) -c kernel/src/console.cpp -o console.o

kernel_utils.o: kernel/src/kernel_utils.cpp
	g++ $(KERNEL_FLAGS) -c kernel/src/kernel_utils.cpp -o kernel_utils.o

kernel.bin: $(KERNEL_O_FILES)
	g++ $(KERNEL_LINK_FLAGS) -o kernel.bin.o $(KERNEL_O_FILES)
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
	
devMicro: 
	geany $(MICRO_KERNEL_SRC) $(MICRO_KERNEL_UTILS_SRC)
	
devCpp:
	geany kernel/src/*.cpp

devBoot:
	geany bootloader/*.asm
	
devEnv:
	geany $(MICRO_KERNEL_SRC) $(MICRO_KERNEL_UTILS_SRC) bootloader/*.asm kernel/src/*.cpp
clean:
	rm -rf bootloader.bin
	rm -rf balecok.bin
	rm -rf kernel.bin
	rm -rf balecok.iso
	rm -rf kernel.o
	rm -rf console.o
	rm -rf kernel_utils.o
	rm -rf keyboard.o
	rm -rf kernel.bin.o
	rm -rf kernel.bin
	rm -rf micro_kernel.bin
