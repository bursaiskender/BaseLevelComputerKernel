#include "memory.hpp"
#include "timer.hpp"
#include "shell.hpp"
#include "keyboard.hpp"
#include "disks.hpp"

extern "C" {
void _init();

void  __attribute__ ((section ("main_section"))) kernel_main(){
    load_memory_map();
    init_memory_manager();
    install_timer();
    keyboard::install_driver();
    disks::detect_disks();
    _init();
    init_shell();

    return;
}
}
