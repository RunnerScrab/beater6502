HOME = $02
CLEAR = $01
ENTRY = $06
SETDDRADDR = $80
FUNCSET = $2F
DISPON = $0f	
	
	org $8000

reset:  
	lda #$ff		; Set data direction bits for port B to output
	sta $6002		; Port B's data direction register address
	lda #$00
	sta $6000
main:
	
	ldx #$02
	jsr writelcdcmd

	ldx #$2f
	jsr writelcdcmd

	ldx #$0f
	jsr writelcdcmd

	ldx #$01
	jsr writelcdcmd

	ldx #$80
	jsr writelcdcmd

	ldx #"S"
	jsr writelcddata

	ldx #$81
	jsr writelcdcmd

	ldx #"h"
	jsr writelcddata

	ldx #$82
	jsr writelcdcmd

	ldx #"i"
	jsr writelcddata

	ldx #$83
	jsr writelcdcmd

	ldx #"t"
	jsr writelcddata
	
	
end:
	nop
	nop
	nop
	nop
	jmp end

writelcdcmd:
	;; opcode passed in A
	
	lda #%01000000		; E = 1
	sta $6000

	txa
	lsr
	lsr
	lsr
	lsr
	ora #$40
	sta $6000
	

	lda #%00000000		; E = 0
	sta $6000
	lda #%01000000		; E = 1
	sta $6000

	txa
	and #$0f
	ora #$40
	sta $6000
	
	lda #%00000000		; E = 0
	sta $6000
	jsr delay
	rts

writelcddata:
	;; data passed in A
	
	lda #%01100000		; E = 1, RS = 1
	sta $6000

	txa
	lsr
	lsr
	lsr
	lsr
	ora #$60
	sta $6000

	lda #%00000000		; E = 0
	sta $6000
	lda #%01000000		; E = 1
	sta $6000

	txa
	and #$0f
	ora #$60
	sta $6000
	
	lda #%00000000		; E = 0
	sta $6000

	jsr delay
	
	rts
	
delay:
	pha
	lda #0
delayloop:	
	sec
	adc #0
	cmp 255
	bne delayloop
	pla
	rts
	
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
