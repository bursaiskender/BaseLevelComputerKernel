default: part1.bin part2.bin padding.bin

part1.bin: part1.asm
	nasm -w+all -f bin -o part1.bin part1.asm

part2.bin: part2.asm
	nasm -w+all -f bin -o part2.bin part2.asm

padding.bin:
	dd if=/dev/zero of=padding.bin bs=512 count=34
	
clean:
	rm -f part1.bin
	rm -f part2.bin
