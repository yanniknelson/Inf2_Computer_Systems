/*************************************************************************************|
|   1. YOU ARE NOT ALLOWED TO SHARE/PUBLISH YOUR CODE (e.g., post on piazza or online)|
|   2. Fill main.c and memory_hierarchy.c files                                       |
|   3. Do not use any other .c files neither alter main.h or parser.h                 |
|   4. Do not include any other library files                                         |
|*************************************************************************************/
#include "mipssim.h"

/// @students: declare cache-related structures and variables here
#define ADDRESS_SIZE 32
#define OFFSET_BITS 4

int index_size;

typedef enum Bool {False, True} Bool;

typedef struct cache_line {
    Bool valid;
    int tag;
    uint8_t block[16];
} cache_line;

cache_line* cache;

void print_tag(int tag){
    for (int i = arch_state.bits_for_cache_tag - 1; i > -1; i--){
        //printf("%d\n", i);
        if (tag >= pow(2,i)) {
            printf("1");
            tag -= pow(2,i);
        } else {
            printf("0");
        }
    }
}

void print_byte(uint8_t byte){
    for (int i = 7; i > -1; i--){
        if (byte >= pow(2,i)) {
            printf("1");
            byte -= pow(2,i);
        } else {
            printf("0");
        }
    }
}

void print_cache(){
    printf("~ current cache:\n");
    for (int i = 0; i < cache_size/16; i++){
        printf("|%d|", cache[i].valid);
        print_tag(cache[i].tag);
        printf("|");
        for (int j = 0; j < 16; j ++) {
            print_byte(cache[i].block[j]);
            printf("|");
        }
        printf("\n");
    }
}

Bool search_cache(int address){
    int tag = get_piece_of_a_word(address, 32-arch_state.bits_for_cache_tag, arch_state.bits_for_cache_tag);
    int index = get_piece_of_a_word(address, 4, index_size);
    //printf("%d, %d\n", tag, index);
    if (cache[index].tag == tag && cache[index].valid) {
        //printf("hit\n");
        return True;
    } 
    return False;
}



void memory_state_init(struct architectural_state* arch_state_ptr) {
    arch_state_ptr->memory = (uint32_t *) malloc(sizeof(uint32_t) * MEMORY_WORD_NUM);
    memset(arch_state_ptr->memory, 0, sizeof(uint32_t) * MEMORY_WORD_NUM);
    if(cache_size == 0){
        // CACHE DISABLED
        memory_stats_init(arch_state_ptr, 0); // WARNING: we initialize for no cache 0
    }else {
        // CACHE ENABLED
        index_size = ceil(log(cache_size/16)/log(2));
        printf("%d\n", index_size);
        int tag_bits = ADDRESS_SIZE - OFFSET_BITS - index_size; 
        printf("There are %d tag bits\n", tag_bits);
        memory_stats_init(arch_state_ptr, tag_bits);
        cache = malloc(cache_size/16 * sizeof(cache_line));
        for (int i = 0; i < cache_size/16; i++) {
            cache[i].valid = False;
            cache[i].tag = 0;
            //cache[i].block = malloc(16*sizeof(uint8_t));
            for (int j = 0; j < 16; j++) {
                cache[i].block[j] = 0;
            }
        }
        print_cache();
        /// @students: memory_stats_init(arch_state_ptr, X); <-- fill # of tag bits for cache 'X' correctly
    }
}


// returns data on memory[address / 4]
int memory_read(int address){
    //printf("read called\n");
    arch_state.mem_stats.lw_total++;
    check_address_is_word_aligned(address);
    if(cache_size == 0){
        // CACHE DISABLED
        return (int) arch_state.memory[address / 4];
    } else {
        // CACHE ENABLED
        int tag = get_piece_of_a_word(address, 32-arch_state.bits_for_cache_tag, arch_state.bits_for_cache_tag);
        int index = get_piece_of_a_word(address, 4, index_size);
        int offset = get_piece_of_a_word(address, 0, 4);
        if (search_cache(address)) {
            arch_state.mem_stats.lw_cache_hits++;
            //printf("get word %d\n",offset);
            int word = 0;
            for (int i = 0; i < 4; i++){
                //print_byte(cache[index].block[offset+i]);
                //printf("\n");
                word += cache[index].block[offset+i] << (8*(3-i));
            }
            //print_binary_32bit_or_less_lsb(word, 32);
            //printf("\n");
            return word;
        } else {
            cache[index].valid = 1;
            cache[index].tag = tag;
            int base_addr = address/16;
            
            for (int a = 0; a < 4; a++) {
                int data = (int) arch_state.memory[base_addr*4 + a];
                for (int b = 0; b < 4; b++) {
                    cache[index].block[a*4 + b] = get_piece_of_a_word(data, 32-(b+1)*8, 8);
                }
            }
            //print_cache();
            return (int) (int) arch_state.memory[address / 4];
        }

        assert(0); /// @students: Remove assert(0); and implement Memory hierarchy w/ cache
        /// @students: your implementation must properly increment: arch_state_ptr->mem_stats.lw_cache_hits
    }
    return 0;
}

// writes data on memory[address / 4]
void memory_write(int address, int write_data){
    //printf("incrementing sw total\n");
    arch_state.mem_stats.sw_total++;
    check_address_is_word_aligned(address);

    if(cache_size == 0){
        // CACHE DISABLED
        arch_state.memory[address / 4] = (uint32_t) write_data;
    }else{
        int index = get_piece_of_a_word(address, 4, index_size);
        int offset = get_piece_of_a_word(address, 0, 4);
        // CACHE ENABLED
        if (search_cache(address)){
            arch_state.mem_stats.sw_cache_hits++;
            for (int b = 0; b < 4; b++) {
                cache[index].block[offset + b] = get_piece_of_a_word(write_data, 32-(b+1)*8, 8);
            }
        }
        arch_state.memory[address/ 4] = (uint32_t) write_data;
    }
}
