	;; charlie8to56.asm
	;; Uses pins 0-7
	;; Controls 14 LEDs ad two 7 segment displays (common anode)
	;; r18 and r19 is used to store which LEDs to light with bits 1-6
	;;
	;; Register Definitions
	;; r16		temporary
	;; r17		Timer Overflow counter
	;; r18 bit0	Selector
	;; r18 bit1	LED01
	;; r18 bit2	LED02
	;; r18 bit3	LED03
	;; r18 bit4	LED04
	;; r18 bit5	LED05
	;; r18 bit6	LED06
	;; r18 bit7	LED07
	;; r19 bit0	LED08
	;; r19 bit1	Selector
	;; r19 bit2	LED09
	;; r19 bit3	LED10
	;; r19 bit4	LED11
	;; r19 bit5	LED12
	;; r19 bit6	LED13
	;; r19 bit7	LED14
	;; r20		cycle speed./
	;; r21		display1
	;; r22		dispaly2
	
	.nolist
	.include "./m328Pdef.inc" ;Include definitions file
	.list
 
	.def temp = r16 	;Use r16 as temporary register
	.def countOF = r17 	;Use r17 as overflow counter
	.def leds1 = r18 	;Use r18 as output LEDS
	.def leds2 = r19 	;Use r19 as output LEDS
	.def cycDelay = r20	;Use r20 for cycle speed
	
	.def disp1 = r21 	;Use r21 for display1
	.def disp2 = r22 	;Use r22 for dsiplay2

	.def ball = r23		;Use r23 to store postion of ball 
	.def score = r24	;Use r24 to store the score
	
	.org 0x0000		;Set jump for reset
	rjmp SETUP

	
	.org 0x0020		;Set jump for overflow interupt
	rjmp OVERFLOW
SETUP:
SETUP_CLOCK:
	ldi temp, 0b00000100	;Set clock scaling to 1/1024
	out TCCR0B, temp	;See Datasheet 107-108 for more info
	;; Since clock speed 20 MHz,
	;; counter will increment at about 19.53 kHz when scaled
	;; Therefore, overflow counter increments at about 76.29 Hz
	
	ldi temp, 0b00000001	;Enable timer overflow interrupts
	sts TIMSK0, temp	;See Datasheet 109 for more info
	
	sei			;Enable global interrupts
	
	ldi countOF, 0b00000000	;Reset counters to zero
	out TCNT0, countOF
SETUP_LEDS:
	ldi leds1, 0b00000001	;Initialize leds1 register (selected)
	ldi leds2, 0b00000000	;Initialize leds2 register
	ldi disp1, 0b00000000	;Initialize disp1 register
	ldi disp2, 0b00000000	;Initialize disp1 register
	
	ldi countOF, 0b0000000	;Reset overflow counter
	
	;; ldi disp1, 0b11111011	;Turn on all displays for testing
	;; ldi disp2, 0b11110111
SETUP_GAME:			;Initialize game variables
	ldi cycDelay, 60	;Initalize delay at ~500ms
	ldi ball,  0b00000000	;Initialize ball at position 0
	ldi score, 0b00000000	;Initialize score to 0

LOOP:				;Main Loop
	rcall CYCLE
	rcall CHARLIE
	rcall JUMP_SCORE1	;Display score1
	rjmp LOOP		;Loop forever

CYCLE:				;Work in progress
	cp countOF, cycDelay	;Do nothing until OF counter > delay
	brlo CYCLE_RETURN
	clr countOF		;Reset counters
	out TCNT0, countOF

	inc  ball		;Increment ball position
	cpi  ball, 24		;Reset if 20
	brlo CYCLE_BALL_CONTINUE
	ldi ball, 0
	CYCLE_BALL_CONTINUE:

	;; Load which leds to light
	andi leds1, 0b00000001	;Clear leds1
	andi leds2, 0b00000010	;Clear leds2
	;; Load to Z register for indirect jumping
	ldi ZH, high(BALL00)
	ldi ZL,  low(BALL00)
	;; Add to Z register
	mov  temp, ball
	cpi  temp, 12
	BRLO BALL_JUMP_TABLE	;Bracnch for ball moving left
	subi temp, 24
	neg  temp
BALL_JUMP_TABLE:	
	lsl temp, 1		;Multiply by 2, since each case is 2 bytes
	add ZL, temp		;Add to Z register
	ijmp
BALL00:	inc score		;increment right player score here
	ret
BALL01:	ori leds1, 0b00000010
	ret
BALL02:	ori leds1, 0b00000100
	ret
BALL03:	ori leds1, 0b00001000
	ret
BALL04:	ori leds1, 0b00010000
	ret
BALL05:	ori leds1, 0b00100000
	ret
BALL06:	ori leds1, 0b01000000
	ret
BALL07:	ori leds1, 0b10000000
	ret
BALL08:	ori leds2, 0b00000001
	ret
BALL09:	ori leds2, 0b00000100
	ret
BALL10:	ori leds2, 0b00001000
	ret
BALL11:	ori leds2, 0b00010000
	ret
BALL12:	nop			;increment left player score here
	ret
CYCLE_RETURN:	
	ret

	
CHARLIE:			;Function to control charlieplexed LEDS
	;; Switch row
	SBRC leds1, 0
	rjmp CHARLIE_ROW0
	SBRC leds2, 1
	rjmp CHARLIE_ROW1
	SBRC disp1, 2
	rjmp CHARLIE_ROW2
	SBRC disp2, 3
	rjmp CHARLIE_ROW3
	ret
CHARLIE_ROW0:
	out  DDRD,  leds1
	andi leds1, 0b11111110	;Clear selector bit for leds1
	out  PortD, leds1
	ori  leds2, 0b00000010	;Set selector bit for leds2
	ret
CHARLIE_ROW1:
	out  DDRD,  leds2
	andi leds2, 0b11111101	;Clear selector bit for leds2
	out  PortD, leds2
	ori  disp1, 0b00000100	;Set selector bit for disp1
	ret
CHARLIE_ROW2:
	out  DDRD,  disp1
	andi disp1, 0b11111011	;Clear selector bit for disp1
	out  PortD, disp1
	ori  disp2, 0b00001000	;Set selector bit for disp2
	ret
CHARLIE_ROW3:
	out  DDRD,  disp2
	andi disp2, 0b11110111	;Clear selector bit for disp2
	out  PortD, disp2
	ori  leds1, 0b00000001	;Set selector bit for leds1
	ret
	
	
DELAY:				;Wait about r16/60 seconds
	clr countOF		;Reset counters
	out TCNT0, countOF
	cp  countOF, temp	;Compare counter with temp
	brlt PC-1		;Loop until counter > temp
	ret			;Return

	
OVERFLOW:
	inc countOF
	reti			;Return after interupt

JUMP_SCORE1:
	andi disp1, 0b00000100	;Clear displays
	ldi ZL, low(DISPLAY1_0)
	ldi ZH, high(DISPLAY1_0)

	mov temp, score
	lsl temp, 1
	add ZL, temp
	ijmp
	
DISPLAY1_N:	
	ori disp1, 0b00000000
	ret

DISPLAY1_0:
	ori disp1, 0b11111010
	ret

DISPLAY1_1:
	ori disp1, 0b01100000
	ret

DISPLAY1_2:
	ori disp1, 0b11011001
	ret
	
DISPLAY1_3:
	ori disp1, 0b11110001
	ret

DISPLAY1_4:
	ori disp1, 0b01100011
	ret

DISPLAY1_5:
	ori disp1, 0b10110011
	ret

DISPLAY1_6:
	ori disp1, 0b10111011
	ret

DISPLAY1_7:
	ori disp1, 0b11100000
	ret

DISPLAY1_8:
	ori disp1, 0b11111011
	ret

DISPLAY1_9:
	ori disp1, 0b11100011
	ret



	
DISPLAY2_N:	
	ori disp2, 0b00000000
	ret

DISPLAY2_0:
	ori disp2, 0b11110110
	ret

DISPLAY2_1:
	ori disp2, 0b01100000
	ret

DISPLAY2_2:
	ori disp2, 0b11010101
	ret
	
DISPLAY2_3:
	ori disp2, 0b11110001
	ret

DISPLAY2_4:
	ori disp2, 0b01100011
	ret

DISPLAY2_5:
	ori disp2, 0b10110011
	ret

DISPLAY2_6:
	ori disp2, 0b10110111
	ret

DISPLAY2_7:
	ori disp2, 0b11100000
	ret

DISPLAY2_8:
	ori disp2, 0b11110111
	ret

DISPLAY2_9:
	ori disp2, 0b11100011
	ret
