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
	
	.org 0x0000		;Set jump for reset
	rjmp SETUP

	
	.org 0x0020		;Set jump for overflow interupt
	rjmp OVERFLOW
SETUP:
SETUP_CLOCK:
	ldi temp, 0b00000101	;Set clock scaling to 1/1024
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
	ldi leds1, 0b00000001	;Initialize leds1 register
	ldi leds2, 0b00000000	;Initialize leds2 register
	ldi disp1, 0b00000000	;Initialize disp1 register
	ldi disp2, 0b00000000	;Initialize disp1 register
	
	ldi cycDelay, 30	;Initalize delay at ~500ms
	ldi countOF, 0b0000000	;Reset overflow counter

	;; Initialize outputs
	ldi leds1,  0b00000000
	ldi leds2,  0b00000000
	ldi disp1,  0b00000000
	ldi disp2,  0b00000000

	ldi leds1,  0b00000000
	
	START:	
	ori  leds1, 0b00000001	;Set selector bit for leds1

LOOP:				;Main Loop
	rcall CYCLE
	rcall CHARLIE
	rjmp LOOP		;Loop forever

CYCLE:
	cp countOF, cycDelay	;Do nothing until OF counter > delay
	brlo CYCLE_RETURN
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
	clr countOF		;Reset overflow counter	
	cp  countOF, temp	;Compare counter with temp
	brlt PC-1		;Loop until counter > temp
	ret			;Return


	
OVERFLOW:
	inc countOF
	reti			;Return after interupt

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


	
DISPLAY2_N:	
	ldi disp2, 0b00001000
	ret

DISPLAY2_0:
	ldi disp2, 0b11111110
	ret

DISPLAY2_1:
	ldi disp2, 0b01101000
	ret

DISPLAY2_2:
	ldi disp2, 0b11011101
	ret
	
DISPLAY2_3:
	ldi disp2, 0b11111001
	ret

DISPLAY2_4:
	ldi disp2, 0b01101011
	ret

DISPLAY2_5:
	ldi disp2, 0b10111011
	ret

DISPLAY2_6:
	ldi disp2, 0b10111111
	ret

DISPLAY2_7:
	ldi disp2, 0b11101000
	ret

DISPLAY2_8:
	ldi disp2, 0b11111111
	ret

DISPLAY2_9:
	ldi disp2, 0b11101011
	ret
