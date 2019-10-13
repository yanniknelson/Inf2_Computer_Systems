
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
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

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!

.align 4
dictionary_idx:		.space 4000
default_ret:		.asciiz "-1\n"
horizontal_label:	.asciiz " H "
vertical_label:		.asciiz " V "
diagonal_label:		.asciiz " D "

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
	sw $t1, dictionary_idx($t2) # dictionary_idx[dict_index] = start_index
	addi $t2, $t2, 4 # dict_index++      dictionary_idx will use words as using bytes limits it's maximum storable index to 255, which won't work if the dictionary is full
	add $t1, $t0, 1 # start_index = idx + 1 
WORD_SKIP: # }
	addi $t0, $t0, 1 # idx += 1;
	j WORD_LOOP # } while(1);
END_WORD: 

	move $s0, $t2 # dict_num_words = dict_index;
	sra $s0, $s0, 2 # dict_num_words / 4 (to get number of words not number of bytes used)
	
	move $s1, $0 # linewidth = 0;
	addi $t2, $0, 10 # '\n'
FIND_LINE_WIDTH_LOOP:
	lb $t1, grid($s1) # grid[linewidth]
	beq $t1, $t2, END_LINE_WIDTH_LOOP # while (grid[linewidth != '\n') {
	addi $s1, $s1, 1
	j FIND_LINE_WIDTH_LOOP # }
END_LINE_WIDTH_LOOP:
	addi $s1, $s1, 1
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
	move $t3, $0 # found = 0;
	move $t0,  $0 # idx = 0;
	move $t1, $0 # grid_idx = 0;
FIND_WHILE:
	lb $t7, grid($t1) # $t7 = grid[grid_idx]
	beqz $t7, END_FIND_WHILE # while(grid[grid_idx] != '\0') {
	move $t0, $0 # for (idx = 0;
	FIND_FOR:
		bge $t0, $s0, END_FIND_FOR # idx < dict_num_words;
		
		
		
		# save all variables to stack
		addi $sp, $sp, -4
		sw $ra, 0($sp) # save return address
		addi $sp, $sp, -4
		sw $t0, 0($sp) # save idx
		addi $sp, $sp, -4
		sw $t1, 0($sp) # save grid_idx
		addi $sp, $sp, -4
		sw $t3, 0($sp) # save found
		
		
		# call contain for horizontal
		sll $t7, $t0, 2 # idx * 4 to make it word aligned
		lb $t2, dictionary_idx($t7) # dictionary_idx[idx * 4]
		add $a0, $t1, $0 # pass grid_idx
		lb $a1, dictionary_idx($t7) # pass dictionary_idx[idx]
		addi $a2, $0, 1 # pass 1 for inc (horizontal
		jal CONTAIN # contain(grid + grid_idx, word)
		
		
		# get all variables back
		lw $t3, 0($sp) # load found
		addi $sp, $sp, 4
		lw $t1, 0($sp) # load grid_idx
		addi $sp, $sp, 4
		lw $t0, 0($sp) # idx
		addi $sp, $sp, 4
		lw $ra, 0($sp) # load return address
		addi $sp, $sp, 4
		
		
		beqz $v0, NOT_HORIZONTAL # if (contain(grid + grid_idx, word)){
			addi $t3, $0, 1 # found = 1;
		
			# this prints all the data
			addi $v0, $0, 1
			add $a0, $t1, $0
			div $a0, $s1 # lo = grid_index div linewidth   hi = grid_index mod linewidth
			mflo $a0
			syscall # print_int(grid_index / linewidth)
			addi $v0, $0, 11
			addi $a0, $0, 44
			syscall # print_char(',');
			addi $v0, $0, 1
			mfhi $a0
			syscall # print_int(grid_index % linewidth)
			la $a0, horizontal_label
			addi $v0, $0, 4
			syscall # printf(" H ");
			addi $v0, $0, 11 # print characters
			sll $t7, $t0, 2 # multiply idx by 4 for word alignment
			lb $t5, dictionary_idx($t7) # get the index first character of the word and put it in $t5
			addi $t6, $0, 10 # $t6 = '\n'
			HPRINT_LOOP:
				lb $a0, dictionary($t5) # get character
				beq $a0, $t6, END_HPRINT_LOOP # if the character is a linebreak stop the print loop otherwise
					syscall # print the character
					addi $t5, $t5, 1 # move to the next pointer
					j HPRINT_LOOP # go back to the start of the print loop
			END_HPRINT_LOOP:
			addi $a0, $0, 10
			syscall # printf('\n');
		
		
		NOT_HORIZONTAL: #}
		
		# save all variables to stack
		addi $sp, $sp, -4
		sw $ra, 0($sp) # save return address
		addi $sp, $sp, -4
		sw $t0, 0($sp) # save idx
		addi $sp, $sp, -4
		sw $t1, 0($sp) # save grid_idx
		addi $sp, $sp, -4
		sw $t3, 0($sp) # save found
		
		
		# call contain for vertical
		sll $t7, $t0, 2 # idx * 4 to make it word aligned
		lb $t2, dictionary_idx($t7) # dictionary_idx[idx * 4]
		add $a0, $t1, $0 # pass grid_idx
		lb $a1, dictionary_idx($t7) # pass dictionary_idx[idx]
		add $a2, $0, $s1 # pass linewidth for inc (vertical)
		jal CONTAIN # contain(grid + grid_idx, word)
		
		
		# get all variables back
		lw $t3, 0($sp) # load found
		addi $sp, $sp, 4
		lw $t1, 0($sp) # load grid_idx
		addi $sp, $sp, 4
		lw $t0, 0($sp) # idx
		addi $sp, $sp, 4
		lw $ra, 0($sp) # load return address
		addi $sp, $sp, 4
		
		
		beqz $v0, NOT_VERTICAL # if (contain(grid + grid_idx, word)){
			addi $t3, $0, 1 # found = 1;
		
			# this prints all the data
			addi $v0, $0, 1
			add $a0, $t1, $0
			div $a0, $s1 # lo = grid_index div linewidth   hi = grid_index mod linewidth
			mflo $a0
			syscall # print_int(grid_index / linewidth)
			addi $v0, $0, 11
			addi $a0, $0, 44
			syscall # print_char(',');
			addi $v0, $0, 1
			mfhi $a0
			syscall # print_int(grid_index % linewidth)
			la $a0, vertical_label
			addi $v0, $0, 4
			syscall # printf(" H ");
			addi $v0, $0, 11 # print characters
			sll $t7, $t0, 2 # multiply idx by for for word alignment
			lb $t5, dictionary_idx($t7) # get the index first character of the word and put it in $t5
			addi $t6, $0, 10 # $t6 = '\n'
			VPRINT_LOOP:
				lb $a0, dictionary($t5) # get character
				beq $a0, $t6, END_VPRINT_LOOP # if the character is a linebreak stop the print loop otherwise
					syscall # print the character
					addi $t5, $t5, 1 # move to the next pointer
					j VPRINT_LOOP # go back to the start of the print loop
			END_VPRINT_LOOP:
			addi $a0, $0, 10
			syscall # printf('\n');
		
		NOT_VERTICAL: # }
		
		# save all variables to stack
		addi $sp, $sp, -4
		sw $ra, 0($sp) # save return address
		addi $sp, $sp, -4
		sw $t0, 0($sp) # save idx
		addi $sp, $sp, -4
		sw $t1, 0($sp) # save grid_idx
		addi $sp, $sp, -4
		sw $t3, 0($sp) # save found
		
		
		# call contain for diagonal
		sll $t7, $t0, 2 # idx * 4 to make it word aligned
		lb $t2, dictionary_idx($t7) # dictionary_idx[idx * 4]
		add $a0, $t1, $0 # pass grid_idx
		lb $a1, dictionary_idx($t7) # pass dictionary_idx[idx]
		add $a2, $0, $s1 
		addi $a2, $a2, 1 # pass linewidth + 1 for inc (Diagonal)
		jal CONTAIN # contain(grid + grid_idx, word)
		
		
		# get all variables back
		lw $t3, 0($sp) # load found
		addi $sp, $sp, 4
		lw $t1, 0($sp) # load grid_idx
		addi $sp, $sp, 4
		lw $t0, 0($sp) # idx
		addi $sp, $sp, 4
		lw $ra, 0($sp) # load return address
		addi $sp, $sp, 4
		
		
		beqz $v0, NOT_DIAGONAL # if (contain(grid + grid_idx, word)){
			addi $t3, $0, 1 # found = 1;
		
			# this prints all the data
			addi $v0, $0, 1
			add $a0, $t1, $0
			div $a0, $s1 # lo = grid_index div linewidth   hi = grid_index mod linewidth
			mflo $a0
			syscall # print_int(grid_index / linewidth)
			addi $v0, $0, 11
			addi $a0, $0, 44
			syscall # print_char(',');
			addi $v0, $0, 1
			mfhi $a0
			syscall # print_int(grid_index % linewidth)
			la $a0, diagonal_label
			addi $v0, $0, 4
			syscall # printf(" H ");
			addi $v0, $0, 11 # print characters
			sll $t7, $t0, 2 # multiply idx by for for word alignment
			lb $t5, dictionary_idx($t7) # get the index first character of the word and put it in $t5
			addi $t6, $0, 10 # $t6 = '\n'
			DPRINT_LOOP:
				lb $a0, dictionary($t5) # get character
				beq $a0, $t6, END_DPRINT_LOOP # if the character is a linebreak stop the print loop otherwise
					syscall # print the character
					addi $t5, $t5, 1 # move to the next pointer
					j DPRINT_LOOP # go back to the start of the print loop
			END_DPRINT_LOOP:
			addi $a0, $0, 10
			syscall # printf('\n');
		
		NOT_DIAGONAL: # }
		
		addi $t0, $t0, 1 # idx ++;
		j FIND_FOR 
	END_FIND_FOR:
	addi $t1, $t1, 1 # grid_idx += 1;
	j FIND_WHILE # }
END_FIND_WHILE:
	bnez $t3, DONT_PRINT
	la $a0, default_ret
	addi $v0, $0, 4
	syscall # printf("-1\n");
	DONT_PRINT:
	jr $ra # return to cal
	
	
CONTAIN:
	li $t7, 1056 # save the largest possible index in $t7
	addi $t3, $0, 10 # $t3 = '\n'
	CONTAIN_WHILE:  # while (1) {
		lb $t0, grid($a0) # get *string
		lb $t1, dictionary($a1) # get *word
		beq $t0, $t3, END_OF_LINE # if (*string != '/n') do the rest of the stuff otherwise go to END_OF_LINE
		beq $t0, $t1, CONTAIN_CONTINUE # if (*string != *word){
			END_OF_LINE: # as in the c, we do the same check, jumping here simply avoid duplicating code, see bellow 
			seq $v0, $t1, $t3 # set return value to *word == '\n'
			jr $ra # return
		CONTAIN_CONTINUE: # }
		add $a0, $a0, $a2 # string += inc
		blt $t7, $a0, END_OF_LINE # if $a0 points outside of grid, check if the word being compared against has aslo ended, if so then it matches, if not then it doesn't
		addi $a1, $a1, 1 # word += 1
		j CONTAIN_WHILE # }
	END_CONTAIN_WHILE:
	move $v0, $0
	jr $ra # return 0
	
# END_OF_LINE:
#	seq $v0, $t1, $t3 # set retunr value to *word == '\n'
#	jr $ra # return
