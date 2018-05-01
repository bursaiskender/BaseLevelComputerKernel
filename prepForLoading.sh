let filler_size=512-`stat -c%s kernel.bin`
dd if=/dev/zero of=filler.bin bs=1 count=$filler_size
