.data
message1:      .asciiz  "\nPlease enter the 1st number: " 
message2:      .asciiz  "\nPlease enter the operation: "
message3:      .asciiz  "\nPlease enter the 2nd number: "
out_message:   .asciiz  "\nThe result is: "
false_message: .asciiz  "\nDidn't recognize the operation."
zero_message:  .asciiz  "\nCouldn't make division with divisor 0."

.text
main:

li $v0, 4
la $a0, message1
syscall                               #Print message1 to ask for the 1st number

li $v0, 5
syscall                               #Read the number as integer

move $t0, $v0                         #Store the integer 

li $v0, 4
la $a0, message2
syscall                               #Print message2 to ask for the operation

li $v0, 12
syscall                               #Read the operation as character

move $t1, $v0                         #Store the character

li $v0, 4
la $a0, message3
syscall                               #Print message3 to ask for the 2nd number

li $v0, 5 
syscall                               #Read the number as integer

move $t2, $v0                         #Store the integer

beq $t1, 43, addition                 #Branch if the operation is addition

beq $t1, 45, subtraction              #Branch if the operation is subtraction

beq $t1, 42, multiplication           #Branch if the operation is multiplication

beq $t1, 47, division                 #Branch if the operation is division

j do_nothing                          #Else, jump to do_nothing

addition:                             #Add the numbers 
add $t4, $t0, $t2
j printing_result

subtraction:                          #Subtract the numbers
sub $t4, $t0, $t2
j printing_result

multiplication:                       #Multiply the numbers
mul $t4, $t0, $t2
j printing_result

division:                             #Divide the numbers
beq $t2, $0, zero_division            #Branch if the divisor is 0
div $t4, $t0, $t2
j printing_result

zero_division:                        #Print zero_message 
li $v0, 4
la $a0, zero_message
syscall

j terminating

printing_result:                      #Print out_message followed by the result of the operation
li $v0, 4
la $a0, out_message
syscall

li $v0, 1                        
move $a0, $t4
syscall 

j terminating

do_nothing:                           #Print false_message
li $v0, 4
la $a0, false_message
syscall

terminating:                          #Terminate the program
li $v0, 10
syscall
