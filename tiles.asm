    opt l-h+f-
    icl 'hardware.asm'
coarse equ $80
fine equ $83
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
    mva <scr coarse
    mva >scr coarse+1
    mva >scr+$80 coarse+2
    mva >chset CHBASE
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
    cmp #123
    bne image
    ldx #0
blank
    lda PORTA
    and #$c
    ora fine
    tax
    lda joyfinetable,x
    sta HSCROL
    sta fine
    lda joycoarsetable,x
    beq updlist
    bpl coarseup
coarsedown
    dec coarse
    cmp #$ff
    ;sne:dec coarse+1
    cmp #$7f
    ;sne:dec coarse+2
    jmp updlist
coarseup
    inc coarse
    ;sne:inc coarse+1
    cmp $80
    ;sne:inc coarse+2

updlist
    lda coarse
    :15 sta dlist+1+6*#
    add #$80
    :15 sta dlist+4+6*#
    ldx coarse+1
    :15 mva scrhi1,x+ dlist+2+6*#
    ldx coarse+2
    :15 mva scrhi2,x+ dlist+5+6*#

    jmp showframe

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
scrhi1
    :256 dta >[scr+[#*$100]&$fff]
scrhi2
    :256 dta >[scr+[$80+#*$100]&$fff]

    org dlist
    :30 dta $74,a(scr+#<<7)
    org scr
    :256 dta 0
    :32 dta 48+0,48+4,48+8,48+12
    :32 dta 48+1,48+5,48+9,48+13
    :32 dta 48+2,48+6,48+10,48+14
    :32 dta 48+3,48+7,48+11,48+15
    :32 dta 80+0,80+4,80+8,80+12
    :32 dta 80+1,80+5,80+9,80+13
    :32 dta 80+2,80+6,80+10,80+14
    :32 dta 80+3,80+7,80+11,80+15
    :32 dta 96+0,96+4,96+8,96+12
    :32 dta 96+1,96+5,96+9,96+13
    :32 dta 96+2,96+6,96+10,96+14
    :32 dta 96+3,96+7,96+11,96+15
    :32 dta 112+0,112+4,112+8,112+12
    :32 dta 112+1,112+5,112+9,112+13
    :32 dta 112+2,112+6,112+10,112+14
    :32 dta 112+3,112+7,112+11,112+15
    :32 dta 64+0,64+4,64+8,64+12
    :32 dta 64+1,64+5,64+9,64+13
    :32 dta 64+2,64+6,64+10,64+14
    :32 dta 64+3,64+7,64+11,64+15
    :32 dta 32+0,32+4,32+8,32+12
    :32 dta 32+1,32+5,32+9,32+13
    :32 dta 32+2,32+6,32+10,32+14
    :32 dta 32+3,32+7,32+11,32+15
    :1 dta 96+0,96+4,96+8,96+12
    :31 dta 16+0,16+4,16+8,16+12
    :1 dta 96+1,96+5,96+9,96+13
    :31 dta 16+1,16+5,16+9,16+13
    :1 dta 96+2,96+6,96+10,96+14
    :31 dta 16+2,16+6,16+10,16+14
    :1 dta 96+3,96+7,96+11,96+15
    :31 dta 16+3,16+7,16+11,16+15
    icl 'assets.asm'
    run main
