# Hello, World!
.data                                          # Data declaration section
string1:     .asciiz "\nHello, "               # String to be printed
string2:     .asciiz "World!\n"                # String to be printed
your_string: .space 20                         # Space allocation in memory
message:     .asciiz "Please enter text:\n"    # Message for the user 

.text                   # Assembly language instructions go in text segment
main:                   # Start of code section

li $v0, 4
la $a0, message
syscall                 # Printing the message for the user

li $v0, 8                     
la $a0, your_string
li $a1, 20
syscall                 # Reading user's input as text

li $v0, 4
la $a0, string1
syscall                 # Printing string1

li $v0, 4
la $a0, your_string
syscall                 # Printing user's string

li $v0, 4
la $a0, string2
syscall                 # Printing string2

li $v0, 10                    
syscall                 # Terminating the program