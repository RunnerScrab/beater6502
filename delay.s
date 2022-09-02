delay:
  pha
  txa
  pha
  lda #0
delayloop:
  ldx #0
innerdelayloop:
  inx
  cpx 32
  bne innerdelayloop
  sec
  adc #0
  cmp 128
  bne delayloop

  pla
  tax
  pla
  rts