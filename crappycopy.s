start:
  ldx #>array
  ldy #<array
  jsr copy

end:
  nop
  nop
  nop
  jmp end
copy:
  pha
  lda $01
  pha
  lda $00
  pha
  stx $01
  sty $00

  
  ldy #$00
loop:
  lda ($00), y
  sta $000f, y
  cpy #$05
  beq copyend
  iny
  jmp loop
copyend:
  pla
  sta $00
  pla
  sta $01
  pla
  rts

array:
  dcb $01, $02, $03, $04, $05, $06, $07, $08, $09
  dcb $0a, $0b, $0c, $0d, $0e, $0f