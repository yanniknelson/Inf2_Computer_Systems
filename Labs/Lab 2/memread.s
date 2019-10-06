# memread.s program for MIPS


    .data

inp: .word 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16

msg:.asciiz     "Reading array\n"
newline:.asciiz "\n"

    .globl main  # declare the global symbols of this program
                 # SPIM requires a "main" symbol, (think of symbol
                 #  as another name for label), which declares
                 #  where our program starts

    .text
                 # .text starts the text segment of the program,
                 # where the assembly program code is placed.

readarr:         # method to process an array

loop:
    beqz  $a2, end        # go to end if all array elements processed
    lw    $a0, 0($a1)     # load array element into reg $a0
    li    $v0, 1
    syscall               # print element
    la    $a0, newline
    li    $v0, 4
    syscall
    addi  $a2, $a2, -1    # decrement counter for elements left to be processed
    addi  $a1, $a1, 4     # increment address for next element
    j     loop            # end of iteration
end:   
    jr $ra                # return

main:   # This is the entry point of our program

    la    $a0, msg # make $a0 point to where the message is
    li    $v0, 4   # $v0 <- 4
    syscall        # Call the OS to print the message

    la $a1, inp    # array to be processed
    li $a2, 16     # size of array to be processed

    jal readarr
    
    # This is the standard way to end a program
    li    $v0, 10
    syscall        # end the program
