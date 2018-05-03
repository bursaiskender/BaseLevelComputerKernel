#ifndef BALECOK_H
#define BALECOK_H

#include "memory.hpp"

void* operator new (uint64_t size);
void operator delete (void *p);

#endif
