	org $8000

reset:  
	lda #$ff
	sta $6002		
	lda #$00
	sta $0200

	lda #$82 		; Set CA1 interrupt in 65c22 IER
	sta $600E
	
	cli
looptop:
	lda $0200		; Load counter into accumulator
	sta $6000		; Write value of counter to LEDs
	jmp looptop

nmi:	

	rti
irq:

	inc $0200 		; Increment counter
	lda $6001
	rti
	
	org $FFFA
	word nmi
	word reset
	word irq
