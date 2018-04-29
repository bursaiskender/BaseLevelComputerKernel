# Bootloader
The BaLeCoK bootloader. 
## Code Description
### rm_start
Start the process in real mode

sets stack spaces and segments

sets data segments

prepares welcome screen

enables A20 gate

waits key for loading kernel

sets base to 0x100(0x0100:0x0 = 0x1000)

sets sectors to 0x20 for read

resets disk drives

reads sectors from mem
### reset_failed
prints read_failed_msg 
### error_end
prints load_failed

make a fucking infinte loop
### defineds
header_* = for loading screen 

press_key_msg = a info msg for annoying the user to press any key 4 load the kernel

load_kernel = annoys the user when bootloader tries to load kernel

reset_failed_msg = annoys the user when disk reseting failed

load_failed = annoys the user kernel loading operation was not sucessfully made

### boot section
prepares the bootsector
