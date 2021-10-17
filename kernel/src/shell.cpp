#include "types.hpp"
#include "keyboard.hpp"
#include "kernel_utils.hpp"
#include "console.hpp"
#include "shell.hpp"
#include "timer.hpp"
#include "utils.hpp"
#include "memory.hpp"
#include "disks.hpp"
#include "vector.hpp"
#include "string.hpp"
#include "algorithms.hpp"

namespace {
vector<char*> history;
uint64_t history_index;
bool shift = false;

void reboot_command(const vector<string>& params);
void help_command(const vector<string>& params);
void uptime_command(const vector<string>& params);
void clear_command(const vector<string>& params);
void date_command(const vector<string>& params);
void sleep_command(const vector<string>& params);
void echo_command(const vector<string>& params);
void mmap_command(const vector<string>& params);
void memory_command(const vector<string>& params);
void disks_command(const vector<string>& params);
void partitions_command(const vector<string>& params);
void mount_command(const vector<string>& params);
void unmount_command(const vector<string>& params);
void ls_command(const vector<string>& params);
void free_command(const vector<string>& params);
void cd_command(const vector<string>& params);
void pwd_command(const vector<string>& params);

struct command_definition {
    const char* name;
    void (*function)(const vector<string>&);
};

command_definition commands[17] = {
    {"reboot", reboot_command},
    {"help", help_command},
    {"uptime", uptime_command},
    {"clear", clear_command},
    {"date", date_command},
    {"sleep", sleep_command},
    {"echo", echo_command},
    {"mmap", mmap_command},
    {"memory", memory_command},
    {"disks", disks_command},
    {"partitions", partitions_command},
    {"mount", mount_command},
    {"unmount", unmount_command},
    {"ls", ls_command},
    {"free", free_command},
    {"cd", cd_command},
    {"pwd", pwd_command},
};


uint64_t current_input_length = 0;
char current_input[50];

void exec_command();

void start_shell(){
    while(true){
        auto key = keyboard::get_char();

        if(key & 0x80){
            key &= ~(0x80);
            if(key == keyboard::KEY_LEFT_SHIFT || key == keyboard::KEY_RIGHT_SHIFT){
                shift = false;
            }
        } 
        else {
            if(key == keyboard::KEY_ENTER){
                current_input[current_input_length] = '\0';

                k_print_line();


                if(current_input_length > 0){
                    exec_command();

                    if(get_column() != 0){
                        k_print_line();
                    }

                    current_input_length = 0;
                }

                k_print("root@balecok # ");
            } else if(key == keyboard::KEY_LEFT_SHIFT || key == keyboard::KEY_RIGHT_SHIFT){
                shift = true;
            } else if(key == keyboard::KEY_UP || key == keyboard::KEY_DOWN){
                if(history.size() > 0){
                    if(key == keyboard::KEY_UP){
                        if(history_index == 0){
                            continue;
                        }

                        --history_index;
                    } else {
                        if(history_index == history.size()){
                            continue;
                        }

                        ++history_index;
                    }

                    set_column(6);

                    for(uint64_t i = 0; i < current_input_length; ++i){
                        k_print(' ');
                    }

                    set_column(6);

                    current_input_length = 0;

                    if(history_index < history.size()){
                        auto saved = history[history_index];
                        while(*saved){
                            current_input[current_input_length++] = *saved;
                            k_print(*saved);

                            ++saved;
                        }
                    }
                }
            } else if(key == keyboard::KEY_BACKSPACE){
                if(current_input_length > 0){
                    k_print('\b');
                    --current_input_length;
                }
            } else {
                auto qwerty_key = 
                    shift
                    ? keyboard::shift_key_to_ascii(key)
                    : keyboard::key_to_ascii(key);

                if(qwerty_key){
                    current_input[current_input_length++] = qwerty_key;
                    k_print(qwerty_key);
                }
            }
        }
    }
}

void exec_command(){
    char buffer[50];
    auto saved = new char[current_input_length + 1];
    memcopy(saved, current_input, current_input_length);
    saved[current_input_length] = '\0';

    history.push_back(saved);
    history_index = history.size();
    for(auto& command : commands){
        const char* input_command = current_input;
        if(str_contains(current_input, ' ')){
            str_copy(current_input, buffer);
            input_command = str_until(buffer, ' ');
        }

        if(str_equals(input_command, command.name)){
            auto params = split(string(current_input));;
            command.function(params);

            return;
        }
    }

    k_printf("The command \"%s\" does not exist\n", current_input);
}

void clear_command(const vector<string>&){
    wipeout();
}

void reboot_command(const vector<string>&){
    interrupt<60>();
}

void help_command(const vector<string>&){
    k_print("Available commands:\n");

    for(auto& command : commands){
        k_print('\t');
        k_print_line(command.name);
    }
}

void uptime_command(const vector<string>&){
    k_printf("Uptime: %ds\n", timer_seconds());
}

#define CURRENT_YEAR        2018
#define century_register    0x00
#define cmos_address        0x70
#define cmos_data           0x71

int get_update_in_progress_flag() {
      out_byte(cmos_address, 0x0A);
      return (in_byte(cmos_data) & 0x80);
}

uint8_t get_RTC_register(int reg) {
      out_byte(cmos_address, reg);
      return in_byte(cmos_data);
}

void date_command(const vector<string>&){
    uint64_t second;
    uint64_t minute;
    uint64_t hour;
    uint64_t day;
    uint64_t month;
    uint64_t year;

    uint64_t last_second;
    uint64_t last_minute;
    uint64_t last_hour;
    uint64_t last_day;
    uint64_t last_month;
    uint64_t last_year;
    uint64_t registerB;

    while (get_update_in_progress_flag()){};                

    second = get_RTC_register(0x00);
    minute = get_RTC_register(0x02);
    hour = get_RTC_register(0x04);
    day = get_RTC_register(0x07);
    month = get_RTC_register(0x08);
    year = get_RTC_register(0x09);

    do {
        last_second = second;
        last_minute = minute;
        last_hour = hour;
        last_day = day;
        last_month = month;
        last_year = year;

        while (get_update_in_progress_flag()){};         

        second = get_RTC_register(0x00);
        minute = get_RTC_register(0x02);
        hour = get_RTC_register(0x04);
        day = get_RTC_register(0x07);
        month = get_RTC_register(0x08);
        year = get_RTC_register(0x09);
    } while( (last_second != second) || (last_minute != minute) || (last_hour != hour) ||
        (last_day != day) || (last_month != month) || (last_year != year) );

    registerB = get_RTC_register(0x0B);


    if (!(registerB & 0x04)) {
        second = (second & 0x0F) + ((second / 16) * 10);
        minute = (minute & 0x0F) + ((minute / 16) * 10);
        hour = ( (hour & 0x0F) + (((hour & 0x70) / 16) * 10) ) | (hour & 0x80);
        day = (day & 0x0F) + ((day / 16) * 10);
        month = (month & 0x0F) + ((month / 16) * 10);
        year = (year & 0x0F) + ((year / 16) * 10);

    }

    if (!(registerB & 0x02) && (hour & 0x80)) {
        hour = ((hour & 0x7F) + 12) % 24;
    }
    year += (CURRENT_YEAR / 100) * 100;
    if(year < CURRENT_YEAR){
        year += 100;
    }

    k_printf("%d.%d.%d %d:%.2d:%.2d\n", day, month, year, hour, minute, second);
}


void sleep_command(const vector<string>& params){
    sleep_ms(parse(params[1]) * 1000);
}

void echo_command(const vector<string>& params){
    for(uint64_t i = 1; i < params.size(); ++i){
        k_print(params[i]);
        k_print(' ');
    }
    k_print_line();
}

void mmap_command(const vector<string>&){
    if(mmap_failed()){
        k_print_line("The mmap was not correctly loaded from e820");
    } else {
        k_printf("There are %d mmap entry\n", mmap_entry_count());
        k_print_line("Base         End          Size                  Type");
        for(uint64_t i = 0; i < mmap_entry_count(); ++i){
            auto& entry = mmap_entry(i);

            k_printf("%.10h %.10h %.10h %8m %s\n",
                entry.base, entry.base + entry.size, entry.size, entry.size, str_e820_type(entry.type));
        }
    }
}


void memory_command(const vector<string>&){
    if(mmap_failed()){
        k_print_line("The mmap was not correctly loaded from e820");
    } else {
        k_printf("Total available memory: %m\n", available_memory());
        k_printf("Total used memory: %m\n", used_memory());
        k_printf("Total free memory: %m\n", free_memory());
        k_printf("Total allocated memory: %m\n", allocated_memory());
    }
}

void disks_command(const vector<string>&){
    k_print_line("UUID       Type");

    for(uint64_t i = 0; i < disks::detected_disks(); ++i){
        auto& descriptor = disks::disk_by_index(i);

        k_printf("%10d %s\n", descriptor.uuid, disks::disk_type_to_string(descriptor.type));
    }
}

void partitions_command(const vector<string>& params){
    auto uuid = parse(params[1]);

    if(disks::disk_exists(uuid)){
        auto partitions = disks::partitions(disks::disk_by_uuid(uuid));

        if(partitions.size() > 0){
            k_print_line("UUID       Type         Start      Sectors");

            for(auto& partition : partitions){
                k_printf("%10d %12s %10d %d\n", partition.uuid,
                    disks::partition_type_to_string(partition.type),
                    partition.start, partition.sectors);
            }
        }
    } else {
        k_printf("Disks %d does not exist\n", uuid);
    }
}

void mount_command(const vector<string>& params){
    if(params.size() == 1){
        auto md = disks::mounted_disk();
        auto mp = disks::mounted_partition();

        if(md && mp){
            k_printf("%d:%d is mounted\n", md->uuid, mp->uuid);
        } else {
            k_print_line("Nothing is mounted");
        }
    } else {
        auto disk_uuid = parse(params[1]);
        auto partition_uuid = parse(params[2]);

        if(disks::disk_exists(disk_uuid)){
            auto& disk = disks::disk_by_uuid(disk_uuid);
            if(disks::partition_exists(disk, partition_uuid)){
                disks::mount(disk, partition_uuid);
            } else {
                k_printf("Partition %d does not exist\n", partition_uuid);
            }
        } else {
            k_printf("Disk %d does not exist\n", disk_uuid);
        }
    }
}

void unmount_command(const vector<string>& ){
    if(!disks::mounted_partition() || !disks::mounted_disk()){
        k_print_line("Nothing is mounted");

        return;
    }

    disks::unmount();
}

void ls_command(const vector<string>& params){
    bool show_hidden_files = false;
    if(params.size() > 1){
        for(size_t i = 1; i < params.size(); ++i){
            // unuğtğğğağğğğmamamamammaa bennnnni
        }
    }
    if(!disks::mounted_partition() || !disks::mounted_disk()){
        k_print_line("Nothing is mounted");
        return;
    }
    auto files = disks::ls();

    for(auto& file : files){
        if(file.hidden && !show_hidden_files){
            continue;
        }
        k_print(file.name, 11);

        if(file.directory){
            k_print(" d ");
        } else {
            k_print(" f ");
        }

        if(file.hidden){
            k_print(" .h ");
        }

        if(file.system){
            k_print(" sys ");
        }
        k_print_line(file.size);
    }
}

void free_command(const vector<string>&){
    if(!disks::mounted_partition() || !disks::mounted_disk()){
        k_print_line("Nothing is mounted");

        return;
    }

    k_printf("Free size: %m\n", disks::free_size());
}

void pwd_command(const vector<string>&){
    auto cd = disks::current_directory();

    if(cd){
        k_print_line('/');
    } else {
        k_printf("/%s\n", cd);
    }
}

void cd_command(const vector<string>& params){
    if(params.size() == 1){
        disks::set_current_directory();
    } else {
        disks::set_current_directory(params[1]);
    }
}

}
void init_shell(){
    current_input_length = 0;
    history_index = 0;
    
    wipeout();

    k_print("root@balecok # ");
    
    start_shell();
}
