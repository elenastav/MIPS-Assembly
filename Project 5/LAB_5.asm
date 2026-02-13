.data
prompt_message:             .asciiz "\nPlease enter a number in the range 1-24, or -1 to quit: \n"
message_false:              .asciiz "\nThis number is outside the allowable range.\n"
output_string:     		    .asciiz "\nThe Fibonacci number F   is "
number_string:              .space 4

.text
main:

	Prompt_User:
		li $v0, 4                               #Print prompt_message
		la $a0, prompt_message
		syscall
	
		li $v0, 5                               #Read user's input as integer
		syscall

	addi $s0, $v0, 0                            #Store the integer in $s0
	addi $t1, $0, -1				            #Put the number -1 at $t1	
	beq $s0, $t1, terminate                     #Branch if the integer is -1
	addi $t1, $0, 24				            #Put the number 24 at $t1
	bgt $s0, $t1, False_Entry                   #Branch if the integer is greater than 24
    addi $t1, $0, -1				            #Put the number -1 at $t1
	blt $s0, $t1, False_Entry                   #Branch if the integer is less than -1

	addi $sp, $sp, -4							#Move $sp 4 bytes lower in the stack (make space for 1 word)
	sw $s0, 0($sp)                              #Store $s0 at the address of $sp (arguement)

	jal Fibonacci								#Call Fibonacci function

	lw $s1, 0($sp)                              #Load the value from the beginning of the stack to $s1 (return value)
	addi $sp, $sp, 4                            #Move $sp 4 bytes higher in the stack

	move $a0, $s0                               #Move the user's integer in $a0 (arguement)    
	jal Print_String                            #Call Print_String function

	li $v0, 1                                   #Print Fibonacci's return value               
	move $a0, $s1
	syscall
	
	j Prompt_User

	False_Entry:
		li $v0, 4                               #Print message_false       
		la $a0, message_false
		syscall

	j Prompt_User                                     

	terminate:                                  #Terminate the program
		li $v0, 10
		syscall

	Fibonacci:

		########################
		#     Register map:    #                    
		# M[$sp] -> n          # 
		# M[$sp+4] -> $ra      #
		# M[$sp+8] -> Fib(n+1) #
		# $t0 -> n             #
		# $t1 -> n-1           #
		# $t1 -> Fib(n-1)      #
		# $t2 -> n-2           #
		# $t2 -> Fib(n-2)      #
		########################

		lw $t0, 0($sp)                          #Load the arguement from the beginning of the stack to $t0
		addi $t1, $t0, -1                       #Decrease the value by 1
	
		addi $sp, $sp, -8                       #Move $sp 8 bytes lower in the stack (make space for 2 words)
		sw $ra, 4($sp)                          #Store $ra at the address of $sp+4
		sw $t1, 0($sp)                          #Store $t1 at the address of $sp (arguement)

		blt $t0, 2, end                         #Branch if the integer is 0 or 1
	
		jal Fibonacci                           #1st recursive call
	
		lw $t1, 0($sp)                          #Load the value from the beginning of the stack to $t1 (return value)
		lw $ra, 4($sp)                          #Load the value at the address of $sp+4 back to $ra
		addi $sp, $sp, 8                        #Move $sp 8 bytes higher in the stack
	
		lw $t0, 0($sp)                          #Reload the value that was initially stored at the beginning of the stack to $t0
		addi $t2, $t0, -2                       #Decrease the value by 2
	
		addi $sp, $sp, -12                      #Move $sp 12 bytes lower in the stack (make space for 3 words)
		sw $t1, 8($sp)                          #Store $t1 at the address of $sp+8
		sw $ra, 4($sp)                          #Store $ra at the address of $sp+4
		sw $t2, 0($sp)                          #Store $t2 at the address of $sp (arguement)

		jal Fibonacci                           #2nd recursive call
	
		lw $t2, 0($sp)                          #Load the value from the beginning of the stack to $t2 (return value)
		lw $ra, 4($sp)                          #Load the value at the address of $sp+4 back to $ra
		lw $t1, 8($sp)                          #Load the value at the address of $sp+8 back to $t1
		addi $sp, $sp, 12                       #Move $sp 12 bytes higher in the stack
	
		add $t0, $t1, $t2                       #Add the results of the 2 recursive calls
		sw $t0, 0($sp)                          #Store final result at the beginning of the stack (return value)
		jr $ra                                  #Return to line 30
	
		end:
			lw $ra, 4($sp)                      #Load the value at the address of $sp+4 back to $ra
			addi $sp, $sp, 8                    #Move $sp 8 bytes higher in the stack (whether it's 0 or 1, the return value is already at the beginning of the stack)
			jr $ra                              #Return to line 78 or line 92


	Print_String:
	
		########################################
		#First, convert the integer to a string#
		########################################
	
		move $t0, $a0                       	#Store the integer in $t0
		addi $t1, $zero, 10                 	#Set $t2 with value 10

		div $t0, $t1                        	#Divide the integer with 10
		mfhi $t2                            	#Store the remainder in $t2 (2nd digit of the integer)
		mflo $t3                            	#Store the quotient in $t3 (1st digit of the integer)

		addi $t2, $t2, 48                   	#Convert the 2nd digit to its ascii code
		addi $t3, $t3, 48                   	#Convert the 1st digit to its ascii code
		addi $t4, $zero, 10                 	#Set $t4 with 10 (ascii for \n)
	
		la $t0, number_string               	#Load the address of the number_tring to $t0

		beq $t3, 48, one_digit              	#Branch if the 1st digit is 0(one digit integer)
		sb $t3, 0($t0)                      	#Else(two digits integer), store the 1st digit to the string
		sb $t2, 1($t0)                      	#Store the 2nd digit to the string
		sb $t4, 2($t0)                      	#Store \n to the string
		j string_union                      	#Jump to string_union

		one_digit:
			sb $t2, 0($t0)                  	#Store the only digit of the integer to the string 
			sb $t4, 1($t0)                  	#Store \n to the string

		#########################################################################
		#Then, unite the string that contains the integer with the output_string#
		#########################################################################

		string_union:
			la $t1, output_string           	#Load the address of the output_string to $t1
			addi $t1, $t1, 23               	#Move $t1 to the 24th byte of the string (where the number must be put)

			byte_Loop:
				lb $t2, 0($t1)              	#Load byte from the output_string to $t2                   
				lb $t3, 0($t0)              	#Load byte from the number_string to $t3
	
				beq $t3, 10, end_Loop     	    #Branch if $t3 is '\n' (end of number_string) 
	
				move $t2, $t3               	#Replace the byte of output_string with the byte of number_string
	
				sb $t2, 0($t1)              	#Store byte from $t2 to the output_string  
				sb $t3, 0($t0)              	#Store byte from $t3 to the number_string
	
				addi $t1, $t1, 1            	#Move $t1 to the next byte
				addi $t0, $t0, 1	        	#Move $t0 to the next byte
				j byte_Loop                 	#Repeat the loop             
	
				end_Loop:                       
					addi $t2, $zero, 32     	#Set $t2 with 32 (ascii for space)                               
					sb $t2, 0($t1)              #Store byte from $t2 to the output_string
		
		li $v0, 4                               #Print output_string 
		la $a0, output_string
		syscall
	
		jr $ra									#Return to line 36			
