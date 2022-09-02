start:

  lda #>array
  ldx #<array
  jsr sum

end:
  nop
  nop
  nop
  nop
  jmp end


sum:
  sta $01
  stx $00
;;Save registers & zp 02
  tya
  pha
  lda $02
  pha

  ldy #$00
loop:
  lda ($00), y
  cmp 0
  beq sumend
  clc
  adc $02
  sta $02
  iny
  jmp loop
sumend:
;; Restore registers & zp 02
   ldx $02
   pla
   sta $02
   pla
   tay
   txa
   rts