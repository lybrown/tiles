    opt l+h+f-
    icl 'hardware.asm'
    org $80
coarse org *+2
mappos org *+2
mapfrac org *+1
tilepos org *+2
mapy org *+1
edgeoff org *+1
tmp org *+1
framecount org *+1
pmbank org *+1
scrpos org *+2
xpos org *+2
xposlast org *+2
jframe org *+1
veldir org *+1
vel org *+1
blink org *+1
runframe org *+1
dir org *+1
rightleft org *+1
footpos org *+2
ground org *+1
lastjump org *+1
midair org *+1
foottile org *+1

inflate_zp equ $f0

ntsc equ 0
main equ $2000
dlist equ $3000
pm equ $3400
song equ $4000
player equ $6000
scr equ $9000
map equ $b000
chset equ $e000
buffer equ $8000
mapheight equ 16
mapwidth equ 256
linewidth equ $40
hx equ 100
hy equ 100
bank0 equ $82
bank1 equ $86
bank2 equ $8A
bank3 equ $8E
bankmain equ $FE
velstill equ 15

    org main
relocate
    sei
    lda #0
    sta IRQEN
    sta NMIEN
    sta DMACTL
    cmp:rne VCOUNT
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
setbank0
    mva #bank0|1 PORTB
    rts
setbank1
    mva #bank1|1 PORTB
    rts
setbank2
    mva #bank2|1 PORTB
    rts
setbank3
    mva #bank3|1 PORTB
    rts
setbankmain
    mva #bankmain|1 PORTB
    rts
clearbank
    mva #$40 clearst+2
    mva #$60 clearst+5
    ldx #0
    lda #0
    ldy #$60
clearst
    sta $4000,x
    sta $6000,x
    inx
    bne clearst
    inc clearst+2
    inc clearst+5
    cpy clearst+2
    bne clearst
    rts
banks
    :64 dta bank0+[[#%4]<<2]
    ;:64 dta [[#*4]&$e0] | [[#*2]&$f] | $01
;inflate
;    icl 'inflate.asm'
disable_antic
    lda #0
    cmp:rne VCOUNT
    sta 559 ; DMACTL shadow
    lda #128
    cmp:rne VCOUNT
    rts
    ini disable_antic

    org dlist
    ift ntsc
    :25 dta $54+[#==0]*$20,a(scr+#<<6)
    els
    :31 dta $54+[#==0]*$20,a(scr+#<<6)
    eif
    dta $41,a(dlist)
    icl 'assets.asm'
    icl 'sprites.asm'
    ini setbankmain
    org song
    ins 'ruffw1.tm2',6
    org player
    icl 'tmc2play.asm'

    org main
    sei
    lda #0
    sta IRQEN
    sta NMIEN
    sta DMACTL
    sta COLBK
    sta COLPF3
    sta SIZEP0
    sta SIZEP1
    sta SIZEP2
    sta SIZEP3
    mva #$11 PRIOR
    mva #$ff SIZEM
    mva #$3f COLPM0
    sta COLPM1
    sta COLPM2
    sta COLPM3
    mva #hx HPOSP0
    sta HPOSM3
    mva #hx+8 HPOSP1
    sta HPOSM2
    mva #hx+16 HPOSP2
    sta HPOSM1
    mva #hx+24 HPOSP3
    sta HPOSM0
    lda #$70
    ldy <song
    ldx >song
    jsr player+$300 ; init

die
    lda #0
    sta edgeoff
    sta lastjump
    sta midair
    sta DMACTL
    sta GRACTL

    mva #$ff veldir
    mva #bankmain PORTB
    mva #japex jframe
    mva #26 ground
    mva #$50 blink
    mwa #$0030 xpos
    mwa #scr coarse
    mva >chset CHBASE

    lda #0
    tax
    jsr player+$300 ; init

initdraw
    jsr drawedgetiles
    inc coarse
    lda coarse
    cmp #64
    bne initdraw
    mva <scr coarse

    lda #124
    cmp:rne VCOUNT
    mva #$3e DMACTL
    jmp blank
showframe
    lda blink
    seq:dec blink
    ldx #0
    and #2
    sne:ldx #3
    stx GRACTL
    lda #3
    cmp:rne VCOUNT
    sta WSYNC
    ; line 7
    mva <dlist DLISTL
    mva >dlist DLISTH
    ; Pal Blending per FJC, popmilo, XL-Paint Max, et al.
    ; http://www.atariage.com/forums/topic/197450-mode-15-pal-blending/
    ldx #$72
    ldy #$d2
    lda #$32
    stx COLPF1
    sta COLPF0
    sta WSYNC
    ; line 8 - bad line
    sty COLPF2
    sta WSYNC
    ; line 9
    mva #$6 COLPF0
    mva #$8 COLPF1
    mva #$c COLPF2
    ldx #$72
    ldy #$d2
    lda #$32
    :4 nop
    stx COLPF1
    sta COLPF0
    sta WSYNC
    sty COLPF2
    sta WSYNC
    mva #$6 COLPF0
    mva #$8 COLPF1
    mva #$c COLPF2
    ldx #$72
    ldy #$d2
    lda #$32
    :4 nop
    stx COLPF1
    sta COLPF0
    sta WSYNC
    sty COLPF2
    sta WSYNC
    mva #$6 COLPF0
    mva #$8 COLPF1
    mva #$c COLPF2
    ldx #$72
    ldy #$d2
    lda #$32
    :4 nop
    stx COLPF1
    sta COLPF0
    sta WSYNC
    sty COLPF2
    sta WSYNC
    ; Full-screen vertical fine scrolling per Rybags:
    ; http://www.atariage.com/forums/topic/154718-new-years-disc-2010/page__st__50#entry1911485
    mva #$7 VSCROL
    mva #$6 COLPF0
    mva #$8 COLPF1
    mva #$c COLPF2
image
    ldx #$72
    ldy #$d2
    lda #$32
    :4 nop
    stx COLPF1
    sta COLPF0
    sta WSYNC
    sty COLPF2
    lda #$6
    sta WSYNC
    sta COLPF0
    mva #$8 COLPF1
    mva #$c COLPF2
    lda VCOUNT
    ift ntsc
    cmp #90
    els
    cmp #124
    eif
    bne image
blank

ymove
    lda PORTA
    and #1
    cmp lastjump
    sta lastjump
    bcs nojump  ; didn't just press up
    lda midair
    bne nojump  ; midair
    lda #japex
    cmp jframe
    bcc nojump  ; japex < jframe
    lda ground
    sub #jmapheight
    sta ground
    mva #jlast jframe
    mva #1 midair
    bne ymovedone
nojump
    lda jframe
    sne:mva #jextra jframe
    dec jframe
ymovedone

    ; PORTA bits: right,left,down,up
    ; vi+=1 if right, clamp max
    ; vi-=1 if left, clamp min
    ; vi+=sign(v) if !right and !left, clamp 0
    ; dir=1 if v>0
    ; dir=0 if v<0
    ; dir'=dir if v==0
    ; p+=v[vi]
    ; runframe=0 if v==0
    ; runframe+=1 if v!=0, modulus
    ; bank=1 if dir
    ; bank=2 if !dir
    ; bank=3 if v==0 or midair
    ; PMBASE=0 if v==0 and dir
    ; PMBASE=1 if v==0 and !dir
    ; PMBASE=2 if midair and dir
    ; PMBASE=3 if midair and !dir
    ; PMBASE=pmbase[runframe] otherwise

xmove
    lda PORTA
    and #%1100
    sta rightleft
    :3 asl @
    ora veldir
    tax
    lda veldirtable,x
    sta veldir
    and #$1f
    ldy #0
    cmp #velstill
    scc:ldy #48
    sty edgeoff
    sta vel
    tax
    mwa xpos xposlast
    lda veltablelo,x
    add:sta xpos
    lda veltablehi,x
    adc:sta xpos+1
xmovedone

adjust
    ; mapy = ground + jumpmap[jframe]
    ldx jframe
    lda jumpmap,x
    add ground
    sta mapy

checkpit
    bmi nopit
    cmp #30
    scc:jmp die
nopit

    ; foottile = map[xpos_w>>6 + herox + mapy<<8]
    mva xpos+1 footpos
    lda xpos
    asl @
    rol footpos
    asl @
    rol footpos
    lda mapy
    and #$1f
    adc >map
    sta footpos+1
    ldy #5 ; herox offset
    lda (footpos),y
    sta foottile

    ;and #$f8
    ;ora #7
    ;sta (footpos),y

    and #$80
    ; if tile.blockx: vel = dir ? 1 : -1; xpos = xposlast
    beq adjusty
adjustx
    ldx #[velstill-1]
    ldy veldir
    spl:ldx #[[velstill+1]|$80]
    stx veldir
    mwx xposlast xpos

adjusty
    ; if tile.blocky: ground = mapy; jframe = japex
    lda foottile
    and #$40
    beq setmidair
    ; skip if jframe >= japex
    ldy jframe
    cpy #japex
    bcs adjustdone
    mva #japex jframe
    mva mapy ground
    mva #0 midair
    beq adjustdone
setmidair
    mva #1 midair
adjustdone

coin
    mva #bankmain PORTB
    ldy #0
    lda foottile
    and #7
    cmp #7
    sne:ldy #$b
    cmp #6
    sne:ldy #$c
    cpy #0
    beq coindone
    lda #$23
    ldx #$ff
    jsr player+$300 ; play sfx
    lda foottile
    and #$f8
    ;ora #3
    ldy #5
    sta (footpos),y
coindone

music
    jsr player+$303 ; play music
    inc:lda framecount
    and #$c
    ora >chset
    sta CHBASE
musicdone

pose
    ; midair
    lda midair
    ; still
    ldy vel
    cpy #velstill
    bne moving
    ldy rightleft
    cpy #%1100
    bne moving
    ora #2
moving
    ; dir
    ldy veldir
    spl:ora #4
    tax
    mva bank_dir_still_midair,x PORTB
    lda pmbase_dir_still_midair,x
    bpl notrunning
    lda:inc runframe
    :2 lsr @
    and #7
    tax
    mva pmbasetable,x PMBASE
    jmp posedone
notrunning
    sta PMBASE
    mva #0 runframe
posedone

update_display
    mva xpos coarse
    lda xpos+1
    lsr @
    ror coarse
    lsr @
    ror coarse
    lsr @
    ror coarse
    lsr @
    ror coarse
    add >scr
    sta coarse+1

    lda xpos
    and #$c
    :2 lsr @
    tax
    mva hscroltable,x HSCROL

    ldx jframe
    mva jumpvscrol,x VSCROL
    lda coarse
    add jumpscrlo,x
    sta scrpos
    lda coarse+1
    adc jumpscrhi,x
    ldx ground
    add ground2scr,x
    sta scrpos+1

    ldx #0
    lda scrpos
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

    lda scrpos+1
    and #$f
    :2 asl @
    sta tmp
    txa
    ora tmp
    tax
    :31 dta {lda a:,x},a(coarsehitable+#),{sta a:},a(dlist+2+3*#)

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
    ror mappos
    lsr @
    ror mappos
    sta mappos+1
    add >map
    sta mappos+1

    mva #mapheight mapy
edge
    ldy #0
    lda (mappos),y
    and #7
    tax
    lda tilex16,x
    ldx mapfrac
    add tilefrac,x
    tax
drawpos
    stx:inx $ffff
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
    :2 inc mappos+1
    dec mapy
    bne edge
    rts

tilex16
    :8 dta #*16
tilefrac
    :4 dta #*4
coarsehitable
    :256 dta >[scr+[[#*linewidth]&$fff]]

>>> my $jsteps = 39;
>>> my $jheight = 3;
>>> my $jextra = 32;
>>> my $jhalf = int($jsteps / 2);
>>> my $japex = $jextra + $jhalf;
>>> my $jsoff = 8;
>>> print "jextra equ $jextra\n";
>>> print "jlast equ ",$jextra + $jsteps - 2,"\n";
>>> print "japex equ ",$japex,"\n";
>>> print "jmapheight equ ",$jheight*2,"\n";
>>> print "jsoff equ $jsoff\n";
>>> my $acc = $jheight/(($jsteps-1)/2)**2;
>>> my @traj = map { $jheight-$jheight+$acc*$_*$_ } -$jhalf .. $jhalf-1;
>>> unshift @traj, $jheight+$_/2 for 1 .. $jextra;
jumpscrlo
>>> printf "    dta %d\n", (int(($jsoff + $_)*4)&3)*0x40 for @traj;
jumpscrhi
>>> printf "    dta %d\n", int($jsoff + $_) for @traj;
jumpmap
>>> printf "    dta %d\n", 2*int($_) for @traj;
jumpvscrol
>>> printf "    dta %d\n", int(($jsoff + $_)*32)&6 for @traj;
ground2scr
    :256 dta #/2+3

veldirtable
>>> my $i = 0;
>>> for my $dir (0, 1) {
>>> for my $rightb (0, 1) {
>>> for my $leftb (0, 1) {
>>> for my $vel (0 .. 31) {
>>>   my $dirn = !$rightb ? 1 : !$leftb ? 0 : $dir;
>>>   my $stop = !($rightb ^ $leftb) ? 1 : 0;
>>>   my $right = (!$rightb && $leftb) ? 1 : 0;
>>>   my $left = ($rightb && !$leftb) ? 1 : 0;
>>>   my $veln = $vel;
>>>   $veln += 1 if $right and $veln < 30;
>>>   $veln -= 1 if $left and $veln > 0;
>>>   $veln -= 1 if $stop and $veln > 15;
>>>   $veln += 1 if $stop and $veln < 15;
>>>   printf "    ; i=%x dirn=$dirn stop=$stop right=$right left=$left vel=$vel veln=$veln\n", $i++;
>>>   printf "    dta %d\n", $dirn<<7|$veln;
>>> }}}}
veltablelo
    :31 dta [#*16/15]-16
veltablehi
    :31 dta [#<15]*$ff
bank_dir_still_midair
>>> for my $dir (0, 1) {
>>> for my $still (0, 1) {
>>> for my $midair (0, 1) {
>>>   printf "    dta bank%s\n", $midair ? $dir ? 1 : 2 : $still ? 3 : $dir ? 1 : 2;
>>> }}}
pmbase_dir_still_midair
>>> for my $dir (0, 1) {
>>> for my $still (0, 1) {
>>> for my $midair (0, 1) {
>>>   printf "    dta \$%x\n",
>>>     0x40 + 8 * ($midair ? 6 : $still ? $dir ? 0 : 1 : 8);
>>> }}}
pmbasetable
    :8 dta $40+8*#
hscroltable
    :4 dta 3,2,1,0


    run main
