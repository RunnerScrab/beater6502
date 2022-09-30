

lcd_putcstr:
	;; x contains address hiword
	;; y contains address loword
	;; If carry flag == 1, print on line 2
	;; If carry flag == 0, print on line 1
	pha
	
	lda $01
	pha
	lda $00
	pha
	lda $03
	pha
	lda $04
	pha
	
	stx $01
	sty $00
	bcc .line1inity
.line2inity:
	ldy #$40
	sty $03
	ldy #$00
	jmp .putcstrloop
.line1inity:	
	ldy #$00      ; y holds the cursor offset
	sty $03
.putcstrloop:
	tya
	clc
	adc $03
	tax
	jsr setramaddr		; set cursor position
	
	lda ($00), y
	cmp #$00
	beq .putcstrloopend

	tax
	jsr writelcddata	; place character at cursor
	
	iny			; advance cursor position
	jmp .putcstrloop
	
	
.putcstrloopend:
	pla
	sta $04
	pla
	sta $03
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
	jsr delay
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

	tya			; Shift y's 1 or 0 to the RS bit (pb5)
	asl			; RS is 1 for data, 0 for command
	asl
	asl
	asl
	asl
	ora #$40			; or enable bit and RS bit together
	sta $04			; then store result at zp 0
	
	lda #%01000000		; E = 1
	ora $04
	sta VIA_PORT_B

	;; Send first nibble
	txa
	lsr
	lsr
	lsr
	lsr
	ora $04
	sta VIA_PORT_B
	

	lda #%00000000		; E = 0
	sta VIA_PORT_B
	lda #%01000000		; E = 1
	sta VIA_PORT_B
	
	;;  Send 2nd nibble
	txa
	and #$0f		; take only lower nibble for sending
	ora $04			; or E and RS onto opcode/data
	sta VIA_PORT_B
	
	lda #%00000000		; E = 0
	sta VIA_PORT_B

	jsr delay
	
	pla
	sta $04
	pla
	rts



