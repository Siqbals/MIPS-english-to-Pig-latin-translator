#Saadman Iqbal
#doj513
#11319791
#Dr. Eager
#CMPT215

.data
	prmpt1:.asciiz "enter input string to convert to pig latin: "
	inp: .space 256
	space: .asciiz "  " 
	vowels: .asciiz "aeiou"
	append1: .asciiz "way"
	append2: .asciiz "ay"


.text

main:

strt:
#initialize/reset all regs used 
move $t0, $0
move $t1, $0
move $t2, $0
move $t3, $0
move $t4, $0
move $t5, $0
move $t6, $0
move $t7, $0

move $s0, $0
move $s1, $0
move $s2, $0
move $s3, $0
move $s5, $0 
move $s6, $0

la $t1, inp     # load the address of hello into $t0
li $s0, 0xFFFF0000	# receiver registers
waitRead: lw $t0, 0($s0) 
	beqz $t0, waitRead #wait till 1st byte says we are ready for input
	lbu $s1, 4($s0) #load the character
	
    	sb $s1, 0($t1)      # store character in buffer
    	addi $t1, $t1, 1   # increment buffer pointer
  	
  	bne $s1, 32, waitRead   #if character is not a space, then the string as not ended 
  
  	#load vowel string and inp string into regs
	la $s0, vowels
	la $s1, inp
	
	jal piglatinconv
	
#how to output a character
addi $s2, $s2, 3
li $s0, 0xFFFF0008	# transmitter registers
waitPrint: lw $t0, 0($s0) 
	beqz $t0, waitPrint #wait till 1st byte says we are ready for output
	
	#print each character in the string
	prntloop:
	lb $s5, 0($s3)
	sb $s5, 4($s0)
	addi $s3, $s3, 1
	addi $s6, $s6, 1
	beq $s6, $s2 inspace
	
	j prntloop
	 
	#add space to the string and restart
	inspace:
	la $s5, space
	lb $s5 , 0($s5) 
	sb $s5, 4($s0)  
	j strt
	

	
	

	


#s0 - hold input string 
#s1 - hold vowels string 
#s2 - hold length of string

piglatinconv:
#t0 - hold addr of inp string
#t1 - hold current char of input string to be examined
#t2 - hold current char of "way"
#s2 - hold length of input string 
findlength:
	#reset regs
	move $t0, $0
	move $t1, $0
	move $t2, $0
	
	move $t0, $s1   #move inp string addr into t1
	addi $s2, $s2, -1   #offset to account for loop
	
	findendloop:
	lb $t1, 0($t0)   #load char of inp string into t1
	beq $t1, 0, vcheck    #check if char is 0 character
	addi $s2, $s2, 1   #count len of str
	addi $t0, $t0, 1   #increment to goto next char 
	j findendloop


#t0 - hold current vowel from vowel list 
#t1 - hold current character for input
#t2 - loop control (5 iterations)
#t3 - hold input str
vcheck:
	#reset regs
	move $t0, $0
	move $t1, $0
	move $t2, $0
	move $t3, $0
	
	move $t3, $s0
	loopthru:
	beq $t2,5,ifconsanent
	lb $t0, 0($t3)    #store the current vowel in vowel list 
	lb $t1, 0($s1)    #store the current char in the input list
	
	beq $t0, $t1, iffirstvowel
	
	addi $t3, $t3, 1
	addi $t2, $t2, 1
	j loopthru 

		
#t0 - hold input string 
#t1 - hold "way" string 
#t2 - hold current char in "way"
#t3 - hold end of string for inp string	
#t4 - loop control for going to end of "way"	
iffirstvowel:
	#reset regs
	move $t0, $0
	move $t1, $0
	move $t2, $0
	move $t3, $0
	
	
	#store inp string into $t0, and goto end of string 
	move $t0, $s1
	add $t3, $t0, $s2
	
	la $t1, append1
	
	wayloop:
	beq $t4, 3, return
	lb $t2 , 0($t1)   #load current char of way into t2
	sb $t2, ($t3)   #append current char of way into inp string
	addi $t1, $t1, 1   #goto next char of way
	addi $t3, $t3, 1 #goto next idx of inp string 
	addi $t4, $t4, 1   #increment counter
	j wayloop
	
	
	return:
	move $s3, $t0
	jr $ra

#t0 - hold input string
#t1 - hold vowel string 
#t2 - hold current char of input string to be pushed back to end of string
#t3 - loop control for vowel check
#t4 - current char to hold vowel

#s4 - hold modified string
#t5 - hold "ay" string
#t6 - current char of ay
#t7 - loop control for ay loop 

	 
ifconsanent:
	#reset regs
	move $t0, $0
	move $t1, $0
	move $t2, $0
	move $t3, $0
	
	move $t0, $s1   #move inp string to $t0
	
	lstart:
	la $t1, vowels   #load vowel string into $t1
	lb $t2, 0($t0)   #load char into t2 from string 
	
	#check if char is a vowel
	loopthru1:
	beq $t3,5,movend
	lb $t4, 0($t1)    #store the current vowel in vowel list 
	
	beq $t4, $t2, appenday
	
	addi $t1, $t1, 1   #goto next char in vowel list 
	addi $t3, $t3, 1   #increment loop control count
	j loopthru1
	
	 
	movend:
		add $t0, $t0, $s2   #goto end of string
		sb $t2, ($t0)   #store character at end of string
		
		#goto beggining of string (accounting for new char and deleting old char)
		addi $t0, $t0, 1
		sub $t0, $t0, $s2
		
		move $t3, $0   #reset counter
		j lstart   
		
	appenday:   
		add $s4, $t0, $s2   #goto end of string
		la $t5, append2   #load "ay" into reg

		ayloop:
		beq $t7, 2, return1   #if end of string "ay" is reached, exit 
		lb $t6 , 0($t5)   #load current char of ay into t2
		sb $t6, ($s4)   #append current char of ay into inp string
		addi $t5, $t5, 1   #goto next char of ay
		addi $s4, $s4, 1 #goto next idx of inp string 
		addi $t7, $t7, 1
		j ayloop
		
		return1:
		move $s3, $t0   #move translated string to s3
		jr $ra
		
		
		
		
		
	
	 
	
	
	
	
	



	 
