#ifndef STRING_H
#define STRING_H

#include "types.hpp"

struct string {
public:
    typedef char*             iterator;
    typedef const char*       const_iterator;

private:
    char* _data;
    size_t _size;
    size_t _capacity;

public:
    string();
    string(const char* s);
    explicit string(size_t capacity);


    string(const string& rhs);
    string& operator=(const string& rhs);


    string(string&& rhs);
    string& operator=(string&& rhs);


    ~string();
    
    void clear();
    
    size_t size() const;
    size_t capacity() const;
    
    bool empty() const;
    
    const char* c_str() const;
    
    string operator+(char c) const;
    string& operator+=(char c);

    iterator begin();
    iterator end();

    const_iterator begin() const;
    const_iterator end() const;
};

#endif
