#ifndef FAT32_H
#define FAT32_H

#include "disks.hpp"

namespace fat32 {

vector<disks::file> ls(const disks::disk_descriptor& disk, const disks::partition_descriptor& partition);
uint64_t free_size(const disks::disk_descriptor& disk, const disks::partition_descriptor& partition);

}

#endif
