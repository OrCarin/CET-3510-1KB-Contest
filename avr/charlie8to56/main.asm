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
	rjmp RESET

	.org 0x0003
	rjmp BUTTON1

	.org 0x0004
	rjmp BUTTON2
	
	.org 0x0020		;Set jump for overflow interupt
	rjmp OVERFLOW
RESET:	
	ldi temp, 0b00000101	;Set clock scaling to 1/1024
	out TCCR0B, temp	;See Datasheet 107-108 for more info
	;; Since clock speed 20 MHz,
	;; counter will increment at about 19.53 kHz when scaled
	;; Therefore, overflow counter increments at about 76.29 Hz
	
	ldi temp, 0b00000001	;Enable timer overflow interrupts
	sts TIMSK0, temp	;See Datasheet 109 for more info
	
	sei			;Enable global interrupts
	
	ldi temp, 0b00000000	;Reset counter to zero
	out TCNT0, temp

	ldi leds1, 0b00000001	;Initialize led1 register
	ldi leds2, 0b00000000	;Initialize led2 register

	ldi cycDelay, 30	;Initalize delay at ~500ms
	ldi countOF, 0b0000000	;Reset overflow counter

LOOP:				;Main Loop
	ldi leds1, 0b00000001	;Initialize led1 register
	out DDRB, leds1 	;
	;; rcall CYCLE
	;; rcall CHARLIE
	rjmp LOOP		;Loop forever

CYCLE:
	ret
	

CHARLIE:			;Function to control charlieplexed LEDS
	;; Switch row
	SBRC leds1, 0
	rjmp CHARLIE_ROW0
	SBRC leds2, 1
	rjmp CHARLIE_ROW1
	SBRC leds2, 1
	rjmp CHARLIE_ROW1
	SBRC leds2, 1
	rjmp CHARLIE_ROW1

	ret
CHARLIE_ROW0:
	andi leds1, 0b11111110	;Clear selector bit for leds1
	ori  leds2, 0b00000010	;Set selector bit for leds2
	ret
CHARLIE_ROW1:
	andi leds2, 0b11111101	;Clear selector bit for leds2
	ori  disp1, 0b00000100	;Set selector bit for disp1
	ret
CHARLIE_ROW2:
	andi disp1, 0b11111011	;Clear selector bit for disp1
	ori  disp2, 0b00001000	;Set selector bit for disp2
	ret
CHARLIE_ROW3:
	andi disp2, 0b11110111	;Clear selector bit for disp2
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
