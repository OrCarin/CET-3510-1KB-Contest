JUMP_SCORE1
ldi ZL, low(DISPLAY1_0)
ldi ZH, high(DISPLAY1_0)

mov  temp, score
lsl temp, 1
add ZL, temp
ijmp

DISPLAY1_N:	
	ldi disp1, 0b00000100
	ret

DISPLAY1_0:
	ldi disp1, 0b11111110
	ret

DISPLAY1_1:
	ldi disp1, 0b01100100
	ret

DISPLAY1_2:
	ldi disp1, 0b11011101
	ret
	
DISPLAY1_3:
	ldi disp1, 0b11110101
	ret

DISPLAY1_4:
	ldi disp1, 0b01100111
	ret

DISPLAY1_5:
	ldi disp1, 0b10110111
	ret

DISPLAY1_6:
	ldi disp1, 0b10111111
	ret

DISPLAY1_7:
	ldi disp1, 0b11100100
	ret

DISPLAY1_8:
	ldi disp1, 0b11111111
	ret

DISPLAY1_9:
	ldi disp1, 0b11100111
	ret

	
JUMP_SCORE2
ldi ZL, low(DISPLAY2_0)
ldi ZH, high(DISPLAY2_0)

mov  temp, score2 
lsl temp, 1
add ZL, temp
ijmp

DISPLAY2_N:	
	ldi disp1, 0b00000100
	ret

DISPLAY2_0:
	ldi disp1, 0b11111110
	ret

DISPLAY2_1:
	ldi disp1, 0b01100100
	ret
 
DISPLAY2_2:
	ldi disp1, 0b11011101
	ret
	
DISPLAY2_3:
	ldi disp1, 0b11110101
	ret

DISPLAY2_4:
	ldi disp1, 0b01100111
	ret

DISPLAY2_5:
	ldi disp1, 0b10110111
	ret

DISPLAY2_6:
	ldi disp1, 0b10111111
	ret

DISPLAY2_7:
	ldi disp1, 0b11100100
	ret

DISPLAY2_8:
	ldi disp1, 0b11111111
	ret

DISPLAY2_9:
	ldi disp1, 0b11100111
	ret

	
	