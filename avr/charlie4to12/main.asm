	;; charlie4to12.asm
	;; Tests 12 common cathode charlieplexed leds on pins 8-11
	;; r18 and r19 is used to store which LEDs to light with bits 1-6
	;;
	;; Register Definitions
	;; r16		temporary
	;; r17		Timer Overflow counter
	;; r18 bit0	LED01
	;; r18 bit1	LED02
	;; r18 bit2	LED03
	;; r18 bit3	LED04
	;; r18 bit4	LED05
	;; r18 bit5	LED06
	;; r18 bit6	LED07
	;; r18 bit7	LED08
	;; r19 bit0	LED09
	;; r19 bit1	LED10
	;; r19 bit2	LED11
	;; r19 bit3	LED12 (extra)
	;; r19 bit4	ROW SELECTOR 0
	;; r19 bit5	ROW SELECTOR 1
	;; r19 bit6	ROW SELECTOR 2
	;; r19 bit7	ROW SELECTOR 3
	;; r20		cycle speed./
	
	.nolist
	.include "./m328Pdef.inc" ;Include definitions file
	.list

	.def temp = r16 	;Use r16 as temporary register
	.def countOF = r17 	;Use r17 as overflow counter
	.def leds1 = r18 	;Use r18 as output LEDS
	.def leds2 = r19 	;Use r19 as output LEDS
	.def cycDelay = r20	;Use r20 for cycle speed
	
	.org 0x0000		;Set jump for reset
	rjmp RESET
	
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
	ldi leds2, 0b10000000	;Initialize led2 register

	ldi cycDelay, 30	;Initalize delay at ~500ms
	ldi countOF, 0b0000000	;Reset overflow counter

LOOP:				;Main Loop
	;; cycle
	rcall CYCLE
	
	rcall CHARLIE
	
	
	rjmp LOOP		;Loop forever



CYCLE:				;LED cycle
	cp  countOF, cycDelay	;Do nothing until OF count > delay
	brlo LED_CYCLE_RET
	clr countOF		;Reset overflow counter

	ldi  temp, 0b00000000

	SBRS leds1, 7
	rjmp LED_CYCLE_L1
LED_CYCLE_L2:
	ldi  leds1, 0b00000000
	ori  leds2, 0b00000001
	ret
LED_CYCLE_L1:
	lsl  leds1, 1		;Left shift
	ret
LED_CYCLE_RET:
	ret

	

CHARLIE:			;Function to control charlieplexed LEDS
	mov  temp, leds2	;Copy before shifting selector
	andi temp, 0b00001111	;Bitmask
	SBRC leds2, 4
	rjmp CHARLIE_RESET	;Reset row index
	lsr  leds2, 1		;Shift row selector
	rjmp CHARLIE_SWITCH
CHARLIE_RESET:			;Reset row selector
	ori  leds2, 0b10000000
	andi leds2, 0b10001111
CHARLIE_SWITCH:
	andi leds2, 0b11110000	;Write bits 0-4 back to leds2
	or   leds2, temp
	;; Switch row
	SBRC leds2, 4
	rjmp CHARLIE_ROW0	
	SBRC leds2, 5
	rjmp CHARLIE_ROW1
	SBRC leds2, 6
	rjmp CHARLIE_ROW2
	SBRC leds2, 7
	rjmp CHARLIE_ROW3
CHARLIE_ROW0:			;Row 0
	mov  temp, leds1	;load data from leds1
	lsl  temp, 1		;Bitshift for leds 1-3
	andi temp, 0b00001110	;Bitmask for leds 1-3
	out  PortB, temp	;Write to pins
	ori  temp, 0b00000001	;Set selector bit as output
	out  DDRB, temp		;Set pins to high impedence
	ret
CHARLIE_ROW1:			;Row 1
	ldi  temp, 0b00000000	;Reset temp
	SBRC leds1, 3
	ori  temp, 0b00000001	;Set bit 0
	SBRC leds1, 4
	ori  temp, 0b00000100	;Set bit 2
	SBRC leds1, 5
	ori  temp, 0b00001000	;Set bit 3
	out  PortB, temp	;Write to pins
	ori  temp, 0b00000010	;Set selector bit as output
	out  DDRB, temp		;Set pins to high impedence
	ret
CHARLIE_ROW2:			;Row 2
	ldi  temp, 0b00000000	;Reset temp
	SBRC leds1, 6
	ori  temp, 0b00000001	;Set bit 0
	SBRC leds1, 7
	ori  temp, 0b00000010	;Set bit 2
	SBRC leds2, 0
	ori  temp, 0b00001000	;Set bit 3
	out  PortB, temp	;Write to pins
	ori  temp, 0b00000100	;Set selector bit as output
	out  DDRB, temp		;Set pins to high impedence
	ret
CHARLIE_ROW3:			;Row 3
	mov  temp, leds2	;load data from leds2
	lsr  temp, 1		;Bitshift for leds 10-12
	andi temp, 0b00000111	;Bitmask for leds 10-12
	out  PortB, temp	;Write to pins
	ori  temp, 0b00001000	;Set selector bit as output
	out  DDRB, temp		;Set pins to high impedence
	ret
	
	
	
DELAY:				;Wait about r16/60 seconds
	clr countOF		;Reset overflow counter	
	cp  countOF, temp	;Compare counter with temp
	brlt PC-1		;Loop until counter > temp
	ret			;Return


	
OVERFLOW:
	inc countOF
	reti			;Return after interupt
