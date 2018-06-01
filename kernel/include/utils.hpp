#ifndef UTILS_H
#define UTILS_H

#include "types.hpp"
uint64_t parse(const char* str, const char* end);
uint64_t parse(const char* str);
bool str_contains(const char* a, char c);
bool str_equals(const char* a, const char* b);
void str_copy(const char* a, char* b);
const char* str_until(char* a, char c);
const char* str_from(char* a, char c);

template<typename T>
void memcopy(T* destination, const T* source, uint64_t size){
    --source;
    --destination;

    while(size--){
        *++destination = *++source;
    }
}

#endif
