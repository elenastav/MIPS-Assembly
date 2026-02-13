.data
prompt_message:      .asciiz  "\nPlease enter your string: "
out_message:         .asciiz  "\nThe output string is: "
.align 2
input_string:        .space 100                   #The string from the user
output_string:       .space 100                   #The final string


.text
main:

	jal Get_Input                                 #Call Get_Input

	la $a0, input_string                          #Store the address of the input_string to $a0
	la $a1, output_string                         #Store the address of the output_string to $a1

	jal Process									  #Call Process with arguements $a0 and $a1

	jal Print_Output                              #Call Print_Output

	terminating:                                  #Terminate program
	li $v0, 10
	syscall


Get_Input:

	li $v0, 4                                     #Print prompt_message
	la $a0, prompt_message
	syscall

	li $v0, 8                                     #Read string from the user
	la $a0, input_string
	li $a1, 100
	syscall

	jr $ra


Process:

	move $t0, $a0                                 #Move the address of input_string to $t0 (to process the string)
	move $t4, $a1                                 #Move the address of output_string to $t4 (to process the string)

	WordLoop:
		lw $t1, 0($t0)                            #Load word from input_string to $t1

		li $t2, 0                                 #Set counter $t2 to 0
		ByteLoop:
			beq $t2, 4, endLoop                   #If counter $t2 reaches 4, go to endLoop
			andi $t3, $t1, 0x000000FF             #Masking (Take the MSB of the word and store it in $t3)
			
			beq $t3, 10, endProcess               #If $t3 is \n go to endProcess 
			li $t5, 96
			bgt $t3, $t5, storeByte               #If $t3 is lowercase go to storeByte
			li $t5, 90
			bgt $t3, $t5, symbols                 #If $t3 is a symbol between 91-96 go to symbols 
			li $t5, 64
			bgt $t3, $t5, converToLowercase       #If $t3 is uppercase go to converToLowercase
			li $t5, 57
			bgt $t3, $t5, symbols                 #If $t3 is a symbol between 58-64 go to symbols
			li $t5, 47
			bgt $t3, $t5, storeByte               #If $t3 is number go to storeByte
			blt $t3, $t5, symbols                 #If $t3 is a symbol below 47 go to symbols
			
			symbols:                              #Convert the symbol to space
			li $t3, 32
			j storeByte
			
			converToLowercase:                    #Convert the uppercase to lowercase
			addi $t3, $t3, 32

			storeByte:                            
			sb $t3, 0($t4)                        #Store the byte in $t3 to memory address $t4+0           
			addi $t4, $t4, 1                      #Move to the next byte of the output_string

			srl $t1, $t1, 8                       #Throw the MSB of the input_string
			addi $t2, $t2, 1                      #Increase the counter by 1

			j ByteLoop                            #Repeat the loop for the next byte

		endLoop:
		addi $t0, $t0, 4                          #Move to the next word of input_string
		j WordLoop	                              #Repeat the loop for the next word

	endProcess:
	sb $t3, 0($t4)                                #Store the byte in $t3 to memory address $t4+0
	
	jr $ra

Print_Output:

	li $v0, 4                                    #Print out_message
	la $a0, out_message
	syscall

	li $v0, 4                                    #Print the output_string
	la $a0, output_string
	syscall

	jr $ra

