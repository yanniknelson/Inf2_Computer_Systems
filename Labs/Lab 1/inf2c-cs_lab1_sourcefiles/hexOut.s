# Prints a number in hexadecimal, digit by digit.
# 
# Written by Aris Efthymiou, 16/08/2005
# Based on hex.s program from U. of Manchester for the ARM ISA

        .data
prompt1:        .asciiz  "Enter decimal number.\n"
outmsg:         .asciiz  "The number in hex representation is:\n"

        .globl main

        .text
main:   
        # prompt for input
        li   $v0, 4
        la   $a0, prompt1
        syscall

        # Get number from user
        li   $v0, 5
        syscall

        add  $s0, $zero, $v0  # Keep the number in $s0,

        # Output message
        li   $v0, 4
        la   $a0, outmsg
        syscall

        # set up the loop counter variable
        li   $t0, 8  # 8 hex digits in a 32-bit number

        # Main loop
loop:   srl  $t1, $s0, 28  # get leftmost digit by shifting it
                           # to the 4 least significant bits of $t1

        # The following instructions convert the number to a char
        slti $t2, $t1, 10  # t2 is set to 1 if $t1 < 10
        bgtz $t7, nocheck # if the no check flag 
        beq  $t1,$zero, noprint
        addi $t7, $zero, 1 # t7 acts as a flag variable for the zero check
nocheck:
        beq  $t2, $0,  over10
        addi  $t1, $t1, 48 # ASCII for '0' is 48
        j    print
        
#note for two's complement, xor with -1 to flip bits then add 1
        
over10: addi  $t1, $t1, 55 # convert to ASCII for A-F
                           # ASCII code for 'A' is 65
                           # Use 55 because $t1 is over 10

        # Print one digit
print:  li   $v0, 11
        add  $a0, $zero, $t1
        syscall            # Print ASCII char in $a0
noprint:
        # Prepare for next iteration
        sll  $s0, $s0, 4   # Drop current leftmost digit
        addi $t0, $t0, -1  # Update loop counter
        bne  $t0, $0, loop # Still not 0?, go to loop

        # end the program
        li   $v0, 10
        syscall

