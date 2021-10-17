#ifndef VECTOR_H
#define VECTOR_H

#include "types.hpp"

template<typename T>
class vector {
public:
    typedef T                       value_type;
    typedef value_type*             pointer_type;
    typedef uint64_t                size_type;
    typedef value_type*             iterator;
    typedef const value_type*       const_iterator;

private:
    T* data;
    uint64_t _size;
    uint64_t _capacity;

public:
    vector() : data(nullptr), _size(0), _capacity(0) {}
    explicit vector(uint64_t c) : data(new T[c]), _size(0), _capacity(c) {}

    vector(const vector& rhs) = delete;
    vector& operator=(const vector& rhs) = delete;

    vector(vector&& rhs) : data(rhs.data), _size(rhs._size), _capacity(rhs._capacity) {
        rhs.data = nullptr;
        rhs._size = 0;
        rhs._capacity = 0;
    };

    vector& operator=(vector&& rhs){
        data = rhs.data;
        _size = rhs._size;
        _capacity = rhs._capacity;
        rhs.data = nullptr;
        rhs._size = 0;
        rhs._capacity = 0;
        
        return *this;
    }

    ~vector(){
        if(data){
            delete[] data;
        }
    }

    size_type size() const{
        return _size;
    }
    
    size_type capacity() const{
        return _capacity;
    }
    
    const value_type& operator[](size_type pos) const {
        return data[pos];
    }

    value_type& operator[](size_type pos){
        return data[pos];
    }

    void push_back(value_type& element){
        if(_capacity == 0){
            _capacity = 1;
            data = new T[_capacity];
        } else if(_capacity == _size){
            _capacity= _capacity * 2;
            auto new_data = new T[_capacity];

            for(size_type i = 0; i < _size; ++i){
                new_data[i] = data[i];
            }

            delete[] data;
            data = new_data;
        }

        data[_size++] = element;
    }
    
    iterator begin(){
        return iterator(&data[0]);
    }

    const_iterator begin() const {
        return const_iterator(&data[0]);
    }

    iterator end(){
        return iterator(&data[_size]);
    }

    const_iterator end() const {
        return const_iterator(&data[_size]);
    }
};

#endif
