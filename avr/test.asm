	;; test.asm
	;; Sets pins 8, 10 and 12 to high on an Arduino Uno
	
	.include "./m328Pdef.inc" ;Include definitions file
	ldi r16,0b00011111	  ;Load bits into r0
	out DDRB, r16		  ;Set pins to output
Start:				  ;
	ldi r16,0b00011011	  ;Load bits into r0
	out PortB, r16		  ;Write HIGH to pins
END:	rjmp END		  ;Loop forever to end
