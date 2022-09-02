reset:	org $8000
	lda #$ff
	sta $6002
	lda #$ff
	PHA
	clc
	lda #$00
	PLA
	sta $6000	
looptop:	
	rol
	sta $6000

	jmp looptop
	
	org $FFFA
	word nmi
	word reset
	word irq
