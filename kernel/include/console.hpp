#ifndef CONSOLE_H
#define CONSOLE_H

#include "types.hpp"
#include "enable_if.hpp"
#include "string.hpp"

void set_column(long column);
long get_column();

void set_line(long line);
long get_line();

void wipeout();
void k_print(char key);
void k_print(const char* string);
void k_print(const char* string, uint64_t end);

void k_print(const string& s);

void k_print(uint8_t number);
void k_print(uint16_t number);
void k_print(uint32_t number);
void k_print(uint64_t number);

void k_printf(const char* fmt, ...);

void next_line();

template<typename... Arguments>
typename enable_if<(sizeof...(Arguments) == 0), void>::type k_print_line(const Arguments&... args){
    k_print('\n');
}

template<typename... Arguments>
typename enable_if<(sizeof...(Arguments) > 0), void>::type k_print_line(const Arguments&... args){
    k_print(args...);
    k_print('\n');
}

#endif
