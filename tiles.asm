    opt l-h+f-
    icl 'hardware.asm'
coarse equ $80
fine equ $82
mappos equ $83
mapfrac equ $85
tilepos equ $86
mapy equ $88
edgeoff equ $89
main equ $2000
chset equ $3000
dlist equ $3400
pm equ $3800
scr equ $4000
map equ $5000
    org main
    sei
    lda #0
    sta IRQEN
    sta NMIEN
    sta DMACTL
    sta GRACTL
    sta GRAFP0
    sta GRAFP1
    sta GRAFP2
    sta GRAFP3
    sta GRAFM
    sta COLBK
    sta fine
    sta edgeoff
    mva <scr coarse
    mva >scr coarse+1
    mva >chset CHBASE
    lda coarse
    add 48
initdraw
    jsr drawedgetiles
    inc coarse
    cmp coarse
    bne initdraw
    mva <scr coarse

    mva #$22 DMACTL
    ;mva #$2d DMACTL
    ;mva #$2e DMACTL
showframe
    lda #3
    cmp:rne VCOUNT
    sta WSYNC
    mva <dlist DLISTL
    mva >dlist DLISTH
    ldx #0
image
    ldx #$72
    ldy #$d2
    lda #$32
    :3 nop
    sta WSYNC
    sta COLPF0
    stx COLPF1
    sty COLPF2
    sta WSYNC
    mva #$6 COLPF0
    mva #$8 COLPF1
    mva #$c COLPF2
    lda VCOUNT
    cmp #124
    bne image
    ldx #0
blank
    lda PORTA
    and #$c
    ora fine
    tax
    lda joyedgetable,x
    sta edgeoff
    lda joyfinetable,x
    sta HSCROL
    sta fine
    lda joycoarsetable,x
    beq updlist
    bpl coarseup
coarsedown
    lda coarse
    sne:dec coarse+1
    dec coarse
    jmp updlist
coarseup
    inc coarse
    sne:inc coarse+1

updlist
    lda coarse
    :15 sta dlist+1+6*#
    add #$80
    :15 sta dlist+4+6*#
    ldx coarse+1
    :15 mva scrhi1,x+ dlist+2+6*#
    lda coarse+1
    adc #0
    tax
    :15 mva scrhi2,x+ dlist+5+6*#
    jsr drawedgetiles
    jmp showframe

drawedgetiles
    lda coarse
    add edgeoff
    sta drawpos+1
    lda coarse+1
    adc #0
    sta drawpos+2

    lda drawpos+1
    sta mappos
    and #3
    sta mapfrac
    lda drawpos+2
    and #$f
    lsr @
    sta mappos+1
    ror mappos
    lsr mappos+1
    ror mappos
    lsr @
    add >[map+$200]
    sta mappos+1

    mva #10 mapy
edge
    ldy #0
    lda (mappos),y
    tax
    lda tilex16,x
    ldx mapfrac
    add tilefrac,x
    tax
drawpos
    stx:inx scr
    lda drawpos+1
    add #$80
    sta drawpos+1
    bcc skiphi
    lda drawpos+2
    adc #0
    cmp >[scr+4096]
    bne donehi
    lda >scr
donehi
    sta drawpos+2
skiphi
    iny
    cpy #4
    bne drawpos
    inc mappos+1
    dec mapy
    bne edge
    rts

    ; RIGHT,LEFT,FINE -> DCOARSE,FINE
    ; 0,0,X -> 0,X
    ; 0,1,X -> (X==0),(X-1)%4
    ; 1,0,X -> -(X==3),(X+1)%4
    ; 1,1,X -> 0,X
joycoarsetable
    :4 dta 0
    dta 1,0,0,0
    dta 0,0,0,$ff
    :4 dta 0
joyfinetable
    :4 dta #
    :4 dta [#+3]%4
    :4 dta [#+1]%4
    :4 dta #
joyedgetable
    :8 dta 48
    :8 dta 0
scrhi1
    :256 dta >[scr+[#*$100]&$fff]
scrhi2
    :256 dta >[scr+[$80+#*$100]&$fff]
tilex16
    :8 dta #*16
tilefrac
    :4 dta #*4

    org dlist
    :30 dta $74,a(scr+#<<7)
    icl 'assets.asm'
    run main
