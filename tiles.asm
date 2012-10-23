    opt l-h+f-
    icl 'hardware.asm'
    org $2000
start
    sei
    lda #0
    sta IRQEN
    sta NMIEN
    sta DMACTL
    mva #0 GRACTL
    mva #0 GRAFP0
    mva #0 GRAFP1
    mva #0 GRAFP2
    mva #0 GRAFP3
    mva #0 GRAFM
    mva #0 COLBK
    mva >chset CHBASE
    mva #$22 DMACTL
    lda #3
    cmp:rne VCOUNT
    sta WSYNC
showframe
    mva <dlist DLISTL
    mva >dlist DLISTH
    ldx #0
image
    sta WSYNC
    mva #$32 COLPF0
    mva #$72 COLPF1
    mva #$d2 COLPF2
    mva #$f2 COLPF3
    sta WSYNC
    mva #6 COLPF0
    mva #10 COLPF1
    mva #14 COLPF2
    mva #14 COLPF3
    :2 inx
    cpx #240
    bne image
    ldx #0
blank
    sta WSYNC
    inx
    cpx #[312-240]
    bne blank
    jmp showframe
dlist
    :30 dta $44,a(scr+#<<8)
scr equ $5000
    org scr
    :64 dta 16+0,16+4,16+8,16+12
    :64 dta 16+1,16+5,16+9,16+13
    :64 dta 16+2,16+6,16+10,16+14
    :64 dta 16+3,16+7,16+11,16+15
    :64 dta 32+0,32+4,32+8,32+12
    :64 dta 32+1,32+5,32+9,32+13
    :64 dta 32+2,32+6,32+10,32+14
    :64 dta 32+3,32+7,32+11,32+15
    :64 dta 48+0,48+4,48+8,48+12
    :64 dta 48+1,48+5,48+9,48+13
    :64 dta 48+2,48+6,48+10,48+14
    :64 dta 48+3,48+7,48+11,48+15
    :64 dta 64+0,64+4,64+8,64+12
    :64 dta 64+1,64+5,64+9,64+13
    :64 dta 64+2,64+6,64+10,64+14
    :64 dta 64+3,64+7,64+11,64+15
    :64 dta 80+0,80+4,80+8,80+12
    :64 dta 80+1,80+5,80+9,80+13
    :64 dta 80+2,80+6,80+10,80+14
    :64 dta 80+3,80+7,80+11,80+15
    :64 dta 96+0,96+4,96+8,96+12
    :64 dta 96+1,96+5,96+9,96+13
    :64 dta 96+2,96+6,96+10,96+14
    :64 dta 96+3,96+7,96+11,96+15
    :64 dta 112+0,112+4,112+8,112+12
    :64 dta 112+1,112+5,112+9,112+13
    :64 dta 112+2,112+6,112+10,112+14
    :64 dta 112+3,112+7,112+11,112+15
chset equ $3000
map equ $4000
    icl 'assets.asm'
;    org $3000
;chset
;    :1024 dta #&$FF
;    org $4000
;scr
;    :[30*$100] dta [5*#]&$FF|$80
