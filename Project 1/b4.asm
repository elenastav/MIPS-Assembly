# Hello, World!
.data                                                # Data declaration section
out_string: .asciiz "\nHello World! "                # String to be printed
message:    .asciiz "Please enter a character:\n"    # Message for the user
	
.text                        # Assembly language instructions go in text segment
main:                        # Start of code section

li $v0, 4	
la $a0, message
syscall                      # Printing the message for the user
	
li $v0, 12
syscall                      # Reading user's input as character

move $t0, $v0                # Storing the character

li $v0, 4 
la $a0, out_string
syscall                      # Printing out_string

li $v0, 11
move $a0, $t0
syscall                      # Printing user's character

li $v0, 10                   
syscall                      # Terminating program
