	;; cycle.asm
	;; Cycles LEDs on pins 8-12
	;; r18 is used to store which LED to light
	
	.nolist
	.include "./m328Pdef.inc" ;Include definitions file
	.list

	.def temp = r16		;Temporary register
	.def cycOF = r17 	;Use r17 as overflow counter
	.def cycLeds = r18	;Use r18 for state of LEDs
	;; Bits 0-4: LED states
	;; Bit 7: direction (1 to move left, 0 to move right)
	;;
	
	.def cycDelay = r19	;Use r19 for cycle speed
	
	.org 0x0000		;Set jump for setup code
	rjmp SETUP
	
	.org 0x0020		;Set jump for overflow interupt
	rjmp OVERFLOW


	
SETUP:				  
	ldi temp, 0b00000101	;Set clock scaling to 1/1024
	out TCCR0B, r16		;See Datasheet 107-108 for more info
	;; Since clock speed 20 MHz,
	;; counter will increment at about 19.53 kHz when scaled
	;; Therefore, overflow counter increments at about 76.29 Hz
	
	ldi temp, 0b00000001	;Enable timer overflow interrupts
	sts TIMSK0, temp	;See Datasheet 109 for more info
	
	sei			;Enable global interrupts
	
	ldi temp, 0b00000000	;Reset counter to zero
	out TCNT0, temp

	ldi temp, 0b00011111	;Set pins 8-12 as output
	out DDRB, temp

	ldi cycLeds, 0b10000001 ;Initialize LEDs
	ldi cycDelay, 30	;Initalize delay at ~500ms
	clr cycOF		;Reset overflow counter


	
LOOP:				;Main loop
	rcall LED_BOUNCE	;Check for bounce
	rcall LED_CYCLE		;Update which LED's to light
	rjmp LOOP		;Loop forever


	
LED_BOUNCE:		      ;Bounce if all LEDs off
	cpi cycLeds, 0b10000000	;Check for bounce right
	breq LED_BOUNCE_R	
	cpi cycLeds, 0b00000000	;Check for bounce left
	breq LED_BOUNCE_L
	ret			;Do nothing and return
LED_BOUNCE_L:
	ldi cycLeds, 0b10000001	;Set direction to left
	ret			;Return
LED_BOUNCE_R:
	ldi cycLeds, 0b00010000	;Set direction to right
	ret			;Return


	
LED_CYCLE:
	cp  cycOF, cycDelay	;Do nothing until OF count > delay
	brlo LED_CYCLE_RET

	clr cycOF		;Reset overflow counter
	
	mov temp, cycLeds	;Mask lower 5 bits
	andi temp, 0b00011111	

	;; Branch for direction (bit7)
	SBRS cycLeds, 7
	rjmp LED_CYCLE_R
LED_CYCLE_L:
	lsl temp, 1		;Left shift
	rjmp LED_CYCLE_UPDATE
LED_CYCLE_R:
	lsr temp, 1		;Right shift
	
LED_CYCLE_UPDATE:
	andi cycLeds, 0b11100000 ;Mask upper 3 bits
	andi temp, 0b00011111	 ;Mask lower 5 bits
	out PortB, temp		 ;Write output to pins
	or   cycLeds, temp	 ;Update LED states	
LED_CYCLE_RET:
	ret


	
DELAY:				;Wait about r16/60 seconds
	;; WARNING: halts program until delay is done
	clr cycOF		;Reset overflow counter	
	cp  cycOF, r16		;Compare counter with r16
	brlt PC-1		;Loop until counter > r16
	ret			;Return
	
OVERFLOW:
	inc cycOF
	reti			;Return after interupt
