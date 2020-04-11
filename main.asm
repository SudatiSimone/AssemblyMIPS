main:
.data
IN:	.byte	0X00
OUT:	.byte	0x00
.text
	la	$a0, IN
	la	$a1, OUT
CFS:	lb	$t0, 0($a0)		  
	andi	$t0, $t0, 0x80	      
	beq	$t0, $zero, CFS		#control first sensor
	add	$t5, $zero, $zero	#initialize speed counter
RS:	lb	$t0, 0($a0)		
	andi	$t0, $t0, 0x40		
	addi	$t5, $t5, 4		#rec speed
	beq	$t0, $zero, RS		#control second sensor
    	li	$t4, 36000000
	slt	$t0, $t4, $t5		#speed < 50km/h (13,6m/s)
	bne	$t0, $zero, ENDV1
	li	$t2, 250000000		#wait 1s //(già diviso per 2)
	jal	WAIT
	li	$t1, 0x08		#line 3 (aperturaotturatore)
	sb	$t1, 0($a1)	
	li	$t2, 62500000		#wait 250ms //(già diviso per 2)
	jal	WAIT
	li	$t1, 0x00		#line 3 (chiusura otturatore)
	sb	$t1, 0($a1)
	li	$t4, 32750000
	slt	$t0, $t4, $t5		#speed < 55km/h (15,27m/s)
	bne	$t0, $zero, ENDV2	
	li	$t4, 30000000
	slt	$t0, $t4, $t5		#speed < 60km/h (16,6m/s)
	bne	$t0, $zero, ENDV3
	j	ENDV4                   #speed > 60km/h (16,6m/s)
RES:	sb	$t1, 0($a1)		#save speed in memory
	jr	$ra
WAIT:	addi	$t2, $t2, -1		#delay of VAL = $t2
	bne	$t2, $zero, WAIT
	jr	$ra
ENDV1:	li	$t1, 0x00		#speed < 50km/h
	jal	RES
	j CFS
ENDV2:	li	$t1, 0x10		#50km/h < speed < 55kh/h
	jal	RES
	j CFS
ENDV3:	li	$t1, 0x20		#55km/h < speed < 60kh/h 
	jal	RES
	j CFS
ENDV4:	li	$t1, 0x30		#speed > 60km/h
	jal	RES
	j CFS