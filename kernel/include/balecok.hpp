#ifndef BALECOK_H
#define BALECOK_H

#include "types.hpp"

void* operator new(uint64_t size);
void operator delete(void* p);

void* operator new[](uint64_t size);
void operator delete[](void* p);
#endif
