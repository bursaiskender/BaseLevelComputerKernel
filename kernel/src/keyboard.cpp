#include "keyboard.hpp"
#include "kernel_utils.hpp"
namespace{
    
char qwerty[128] =
{
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8',	
  '9', '0', '-', '=', '\b',
  '\t',			
  'q', 'w', 'e', 'r',	
  't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0,			
  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',	
 '\'', '`',   0,		
 '\\', 'z', 'x', 'c', 'v', 'b', 'n',			
  'm', ',', '.', '/',   0,				
  '*',
    0,	
  ' ',	
    0,	
    0,	
    0,   0,   0,   0,   0,   0,   0,   0,
    0,	
    0,	
    0,	
    0,	
    0,	
    0,	
  '-',
    0,	
    0,
    0,	
  '+',
    0,	
    0,	
    0,	
    0,	
    0,	
    0,   0,   0,
    0,	
    0,	
    0,	/*all of other keys are setted as undefined*/
};

const uint8_t BUFFER_SIZE = 64;

char input_buffer[BUFFER_SIZE];
volatile uint8_t start;
volatile uint8_t count;

void keyboard_handler(){
    auto key = static_cast<char>(in_byte(0x60));

    if(count == BUFFER_SIZE){} 
    else {
        auto end = (start + count) % BUFFER_SIZE;
        input_buffer[end] = key;
        ++count;
    }
}

}

void keyboard::install_driver(){
    register_irq_handler<1>(keyboard_handler);

    start = 0;
    count = 0;
}

char keyboard::get_char(){
    while(count == 0){
        __asm__  __volatile__ ("nop");
        __asm__  __volatile__ ("nop");
        __asm__  __volatile__ ("nop");
        __asm__  __volatile__ ("nop");
        __asm__  __volatile__ ("nop");
    }

    auto key = input_buffer[start];
    start = (start + 1) % BUFFER_SIZE;
    --count;

    return key;
}

char keyboard::key_to_ascii(uint8_t key){
    return qwerty[key];
}


