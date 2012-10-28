    opt l-h+f-
    icl 'hardware.asm'
coarse equ $80
fine equ $82
mappos equ $83
mapfrac equ $85
tilepos equ $86
mapy equ $88
edgeoff equ $89
tmp equ $8a
framecount equ $8b
main equ $2000
dlist equ $3000
pm equ $3400
song equ $4000
player equ $6000
scr equ $9000
map equ $b000
chset equ $c000
buffer equ $8000
linewidth equ $40
    org main
relocate
    sei
    lda #0
    sta IRQEN
    sta NMIEN
    sta DMACTL
    mva PORTB tmp
    ldx buffer+4
    lda banks,x
    sta PORTB
    mwa #buffer+5 ld+1
    mwa buffer st+1
ld  lda $ffff
st  sta $ffff
    inc ld+1
    sne:inc ld+2
    inc st+1
    sne:inc st+2
    lda st+1
    cmp buffer+2
    bne ld
    lda st+2
    cmp buffer+3
    bne ld
    mva #$82 PORTB
    rts
start
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
    lda #$70
    ldy <song
    ldx >song
    jsr player+$300 ; init
    lda #0
    tax
    jsr player+$300 ; init
    mva <scr coarse
    mva >scr coarse+1
    mva >chset CHBASE
initdraw
    jsr drawedgetiles
    inc coarse
    lda coarse
    cmp #49
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
    inc:lda framecount
    and #$1f
    bne nosfx
    lda framecount
    and #$3f
    seq:ldy #$b
    sne:ldy #$c
    lda #$23
    ldx #1
    ;jsr player+$300 ; play sfx
nosfx
    and #$c
    ora >chset
    sta CHBASE
    jsr player+$303 ; play music
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
    ldx #0
    lda coarse
    :8 sta dlist+1+12*#
    add #linewidth
    scc:ldx #3
    :8 sta dlist+4+12*#
    add #linewidth
    scc:ldx #2
    :8 sta dlist+7+12*#
    add #linewidth
    scc:ldx #1
    :7 sta dlist+10+12*#

    lda coarse+1
    and #$f
    :2 asl @
    sta tmp
    txa
    ora tmp
    tax
    :31 dta {lda a:,x},a(coarsehitable),{sta a:},a(dlist+2+3*#),{inx}

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
    add >[map+8*linewidth]
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
    add #linewidth
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
tilex16
    :8 dta #*16
tilefrac
    :4 dta #*4
coarsehitable
    :128 dta >[scr+[[#*linewidth]&$fff]]
banks
    :64 dta $82
    ;:64 dta [[#*4]&$e0] | [[#*2]&$f] | $01

    org dlist
    :30 dta $54,a(scr+#<<6)
    dta $41,a(dlist)
    icl 'assets.asm'
    org song
    ins 'ruffw1.tm2',6
    org player
    icl 'tmc2play.asm'
    run start
