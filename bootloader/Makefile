default: part1.bin part2.bin

part1.bin: part1.asm
	nasm -w+all -f bin -o part1.bin part1.asm

part2.bin: part2.asm
	nasm -w+all -f bin -o part2.bin part2.asm

clean:
	rm -f part1.bin
	rm -f part2.bin
