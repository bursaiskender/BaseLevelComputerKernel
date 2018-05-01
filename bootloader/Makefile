bootloader.bin: balecokBaseBootloader.asm
	nasm -w+all -f bin -o bootloader.bin balecokBaseBootloader.asm

devEnv: balecokBaseBootloader.asm intel_16.asm
	geany balecokBaseBootloader.asm intel_16.asm

clean:
	rm -f bootloader.bin
