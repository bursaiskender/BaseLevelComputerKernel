#ifndef UNIQUE_PTR_H
#define UNIQUE_PTR_H

#include "balecok.hpp"

template<typename T>
struct default_delete {
    default_delete() {}

    template<typename Up>
    default_delete(const default_delete<Up>&) {}

    void operator()(T* ptr) const {
        static_assert(sizeof(T) > 0, "Type must be complete");
        delete ptr;
    }
};

template<typename T>
struct malloc_delete {
    malloc_delete() {}

    template<typename Up>
    malloc_delete(const malloc_delete<Up>&) {}

    void operator()(T* ptr) const {
        static_assert(sizeof(T) > 0, "Type must be complete");
        k_free(ptr);
    }
};

template <typename T, typename D = default_delete<T>>
class unique_ptr {
public:
    typedef T* pointer_type;
    typedef T element_type;
    typedef D deleter_type;

private:
    pointer_type pointer;
    deleter_type deleter;

public:
    unique_ptr() : pointer(pointer_type()), deleter(deleter_type()) {}

    explicit unique_ptr(pointer_type p) : pointer(p), deleter(deleter_type()) {}

    unique_ptr(unique_ptr&& u) : pointer(u.release()), deleter(u.get_deleter()) {}
    unique_ptr& operator=(unique_ptr&& u){
        reset(u.release());
        return *this;
    }

    ~unique_ptr(){
        reset();
    }

    unique_ptr(const unique_ptr& rhs) = delete;
    unique_ptr& operator=(const unique_ptr& rhs) = delete;

    element_type& operator*() const {
        return *get();
    }

    pointer_type operator->() const {
        return get();
    }

    pointer_type get() const {
        return pointer;
    }

    deleter_type get_deleter() const {
        return deleter;
    }

    operator bool() const {
        return get();
    }

    pointer_type release(){
        pointer_type p = pointer;
        pointer = nullptr;
        return p;
    }

    void reset(pointer_type p = pointer_type()){
        if(pointer != p){
            get_deleter()(pointer);
            pointer = nullptr;
        }
    }
};

#endif
