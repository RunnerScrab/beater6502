HOME = $02
CLEAR = $01
ENTRY = $06
SETDDRADDR = $80
FUNCSET = $2F
DISPON = $0f
	
VIA_PORT_A = $6001
VIA_PORT_B = $6000
VIA_PORT_A_DIR = $6003
VIA_PORT_B_DIR = $6002	
UART = $8000	
UART_STATUS_REGISTER = $8001
UART_COMMAND_REGISTER = $8002
UART_CONTROL_REGISTER = $8003	
	
	
	org $E000		; For 8192 byte EEPROM
message:
	string "I am (write)"
message2:
	string "protected"
	word 0
	
reset:
	lda #$ff		; Set data direction bits for port B to output
	sta VIA_PORT_B_DIR		; Port B's data direction register address
	lda #$00		; Write 0 to Port B pins
	sta VIA_PORT_B

	lda #$ff
	sta VIA_PORT_A_DIR
	lda #$00
	sta VIA_PORT_A

inituart:	
	lda #$00		; Soft-reset via status register store
	sta UART_STATUS_REGISTER

	jsr delay
	lda #$09
	sta UART_COMMAND_REGISTER
	
	jsr delay
	lda #$1E
	sta UART_CONTROL_REGISTER


main:
	jsr initlcd
	jsr delay
	
	ldx #>message
	ldy #<message
	clc
	jsr lcd_putcstr

	ldx #>message2
	ldy #<message2
	sec
	jsr lcd_putcstr
	lda #$00
	cli	
end:
	nop
	nop
	nop
	jmp end
	
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
	bcc line1inity
line2inity:
	ldy #$40
	sty $03
	ldy #$00
	jmp putcstrloop
line1inity:	
	ldy #$00      ; y holds the cursor offset
	sty $03
putcstrloop:
	tya
	clc
	adc $03
	tax
	jsr setramaddr		; set cursor position
	
	lda ($00), y
	cmp #$00
	beq putcstrloopend

	tax
	jsr writelcddata	; place character at cursor
	
	iny			; advance cursor position
	jmp putcstrloop
	
	
putcstrloopend:
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
	
delay:
	pha
	php
	lda #0
delayloop:	
	sec
	adc #0
	cmp 255
	bne delayloop
	plp
	pla
	rts
	
nmi:	

	rti
irq:
	lda UART
	jsr delay
	sta VIA_PORT_A
	jsr delay
	lda UART_STATUS_REGISTER ; Loading the status register
	rti
	
	org $FFFA		; For 8192 byte EEPROM
	word nmi
	word reset
	word irq
