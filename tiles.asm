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
    ;mva >chset CHBASE
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
scr equ $d100
;    org $3000
;chset
;    :1024 dta #&$FF
;    org $4000
;scr
;    :[30*$100] dta [5*#]&$FF|$80
