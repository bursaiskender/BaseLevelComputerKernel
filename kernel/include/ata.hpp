#ifndef ATA_H
#define ATA_H

#include "types.hpp"

namespace ata {

struct drive_descriptor {
    uint16_t controller;
    uint8_t drive;
    bool present;
    uint8_t slave;
};

void detect_disks();
uint8_t number_of_disks();
drive_descriptor& drive(uint8_t disk);

bool read_sectors(drive_descriptor& drive, uint64_t start, uint8_t count, void* destination);

}

#endif
