.nolist
.include "./m328Pdef.inc"
.list

.def temp = r16
.def countOF = r17
.def BUTT = r26 


.org 0x0000
rjmp SETUP

.org 0x0020
rjmp OVERFLOW



SETUP:		
	ldi temp,0b00000000
	out DDRC,temp
	ldi temp,0b00000001
	out PortC,temp
		
	ldi temp,0b00000010   ;Enable pin change interrupts A0 - A5
	sts PCICR,temp		  ;Start from Pages 73
	
	ldi temp,0b00000001   
	sts PCMSK1,temp

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

	ldi r18,0b00000001          
	out DDRB,r18				;Setting pin 8 as an Output
	
	out PortB,r18				;Setting every pin to low except for pin 8

BUTTSETUP:	
	BUTT1:
		ldi temp, 0b00000001	; Toggle light
		eor r26, temp
		out PortC,r26
	
		ret     ;return for interrupt
	
	BUTT2:
		ldi temp, 0b00000010	; Toggle light
		eor r26, temp
		out PortC,r26
		
		ret     ;return for interrupt
		
BUTT1LOGIC:
	SBRC PortC
	rjmp BUTT1
	nop 
	
BUTT2LOGIC:
	SBRC PortC
	rjmp BUTT2
	nop

	



loop:
	rjmp loop
	
DELAY:				;Wait about r16/60 seconds
	;; WARNING: halts program until delay is done
	clr countOF		;Reset overflow counter	
	cp  countOF, r16	;Compare counter with r16
	brlt PC-1		;Loop until counter > r16
	ret			;Return

OVERFLOW:
	inc countOF
	reti			;Return after interupt
	