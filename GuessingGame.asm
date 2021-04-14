# Author:		Adrian Shina
# Date:			4/12/2021
# Descrption:	Guessing Game in MIPS		

.data
	title:		.asciiz		"Guessing Game by Adrian Shina\n"
	greeting:	.asciiz 		"\nWhat is your name?: "
	greeting2:	.asciiz 		"\nHello, "
	userName:	.space		64 
	message:		.asciiz 		"I have picked a number between 1 and 100. You have 10 attempts to guess the number.\n"
	attempt:		.asciiz		"\nAttempt #"
	colon:		.asciiz		":"
	prompt:		.asciiz		" Enter a guess between 1 and 100: "
	hintH:		.asciiz		"Too high!\n"
	hintL:		.asciiz		"Too low!\n"
	W:			.asciiz		"\nCongrats, you won! You got it in "
	W2:			.asciiz		" guesses."
	L:			.asciiz		"\nSorry, you have reached the maximum number of guesses! You lost.\n"
	L2:			.asciiz 		"The correct number was: "
	farewell:	.asciiz		"\nGoodbye, "
	guesses:		.asciiz		"\n\nYour guesses: "
	commaSpace:	.asciiz		", "	
	
.text

# Pseudocode:
#	int randomNum, userGuess = 0, tries = 0;
#   generate random number between 1 and 100 and store in randomNum

#	while (userGuess != randomNum && tries < 10) {
#		prompt user and store the integer in guess
#       tries++;
#
#		if (userGuess > randomNum) {
#       		print too high
#       }
#       else if (userGuess < randomNum) {
#           print too low
#       }
#       else {
#       		print congrats	
#        }
#    }

#    if (userGuess != randomNum && tries >= 10) {
#        print you lost
#    }


	main:
		# Print introduction and greet user
		li $v0, 4
		la $a0, title
		syscall

		li $v0, 4
		la $a0, greeting
		syscall

		# Get user's name as input
		li $v0, 8
		la $a0, userName
		li $a1, 64
		syscall
			
		li $v0, 4
		la $a0, greeting2
		syscall

		li $v0, 4
		la $a0, userName
		syscall
		
		li $v0, 4
		la $a0, message
		syscall
		
		# Initialize variable
		addi $t0, $t0, 0		# int tries = 0

		# Generate random number in the range [1, 100]
		li $v0, 42		# generate the random number and store it in $a0
		la $a1, 100		# set upper bound to 100 (exclusive)
		syscall

		addi $a0, $a0, 1		# add 1 to the lower and upper bound to make it between 1 and 100 (inclusive)
		#li $v0, 1			# print integer
		#syscall
		move $t1, $a0		# store the random number in $t1
		
		# Create dynamic array to store the guesses
		li $v0, 9	# allocate memory for new record
		li $a0, 40	# 40 bytes, (10 guesses): 10*4
		syscall
		move $s0, $v0	# store the initial address of the array (memory) in $s0
		li $t9, 0       # set current offset to 0

	# Register mappings:
	#	tries: $t0, randomNum: $t1, guess: $t2
		while: 
			jal promptUser			# prompt user to enter a guess
			beq $t2, $t1, userWon	# if(guess == randomNum) then congratulate user
			bge $t0, 10, userLost	# if(tries >= 10) then print user lost
			blt $t2, $t1, tooLow		# else if(guess < randomNum) then print too low	
			bgt $t2, $t1, tooHigh	# else print too high
			j while					# jump back to the beginning of the loop
			
			
		done:	
			# Print farewell message
			li $v0, 4
			la $a0, farewell
			syscall
			li $v0, 4
			la $a0, userName
			syscall

			# Exit program
			li $v0, 10
			syscall


	promptUser:
		addi $t0, $t0, 1		# tries++
		
		# Print attempt number
		li $v0, 4
		la $a0, attempt
		syscall
		li $v0, 1
		move $a0, $t0
		syscall
		li $v0, 4
		la $a0, colon
		syscall
			
		# Prompt user to enter number
		li $v0, 4
		la $a0, prompt
		syscall

		# Read user input for "guess" and store in t2 register
		li $v0, 5
		syscall
		move $t2, $v0
		
		add $s2, $s0, $t9   # $s2 = initial memory location + offset 
		sw $t2, 0($s2)      # store userGuess in the offset location
		addi $t9, $t9, 4    # add 4 to offset
		
		jr $ra


	tooHigh:
		# Print too high
		li $v0, 4
		la $a0, hintH
		syscall
		j promptUser		# go back to prompt user

		
	tooLow:
		# Print too low
		li $v0, 4
		la $a0, hintL
		syscall
		j promptUser		# go back to prompt user


	userWon:
		# Produce sound
		li $v0, 31	# midi output
	    addi $a1, $a1, 1000000 # duration in ms
	    addi $a2, $a2, 114	# instrument (percussion)
	    	addi $a3, $a3, 50	# volume
	    syscall
		
		# Print congrats and number of guesses it took
		li $v0, 4
		la $a0, W
		syscall
		li $v0, 1
		move $a0, $t0
		syscall
		li $v0, 4
		la $a0, W2
		syscall
		
		j showArray		# go to showArray


	userLost:
		# Print user lost and the correct number
		li $v0, 4
		la $a0, L
		syscall
		li $v0, 4
		la $a0, L2
		syscall
		move $a0, $t1
		li $v0, 1
		syscall
		
		j showArray		# go to showArray
		
		
	showArray:
		# Print guess string
		li $v0, 4
		la $a0, guesses
		syscall
			
		li $t5, 0	# set initial offset to 0
		
		
	printArray:
		# Print all guesses entered by user in a loop
		add $s2, $s0, $t5 # $s2 = initial memory location + initial offset
		li $v0, 1
		lw $a0, 0($s2)    # print the number at memory address + initial offset
		syscall

		addi $t5, $t5, 4    # add 4 to offset
		beq $t5, $t9, done	# if offset == final guess offset, go to done
				
		#Print comma and space
		li $v0, 4         
		la $a0, commaSpace
		syscall
		
		j printArray		# jump back to loop


		


