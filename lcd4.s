HOME = $02
CLEAR = $01
ENTRY = $06
SETDDRADDR = $80
FUNCSET = $2F
DISPON = $0f	
	
	org $E000

reset:  
	lda #$ff		; Set data direction bits for port B to output
	sta $6002		; Port B's data direction register address
	lda #$00		; Write 0 to Port B pins
	sta $6000
main:
	jsr initlcd
	
	ldx #"M"
	jsr writelcddata

	ldx #$01
	jsr setramaddr

	ldx #"e"
	jsr writelcddata

	ldx #$02
	jsr setramaddr

	ldx #"o"
	jsr writelcddata

	ldx #$03
	jsr setramaddr

	ldx #"w"
	jsr writelcddata
	
	
end:
	nop
	nop
	nop
	nop
	jmp end
	
lcd_putcstr:
	;; x contains address hiword
	;; y contains address loword
	pha
	lda $01
	pha
	lda $00
	pha
	stx $01
	sty $00
	ldy #$00
putcstrloop:
	lda ($00), y
	sta $6000
	
putcstrloopend:
	pla
	sta $00
	pla
	sta $01
	pla
	rts
initlcd:
	pha
	txa
	pha
	tya
	pha
	php

	;; HOME LCD instruction	(not sure if this is needed)
	ldx #$02
	jsr writelcdcmd
	
	;; FUNCSET instruction, setting 4-bit mode, N=1, F=1 and
	;; two don't cares in bits 0 and 1
	ldx #$2f		
	jsr writelcdcmd
	
	;; DISPON with entire display on flag = 1, cursor flag = 1
	;; and blinking cursor flag = 1
	ldx #$0f		
	jsr writelcdcmd
	
	;; Clear display
	ldx #$01
	jsr writelcdcmd
	
	;; Set DDRAM address offset to 0
	ldx #$80
	jsr writelcdcmd

	plp
	pla
	tay
	pla
	tax
	pla
	rts
setramaddr:
	;; Offset passed in X
	pha

	txa
	ora #$80
	tax

	jsr writelcdcmd

	pla
	

writelcdcmd:
	;; opcode passed in X
	pha
	tya
	pha
	ldy #$00
	jsr writelcd
	pla
	tay
	pla
	rts
	
writelcddata:
	pha
	tya
	pha
	ldy #$01
	jsr writelcd
	pla
	tay
	pla
	rts
	
writelcd:
	;; opcode passed in X
	;; y = 0 for cmd, 1 for data
	pha
	lda $04
	pha
	
	tya			; Shift y's 1 or 0 to the RS bit (bit 6)
	asl
	asl
	asl
	asl
	asl
	ora #$40			; or enable bit and RS bit together
	sta $04			; then store result at zp 0
	
	lda #%01000000		; E = 1
	ora $04
	sta $6000

	;; Send first nibble
	txa
	lsr
	lsr
	lsr
	lsr
	ora $04
	sta $6000
	

	lda #%00000000		; E = 0
	sta $6000
	lda #%01000000		; E = 1
	sta $6000

	;;  Send 2nd nibble
	txa
	and #$0f		; take only lower nibble for sending
	ora $04			; or E and RS onto opcode/data
	sta $6000
	
	lda #%00000000		; E = 0
	sta $6000
	
	jsr delay		; This delay should really be done outside this function

	pla
	sta $04
	pla
	rts
	
delay:
	pha
	php
	lda #0
delayloop:	
	sec
	adc #0
	cmp 128
	bne delayloop
	plp
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
