#ifndef MEMORY_H
#define MEMORY_H

#include "types.hpp"

struct mmapentry {
    uint64_t base;
    uint64_t size;
    uint64_t type;
};

const char* str_e820_type(uint64_t type);
void load_memory_map();
bool mmap_failed();
uint64_t mmap_entry_count();
const mmapentry& mmap_entry(uint64_t i);
void init_memory_manager();
void* k_malloc(uint64_t bytes);
void k_free(void* block);
template<typename T>
T* k_malloc(){
    return reinterpret_cast<T*>(k_malloc(sizeof(T)));
}
uint64_t available_memory();
uint64_t free_memory();
uint64_t used_memory();
uint64_t allocated_memory();
#endif
