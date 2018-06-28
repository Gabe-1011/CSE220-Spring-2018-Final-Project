# Name: Juan Gabriel Purugganan
# ID: 111483826
##################################
# Part 1 - String Functions
##################################

is_whitespace:
	######################
	# Replace these lines with your code
#	li $v0, 888
	li $t0, '\n'
	li $t1, '\0'
	li $t2, ' '
	
	beq $a0, $t0, whitespace
	beq $a0, $t1, whitespace
	beq $a0, $t2, whitespace
	li $v0, 0
	######################
	jr $ra

whitespace:
	li $v0, 1
	jr $ra

cmp_whitespace:
	######################
	# Replace these lines with your code
	addi $sp, $sp, -8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	move $s0, $a1
	jal is_whitespace
	bnez $v0, checkSecondChar
	li $v0, 0
	j cmp_epilogue
checkSecondChar:
	move $a0, $s0
	jal is_whitespace
	bnez $v0, bothWhitespace
	li $v0, 0
	j cmp_epilogue
bothWhitespace:
	li $v0, 1
cmp_epilogue:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra	
	######################

strcpy:
	######################
	# Insert your code here
	
	# Check if address of the source string is less than or equal to the destination string
	blt $a0, $a1, srcLessDest
	move $t2, $a1
	li $t0, 0
strcpy_loop:
	beq $t0, $a2, exit_strcpy_loop
	lb $t1, ($a0)
	sb $t1, ($a1)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	addi $t0, $t0, 1
	j strcpy_loop
	######################
srcLessDest:
	jr $ra

exit_strcpy_loop:
	move $a1, $t2
	jr $ra

strlen:
	######################
	# Replace these lines with your code
#	li $v0, 888
	addi $sp, $sp, -16
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	move $s0, $a0
	li $s1, 0
	li $s2, 1
strlen_loop:
	lb $t0, ($s0)
	move $a0, $t0
	jal is_whitespace
	beq $v0, $s2, exit_strlen_loop
	addi $s1, $s1, 1
	addi $s0, $s0, 2
	j strlen_loop
exit_strlen_loop:
	move $v0, $s1
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	######################

##################################
# Part 2 - vt100 MMIO Functions
##################################

set_state_color:
	######################
	# Insert your code here
	li $t0, 1
	li $t1, 2
	# Check for the category
	beqz $a2, default_color
highlight_color:
	# Check for the mode
	beqz $a3, highlight_mode_zero
	beq $a3, $t0, highlight_mode_one
highlight_mode_two:
	lb $t3, 1($a0)
	andi $t3, $t3, 0x0F
	andi $t2, $a1, 0xF0
	or $t4, $t2, $t3
	sb $t4, 1($a0)
	jr $ra

highlight_mode_one:
	lb $t3, 1($a0)
	andi $t3, $t3, 0xF0
	andi $t2, $a1, 0x0F
	or $t4, $t3, $t2
	sb $t4, 1($a0)
	jr $ra

highlight_mode_zero:
	sb $a1, 1($a0)
	jr $ra
	
default_color:
	# Check for the mode
	beqz $a3, default_mode_zero
	beq $a3, $t0, default_mode_one
default_mode_two:
	lb $t3, ($a0)
	andi $t3, $t3, 0x0F	# Lower old
	andi $t2, $a1, 0xF0	# upper new
	or $t4, $t2, $t3
	sb $t4, ($a0)
	jr $ra

default_mode_one:
	lb $t3, ($a0)
	andi $t3, $t3, 0xF0	# Upper old
	andi $t2, $a1, 0x0F	# lower new
	or $t4, $t3, $t2
	sb $t4, ($a0)
	jr $ra

default_mode_zero:
	sb $a1, ($a0)
		
	######################
	jr $ra

save_char:
	######################
	# Insert your code here
	
	# Total number of rows of the display
	li $t0, 25
	
	# Total number of columns of the display
	li $t1, 80
	
	# Get the x value from the struct
	lb $t2, 2($a0)
	# Get the y value from the struct
	lb $t3, 3($a0)
	######################
	li $t6, 0xFFFF0000	# Base address
	
	# 2D array formula
	mul $t4, $t2, $t1 # i * num_columns
	add $t4, $t4, $t3 # i * num_columns + j
	sll $t4, $t4, 1		# 2 * (i * num_columns + j)
	add $t4, $t4, $t6
	sb $a1, ($t4)
	
	jr $ra

reset:
	######################
	# Insert your code here
	
	# Have to go through each cell and change the color (and ASCII character to null) depending on color_only arg)
	li $t0, 1
	
	# Total nunber of rows of the display
	li $t1, 25
	
	# Total number of columns of the display
	li $t2, 80
	
	# Base address
	li $t6, 0xFFFF0000	
	
	li $t8, 0
	
	# 2D array formula
	li $t3, 0	# i, row counter
	
	
	row_loop:
		li $t4, 0	# j, column counter
	col_loop:
		mul $t5, $t3, $t2
		add $t5, $t5, $t4
		sll $t5, $t5, 1
		add $t5, $t5, $t6
		
		beqz $a1, set_color_ascii
		lb $t7, ($a0)
		sb $t7, 1($t5)
		j increment_counter
	
	set_color_ascii:
		lb $t7, ($a0)
		sb $t7, 1($t5)
		sb $t8, ($t5)
	
	increment_counter:
		addi $t4, $t4, 1
		blt $t4, $t2, col_loop
	col_loop_done:
		addi $t3, $t3, 1
		blt $t3, $t1, row_loop
	
	row_loop_done:
	######################
	jr $ra

clear_line:
	######################
	# Insert your code here
	
	# Have to go through each column in the specified row and clear the ASCII characters and set the color to the color arg
	
	# Total nunber of rows of the display
	li $t1, 25
	
	# Total number of columns of the display
	li $t2, 80
	
	# Base address
	li $t6, 0xFFFF0000
	
	li $t7, 0
	
	# The row is in $a0, the column is in $a1
	
	col_loop_clear:
		mul $t5, $a0, $t2
		add $t5, $t5, $a1
		sll $t5, $t5, 1
		add $t5, $t5, $t6
		
		sb $a2, 1($t5)
		sb $t7, ($t5)
		
		addi $a1, $a1, 1
		blt $a1, $t2, col_loop_clear
	
	col_loop_done_clear:
	######################
	jr $ra

set_cursor:
	######################
	# Insert your code here
	
	# Total number of columns of the display
	li $t1, 80
	
	# Get the x value from the struct
	lb $t2, 2($a0)
	# Get the y value from the struct
	lb $t3, 3($a0)
	######################
	li $t6, 0xFFFF0000	# Base address
	
	li $t7, 1
	# 2D array formula
	mul $t4, $t2, $t1 # i * num_columns
	add $t4, $t4, $t3 # i * num_columns + j
	sll $t4, $t4, 1		# 2 * (i * num_columns + j)
	add $t4, $t4, $t6
	
	# Check if initial is 1 or 0 
	beq $a3, $t7, update_cursor_location
	lb $t8, 1($t4)
	andi $t9, $t8, 0x0F	# Lower old
	andi $t2, $t8, 0xF0	# upper new
	sll $t9, $t9, 4
	srl $t2, $t2, 4
	or $t3, $t9, $t2
	sb $t3, 1($t4)
	sb $a1, 2($a0)
	sb $a2, 3($a0)
	
	mul $t4, $a1, $t1
	add $t4, $t4, $a2
	sll $t4, $t4, 1
	add $t4, $t4, $t6
	
	lb $t0, 1($t4)
	andi $t9, $t0, 0x0F
	andi $t2, $t0, 0xF0
	sll $t9, $t9, 4
	srl $t2, $t2, 4
	or $t3, $t9, $t2
	sb $t3, 1($t4)
	jr $ra
	
update_cursor_location:
	mul $t4, $a1, $t1
	add $t4, $t4, $a2
	sll $t4, $t4, 1
	add $t4, $t4, $t6
	
	lb $t0, 1($t4)
	andi $t9, $t0, 0x0F
	andi $t2, $t0, 0xF0
	sll $t9, $t9, 4
	srl $t2, $t2, 4
	or $t3, $t9, $t2
	sb $t3, 1($t4)
	
	jr $ra

move_cursor:
	######################
	# Insert your code here
	
	addi $sp, $sp, -16
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	move $s2, $a1	# direction arg
	
	lb $s0, 2($a0) # x value
	lb $s1, 3($a0) # y value
	
	li $a3, 0	# initial is set to 0
	
	# Check for the direction arg
	beq $s2, 'l', move_cursor_right
	beq $s2, 'k', move_cursor_up
	beq $s2, 'j', move_cursor_down
	
move_cursor_left:
	# Check if cell is at leftmost column
	beqz $s1, move_cursor_done
	addi $s1, $s1, -1
	move $a1, $s0
	move $a2, $s1
	jal set_cursor
	j move_cursor_done

move_cursor_right:
	# Check if cell is at rightmost column
	beq $s1, 79, move_cursor_done
	addi $s1, $s1, 1
	move $a1, $s0
	move $a2, $s1
	jal set_cursor
	j move_cursor_done
	
move_cursor_up:
	# Check if cell is at first row
	beqz $s0, move_cursor_done
	addi $s0, $s0, -1
	move $a1, $s0
	move $a2, $s1
	jal set_cursor
	j move_cursor_done

move_cursor_down:
	# Check if cell is at last row
	beq $s0, 24, move_cursor_done
	addi $s0, $s0, 1
	move $a1, $s0
	move $a2, $s1
	jal set_cursor

move_cursor_done:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	######################
	jr $ra

mmio_streq:
	######################
	# Replace these lines with your code
#	li $v0, 888
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	mmio_loop:
		lb $s2, ($s0)
		lb $s3, ($s1)
		move $a0, $s2
		move $a1, $s3
		jal cmp_whitespace
		beqz $v0, check_char_equal
		j mmio_streq_epilogue
	
	check_char_equal:
		beq $s2, $s3, next_char
		j mmio_streq_epilogue
	
	next_char:
		addi $s0, $s0, 2
		addi $s1, $s1, 1
		j mmio_loop
	
mmio_streq_epilogue:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	######################
	jr $ra

##################################
# Part 3 - UI/UX Functions
##################################

handle_nl:
	######################
	# Insert your code here
	addi $sp, $sp, -8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	move $s0, $a0
	
	# First, we have to save a newline character in the current position of the struct
	li $a1, '\n'
	jal save_char
	
	# Then, we have to clear the line from the current location of the cursor to the end of the line
	lb $a0, 2($s0)
	lb $a1, 3($s0)
	lb $a2, ($s0)
	jal clear_line
	
	# Next, we have to move the location of the cursor to the row below and to the start of the row
	move $a0, $s0
	lb $a1, 2($a0)
	beq $a1, 24, start_row
	addi $a1, $a1, 1
	li $a2, 0
	li $a3, 0
	jal set_cursor
	j handle_nl_done
start_row:
	li $a2, 0
	li $a3, 0
	jal set_cursor
	
	######################
handle_nl_done:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra

handle_backspace:
	######################
	# Insert your code here
	addi $sp, $sp, -28
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	
	move $s0, $a0
	# First we need to navigate to the location of the cursor given the x and y from the struct
	# Total number of columns of the display
	li $s1, 80
	
	# Get the x value from the struct
	lb $s2, 2($a0)
	# Get the y value from the struct
	lb $s3, 3($a0)
	beqz $s3, handle_backspace_done
	
	li $s4, 0xFFFF0000	# Base address
	
	col_loop_backspace:
		# 2D array formula
		mul $s5, $s2, $s1 # i * num_columns
		add $s5, $s5, $s3 # i * num_columns + j
		sll $s5, $s5, 1		# 2 * (i * num_columns + j)
		add $s5, $s5, $s4
		
		# N + 1th byte (source)
		addi $s5, $s5, 2
		move $a0, $s5
		
		# Nth byte (destination)
		addi $s5, $s5, -2
		move $a1, $s5
		li $a2, 1
		jal strcpy
		
		addi $s3, $s3, 1
		blt $s3, $s1, col_loop_backspace

handle_backspace_done:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	######################
	jr $ra

highlight:
	######################
	# Insert your code here
	
	# Total nunber of rows of the display
	li $t1, 25
	
	# Total number of columns of the display
	li $t2, 80
	
	# Base address
	li $t6, 0xFFFF0000
	
	# 2D array formula
	li $t3, 0	# i, row counter
	
	# Counter
	li $t7, 0
	
	j col_loop_hl
	
	row_loop_hl:
		li $a1, 0	# j, column counter
	col_loop_hl:
		mul $t5, $a0, $t2
		add $t5, $t5, $a1
		sll $t5, $t5, 1
		add $t5, $t5, $t6
		beq $t7, $a3, row_loop_hl_done
		
		addi $t7, $t7, 1
		sb $a2, 1($t5)
	increment_counter_hl:
		addi $a1, $a1, 1
		blt $a1, $t2, col_loop_hl
	col_loop_hl_done:
		addi $a0, $a0, 1
		blt $a0, $t1, row_loop_hl
	
	row_loop_hl_done:
	######################
	jr $ra

highlight_all:
	######################
	# Insert your code here
	addi $sp, $sp, -40
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	move $s0, $a1
	sw $s0, 36($sp)
	
	# Total number of rows in the display
	li $s1, 25
	
	# Total number of columns in the display
	li $s2, 80
	
	# Base address
	li $s6, 0xFFFF0000
	
	# 2D array formula
	li $s3, 0	# i, row counter
	
	move $s7, $a0
	
	row_loop_hl_all:
		li $s4, 0	# j, column counter
	
	col_loop_hl_all:
		mul $s5, $s3, $s2
		add $s5, $s5, $s4
		sll $s5, $s5, 1
		add $s5, $s5, $s6
		lb $a0, ($s5)
		jal is_whitespace
		beqz $v0, check_dictionary
		j increment_counter_hl_all
	check_dictionary:
		# Tentative algorithm for checking if the string starting at current cell is equal to a word in the dictionary
		# Get the char at the current cell. If its equal to the first char of a word in the dictionary, move to the next char in the dictionary word and get the char at the next cell
		# until a whitespace char is reached.
		addi $sp, $sp, -8
		sw $s3, ($sp)	# Save the i
		sw $s4, 4($sp) # Save the j
	check_dictionary_loop:
		move $a0, $s5
		lw $a1, ($s0)
		beqz $a1, restore_xy
		jal mmio_streq
		beqz $v0, next_word_dictionary
		
		lw $s3, ($sp)
		lw $s4, 4($sp)
		addi $sp, $sp, 8
		
		# Count the number of chars in the string
		move $a0, $s5
		jal strlen
		
		# The length of the string is in v0
		move $a0, $s3
		move $a1, $s4
		move $a2, $s7
		move $a3, $v0
		jal highlight
		lw $s0, 36($sp)
		j inner_loop_hl
	next_word_dictionary:
		addi $s0, $s0, 4
#		beqz $s0, inner_loop_hl
		j check_dictionary_loop
	
	restore_xy:
		lw $s3, ($sp)
		lw $s4, 4($sp)
		addi $sp, $sp, 8
		lw $s0, 36($sp)
	
	inner_loop_hl:
		addi $s5, $s5, 2
		addi $s4, $s4, 1
		lb $a0, ($s5)
		jal is_whitespace
		beqz $v0, inner_loop_hl
		
	increment_counter_hl_all:
		addi $s4, $s4, 1
		blt $s4, $s2, col_loop_hl_all
	col_loop_hl_all_done:
		addi $s3, $s3, 1
		blt $s3, $s1, row_loop_hl_all
	
	row_loop_hl_all_done:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 32
	######################
	jr $ra
