	;; cycle.asm
	;; Cycles LEDs on pins 8-12
	
	.nolist
	.include "./m328Pdef.inc" ;Include definitions file
	.list

	.def countOF = r17 	;Use r17 as overflow counter
	
	.org 0x0000		;Set jump for reset
	rjmp RESET
	
	.org 0x0020		;Set jump for overflow interupt
	rjmp OVERFLOW
RESET:				  
	ldi r16, 0b00000101	;Set clock scaling to 1/1024
	out TCCR0B, r16		;See Datasheet 107-108 for more info
	;; Since clock speed 20 MHz
	;; Counter increments at 19.53 kHz
	;; Therefore, counter overflows at about 76.29 Hz
	
	ldi r16, 0b00000001	;Enable timer interrupts
	sts TIMSK0, r16		;See Datasheet 109 for more info
	
	sei			;Enable global interrupts
	
	ldi r16, 0b00000000	;Reset counter to zero
	out TCNT0, r16

	ldi r16, 0b00011111	;Set pins 8-12 as output
	out DDRB, r16
LOOP:	
	ldi r16, 0b00011111	;Load bits into r0
	out PortB, r16		;Write HIGH to pins
	
	ldi r16, 30
	rcall DELAY
	
	ldi r16, 0b00000000	;Load bits into r0
	out PortB, r16		;Write HIGH to pins

	ldi r16, 30
	rcall DELAY

	rjmp LOOP		;Loop forever 

DELAY:				;Wait about r16/60 seconds
	clr countOF		;Reset overflow counter	
	cp  countOF, r16	;Compare counter with r16
	brlt PC-1		;Loop until counter > r16
	ret			;Return
	
OVERFLOW:
	inc countOF
	reti			;Return after interupt
