.data
prompt_message:             .asciiz "\nPlease determine operation, entry (E), inquiry (I) or quit (Q): \n"
entry_message1:             .asciiz "\nPlease enter last name: "
entry_message2:         	.asciiz "\nPlease enter first name: "
entry_message3:      		.asciiz "\nPlease enter phone number: "
entry_message4:     		.asciiz "\nThank you, the new entry is the following: "
entry_message_false:        .asciiz "\nThe phonebook is full."
inquiry_message1:    		.asciiz "\nPlease enter the entry number you wish to retrieve: "
inquiry_message2:   	    .asciiz "\nThe number is: "
inquiry_message_false:      .asciiz "\nThere is no such entry in the phonebook."
dot_space:                  .asciiz ". "
.align 2
catalog:                    .space 600                #Allocate 10*3*20 = 600bytes in memory 


.text
main:

	la $s0, catalog                                   #Load the address of the catalog in $s0 (global register)
	li $s1, 0                                         #Set counter for the number of entries in $s1 (global register)
	
	Prompt_User:
		li $v0, 4                                     #Print prompt_message
		la $a0, prompt_message
		syscall
	
		li $v0, 12                                    #Read user's input as character
		syscall
	
	move $t0, $v0                                     #Store the character in $t0 (register for temporary saving)
	beq $t0, 69, entry                                #Branch if the character is E
	beq $t0, 73, inquiry                              #Branch if the character is I
	beq $t0, 81, terminate                            #Branch if the character is Q
	j Prompt_User                                     #Return to Prompt_User if any other character
	
	entry:                                            #Add a new entry in the catalog
		li $t0, 10                                    #Store maximum number of entries(10) in $t0
		beq $s1, $t0, Full_Catalog                    #Branch if counter $s1 reaches 10
		
		jal Get_Entry                                 #Call Get_Entry function to store the new entry
		addi $s1, $s1, 1                              #Increase the number of entries by 1
		
		li $v0, 4                                     #Print entry_message4
		la $a0, entry_message4
		syscall
		
		move $a0, $s1                                 #Store the entry number in $a0 (arguement for Print_Entry)
		jal Print_Entry                               #Call Print_Entry function to print the new entry
		j Prompt_User                                 #Return to Prompt_User
		
		Full_Catalog:                                 #Print entry_message_false
		li $v0, 4                                      
		la $a0, entry_message_false
		syscall
		                                  
		j Prompt_User                                 #Return to Prompt_User               
		
	inquiry:                                          #Search for an entry
		li $v0, 4                                     #Print inquiry_message1       
		la $a0, inquiry_message1
		syscall
	
		li $v0, 5                                     #Read the user's input as integer
		syscall

		move $t0, $v0                                 #Store the integer
		bgt $t0, $s1, false_Entry                     #Branch if the entry number is greater than the number of entries 
	
		li $v0, 4                                     #Print inquiry_message2       
		la $a0, inquiry_message2
		syscall
		
		move $a0, $t0                                 #Store the entry number in $a0 (arguement for Print_Entry)
		jal Print_Entry                               #Call Print_Entry function to print the requested entry
		j Prompt_User                                 #Return to Prompt_User
	
		false_Entry:
			li $v0, 4                                 #Print inquiry_message_false       
			la $a0, inquiry_message_false
			syscall
	
		j Prompt_User								  #Return to Prompt_User
		
	terminate:                                        #Terminate the program
		li $v0, 10
		syscall
		
Get_Entry:
	addiu $sp, $sp, -4                                #Move $sp 4 bytes lower in the stack
	sw $ra, 0($sp)                                    #Store $ra at the address of $sp
	
	li $t0, 60                                        #Store the entry size in $t0                                 
	mul $t1, $s1, $t0                                 #Multiply it with the number of entries
	add $s2, $t1, $s0                                 #Add the result to the catalog address, so now $s2 has the address where the new entry will be
	
	jal Get_Last_Name                                 #Call Get_Last_Name to store the last name 
	jal Get_First_Name                                #Call Get_First_Name to store the first name
	jal Get_Number                                    #Call Get_Number to store the phone number
	
	lw $ra, 0($sp)                                    #Load the value stored in $sp back to $ra 
	addiu $sp, $sp, 4                                 #Move $sp 4 bytes higher in the stack
		
	jr $ra                                            #Return to line 41 

Get_Last_Name:
	addiu $sp, $sp, -4                                #Move $sp 4 bytes lower in the stack
	sw $ra, 0($sp)                                    #Store $ra at the address of $sp
	
	move $t0, $s2                                     #Store the address of the 1st field of the new entry 
	
	li $v0, 4                                         #Print entry_message1   
	la $a0, entry_message1
	syscall
	
	li $v0, 8                                         #Read the user's input as string and store it                           
	move $a0, $t0
	li $a1, 20
	syscall
	
	jal Remove_New_Line                               #Call Remove_New_Line function to remove the \n at the end of the string
	
	lw $ra, 0($sp)                                    #Load the value stored in $sp back to $ra
	addiu $sp, $sp, 4                                 #Move $sp 4 bytes higher in the stack
	jr $ra											  #Return to line 98

Get_First_Name:
	addiu $sp, $sp, -4                               #Move $sp 4 bytes lower in the stack
	sw $ra, 0($sp)                                   #Store $ra at the address of $sp
	
	addi $t0, $s2, 20                                #Store the address of the 2nd field of the new entry(20 bytes after the address of the 1st)

	li $v0, 4                                        #Print entry_message2            
	la $a0, entry_message2
	syscall
	
	li $v0, 8                                        #Read the user's input as string and store it
	move $a0, $t0
	li $a1, 20
	syscall
	
	jal Remove_New_Line                              #Call Remove_New_Line function to remove the \n at the end of the string
	
	lw $ra, 0($sp)                                   #Load the value stored in $sp back to $ra
	addiu $sp, $sp, 4                                #Move $sp 4 bytes higher in the stack
	jr $ra											 #Return to line 99

Get_Number:
	addi $t0, $s2, 40                                #Store the address of the 3rd field of the new entry(20 bytes after the address of the 2nd)

	li $v0, 4                                        #Print entry_message3  
	la $a0, entry_message3
	syscall
	
	li $v0, 8                                        #Read the user's input as string and store it
	move $a0, $t0
	li $a1, 20
	syscall
	
	jr $ra											 #Return to line 100

Remove_New_Line:
	move $t0, $a0                                    #Store the address of the string in $t0
	
	byte_Loop:
		lb $t1, 0($t0)                               #Load the byte of the string from the address of $t0 to $t1
		beq $t1, 10, convert_To_Space                #Branch if the character is \n
		sb $t1, 0($t0)                               #Store the byte back to the address of $t0
		addi $t0, $t0, 1                             #Move to the next character
	j byte_Loop                                      #Repeat the loop until you find \n
	
	convert_To_Space:
		li $t1, 32                                   #Convert the \n character to space character
		sb $t1, 0($t0)                               #Store the byte back to the address of $t0
			
	jr $ra											 #Return to lines 122 or 143

Print_Entry:
	move $t0, $a0                                    #Store the entry number in $t0
	
	li $v0, 1                                        #Print the entry number  
	move $a0, $t0
	syscall
	
	li $v0, 4                                        #Print dot_space 
	la $a0, dot_space
	syscall
	
	addi $t0, $t0, -1                         	     #Decrease the entry number by 1
	li $t1, 60                                       #Store the entry size in $t1
	mul $t0, $t0, $t1                                #Multiply the two
	add $t0, $t0, $s0                                #Add the result to the catalog address, so now $t0 has the address of the 1st field of the entry
	
	li $v0, 4                                        #Print the last name                              
	move $a0, $t0
	syscall
	
	addi $t0, $t0, 20                                #Move $t0 to show at the 2nd field of the entry
	
	li $v0, 4                                        #Print the first name                    
	move $a0, $t0
	syscall
	
	addi $t0, $t0, 20                                #Move $t0 to show at the 3rd field of the entry
	
	li $v0, 4                                        #Print the phone number
	move $a0, $t0
	syscall
	
	jr $ra                                           #Return to lines 49 or 75