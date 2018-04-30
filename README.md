## BaseLevelComputerKernel
A Computer Kernel in Base Level. 

### Build and Start
If you wanna start immediately you can type "make"
```
user@hostname ~/BaseLevelComputerKernel $ make
```
It compiles the micro kernel and runs it on qemu (you need qemu-system-x86_64)
#### Compile to Binary
```
user@hostname ~/BaseLevelComputerKernel $ make bootloader.bin
user@hostname ~/BaseLevelComputerKernel $ make micro_kernel.bin
```
#### Compile to ISO
```
user@hostname ~/BaseLevelComputerKernel $ make balecok.iso
```
#### Run it on qemu-system-x86_64
```
user@hostname ~/BaseLevelComputerKernel $ make start-qemu
```
#### Run it on bochs
```
user@hostname ~/BaseLevelComputerKernel $ make bochs
```
### Usage
Type "help" for available commands
