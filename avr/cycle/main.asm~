	;; cycle.asm
	;; Cycles LEDs on pins 8-12
	
	.include "./m328Pdef.inc" ;Include definitions file
	ldi r16, 0b00011111	  ;Load bits into r0
	out DDRB, r16		  ;Set pins to output
RESET:				  ;
	ldi r16, 0b00000101	  ;
	out TCCR0B, r16		  ;
	ldi r16, 0b00000001	  ;
	sts TIMSK0, r16		  ;
	sei			  ;Enable interrupts
	ldi r16, 0b00000000	  ;
	out TCNT0, r16		  ;
START:	
	ldi r16, 0b00010101	  ;Load bits into r0
	out PortB, r16		  ;Write HIGH to pins
END:	rjmp END		  ;Loop forever to end
