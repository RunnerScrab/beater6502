HOME = $02
CLEAR = $01
ENTRY = $06
SETDDRADDR = $80
FUNCSET = $2F
DISPON = $0f
	
VIA_PORT_A = $8001
VIA_PORT_B = $8000
VIA_PORT_A_DIR = $8003
VIA_PORT_B_DIR = $8002	
UART = $A000	
UART_STATUS_REGISTER = $A001
UART_COMMAND_REGISTER = $A002
UART_CONTROL_REGISTER = $A003	
	
	
	org $E000		; For 8192 byte EEPROM
	
	include "lcdlib.s"	; Include LCD routines
message:
	string "I wait for"
message2:
	string "the busy flag!"
	word 0

uartmsg:
	ascii "Busy flag waiting", $0a, $0d, $00
	
reset:
	ldx #$ff		; Set stack pointer (8 bits) to 0x01FF
	txs

initvia:
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
	ldy #$FF
	jsr delayms
	jsr initlcd
	jsr ldelay
	jsr ldelay
	
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

	ldx #>uartmsg
	ldy #<uartmsg
	jsr uart_putstr
.end:
	nop
	nop
	nop
	jmp .end
	
uart_putstr:	
	pha
	
	lda $01
	pha
	lda $00
	pha
	lda $03
	pha
	lda $04
	pha
	
	stx $01			; Copy memory address to spot in ZP memory
	sty $00
	
	ldy #$00      ; y holds the cursor offset

.putstrloop:
	lda ($00), y
	cmp #$00
	beq .putstrloopend

	;; Delay here
	pha
.txwait:
	lda UART_STATUS_REGISTER
	and #$10		; Check TDRE
	beq .txwait
	pla
	
	sta UART

	iny			; advance cursor position
	jmp .putstrloop

.putstrloopend:
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

ldelay:
	pha
	php
	txa
	pha
	ldx #0
.louterloop:
	lda #0
.ldelayloop:	
	sec
	adc #0
	cmp 255
	bne .ldelayloop

	inx
	cpx 128
	bne .louterloop
	
	pla
	tax
	plp
	pla
	rts

delayms:
	;; Register Y = # of approximate milliseconds to delay	
	pha
	txa
	pha
	php
	

	cpy #0
	beq .exit
	nop
	cpy #1
	bne .delaya
	jmp .last1
.delaya:
	dey
.delay0
	ldx #$C6
.delay1
	dex
	bne .delay1
	nop
	nop
	dey
	bne .delay0
.last1	
	ldx #$C3
.delay2	
	dex
	bne .delay2
.exit

	plp
	pla
	tax
	pla
	rts
delay:
	pha
	php
	lda #0
.delayloop:	
	sec
	adc #0
	cmp 255
	bne .delayloop
	plp
	pla
	rts


	
nmi:	

	rti
irq:

	jsr lcd_waitbusyflag
	ldx #$4F
	jsr setramaddr

	lda UART		; Load a byte from the UART buffer (we know it caused the interrupt)
	tax
	jsr writelcddata 

	cmp #$21		; Clear display if a '!' is received by the UART
	bne .cleanirq

	jsr lcd_waitbusyflag
	
	;; Clear display
	ldx #$01
	jsr writelcdcmd
	
.cleanirq:
	jsr delay
	sta VIA_PORT_A
	jsr delay
	lda UART_STATUS_REGISTER ; Loading the status register, which clears the UART's interrupt bit
	rti
	
	org $FFFA		; For 8192 byte EEPROM
	word nmi
	word reset
	word irq
