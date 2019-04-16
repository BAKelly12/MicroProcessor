# Lab 6 - Test Application

	.data	# Data declaration section

Result:	.word	0

	.text

main:		# Start of code section

	add  a0, zero, zero
	lui  a7, 0x10000
	addi a2, zero, 0x0444
line2:	
	slli a1, a0, 2
	slli a1, a1, 2  
	add  a1, a1, a7       
	slli a2, a2, 1       
	sw   a0, 0(a1)
	sw   a2, 4(a1)
	slli a3, a2, 2   
	sw   a3, 8(a1)
	sub  a4, a3, a2
	sw   a4, 12(a1)
	addi a0, a0, 1       
	addi a5, zero, 5   
	sub  a6, a5, a0
	bne  a6, zero, line2
	lw   a7, 8(a1)
stop:	
	beq  zero, zero, stop

# END OF PROGRAM
