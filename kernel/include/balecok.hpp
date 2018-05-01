#ifndef BALECOK_H
#define BALECOK_H

#include <new>

#include "memory.hpp"

void* operator new (size_t size);
void operator delete (void *p);

#endif
