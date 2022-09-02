	org $8000
	lda #$ff
	sta $6002
looptop:	
	lda #$55
	sta $6000

	lda #$aa
	sta $6000

	jmp looptop
	org $FFFC
	word $8000
	word $0000
