
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 4
dictionary_idx:		.space 1000
default_ret:		.asciiz "-1\n"
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!
 	move $t1, $0 # start_index = 0;
	move $t2, $0 # dict_index = 0;
	move $t0, $0 # idx = 0;
WORD_LOOP: # do {
	lb $t3, dictionary($t0) # c_input = dictionary[idx];
	beqz $t3, END_WORD	# if (c_input == '/0'){
				#	break; 
				# }
	addi $t4, $0, 10
	bne $t3, $t4, WORD_SKIP # if (c_input == '/n'){
	sb $t1, dictionary_idx($t2) # dictionary_idx[dict_index] = start_index
	addi $t2, $t2, 1 # dict_index++
	add $t1, $t0, 1 # start_index = idx + 1 
WORD_SKIP: # }
	addi $t0, $t0, 1 # idx += 1;
	j WORD_LOOP # } while(1);
END_WORD: 

	move $s0, $t2 # dict_num_words = dict_index;
	
	jal STRFIND
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------

STRFIND:
	move $t0,  $0 # idx = 0;
	move $t1, $0 # grid_idx = 0;
FIND_WHILE:
	lb $t7, grid($t1) # $t7 = grid[grid_idx]
	beqz $t7, END_FIND_WHILE # while(grid[grid_idx] != '\0') {
	move $t0, $0 # for (idx = 0;
	FIND_FOR:
		bge $t0, $s0, END_FIND_FOR # idx < dict_num_words;
		lb $t2, dictionary_idx($t0) # dictionary_idx[idx]
		
		
		# save all variables to stack
		addi $sp, $sp, -4
		sw $ra, 0($sp) # save return address
		addi $sp, $sp, -4
		sw $t0, 0($sp) # save idx
		addi $sp, $sp, -4
		sw $t1, 0($sp) # save grid_idx
		
		
		# call contain
		add $a0, $t1, $0 # pass grid_idx
		lb $a1, dictionary_idx($t0) # pass dictionary_idx[idx]
		jal CONTAIN # contain(grid + grid_idx, word)
		
		
		# get all variables back
		lw $t1, 0($sp) # load grid_idx
		addi $sp, $sp, 4
		lw $t0, 0($sp) # idx
		addi $sp, $sp, 4
		lw $ra, 0($sp) # load return address
		addi $sp, $sp, 4
		
		
		beqz $v0, FIND_FOR_SKIP # if (contain(grid + grid_idx, word)){
		addi $v0, $0, 1
		add $a0, $t1, $0
		syscall # print_int(grid_index)
		addi $v0, $0, 11
		addi $a0, $0, 32
		syscall # printf(' ');
		
		lb $t5, dictionary_idx($t0)
		addi $t6, $0, 10
		PRINT_LOOP:
		lb $a0, dictionary($t5)
		beq $a0, $t6, END_PRINT_LOOP
		syscall
		addi $t5, $t5, 1
		j PRINT_LOOP
		END_PRINT_LOOP:
		
		addi $a0, $0, 10
		syscall # printf('\n');
		jr $ra # return
		FIND_FOR_SKIP:
		addi $t0, $t0, 1 # idx ++;
		j FIND_FOR 
	END_FIND_FOR:
	addi $t1, $t1, 1 # grid_idx += 1;
	j FIND_WHILE # }
END_FIND_WHILE:
	la $a0, default_ret
	addi $v0, $0, 4
	syscall # printf("-1\n");
	jr $ra # return to cal
	
	
CONTAIN:
	CONTAIN_WHILE:  # while (1) {
		lb $t0, grid($a0) # get *string
		lb $t1, dictionary($a1) # get *word
		
		beq $t0, $t1, CONTAIN_CONTINUE # if (*string != *word){
			addi $t3, $0, 10
			seq $v0, $t1, $t3 # set return value to *word == '\n'
			jr $ra # return
		CONTAIN_CONTINUE: # }
		addi $a0, $a0, 1 # string += 1
		addi $a1, $a1, 1 # word += 1
		j CONTAIN_WHILE # }
	END_CONTAIN_WHILE:
	move $v0, $0
	jr $ra # return 0
	
	
	
	
	
	