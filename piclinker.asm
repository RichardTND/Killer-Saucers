;Killer saucers loading picture

vid = $3f40
col = $4328

        !to "piclinker.prg",cbm
        
        *=$0801
        !basic 2064
        *=$0810
        sei
        lda $02a6
        sta system
        lda #$00
        sta button
        sta space
        sta $d020
        sta $d021
        sta $d011
        ldx #$00
setuppic lda vid,x
        sta $0400,x
        lda vid+$100,x
        sta $0500,x
        lda vid+$200,x
        sta $0600,x
        lda vid+$2e8,x
        sta $06e8,x
        lda col,x
        sta $d800,x
        lda col+$100,x
        sta $d900,x
        lda col+$200,x
        sta $da00,x
        lda col+$2e8,x
        sta $dae8,x
        inx
        bne setuppic
        
        lda #$18
        sta $d018
        sta $d016
        lda #$03
        sta $dd0d
        lda #$3b
        sta $d011
        ldx #<irq
        ldy #>irq
        lda #$7f
        stx $0314
        sty $0315
        sta $dc0d
        lda #$36
        sta $d012
        lda #$3b
        sta $d011
        lda #$01
        sta $d01a
        lda #0
        jsr $1000
        cli
loop    lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit button
        ror button
        bmi skip1
        bvc skip1
        jmp exitviewer
skip1   lda $dc01
        lsr
        lsr
        lsr
        lsr
        lsr
        bit space
        ror space
        bmi loop
        bvc loop
exitviewer
        sei
        ldx #$31
        ldy #$ea
        lda #$81
        stx $0314
        sty $0315
        sta $dc0d
        sta $dd0d
        lda #$00
        sta $d019
        sta $d01a
        ldx #$00
nosid   lda #$00
        sta $d400,x
        inx
        cpx #$18
        bne nosid
        jsr $ff81
        lda #0
        sta $d020
        sta $d021
        ldx #$00
transfercopy
        lda transfer,x
        sta $0400,x
        lda #0
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $dae8,x
        inx
        bne transfercopy
        lda #0
        sta $0800
        cli
        jmp $0400
transfer
        sei
        lda #$34
        sta $01
t1        ldx #$00
t2 lda $4800,x
        sta $0801,x
        inx
        bne t2
        inc $0409
        inc $040c
        lda $0409
        bne t1
        lda #$37
        sta $01
        cli
        jmp $080d
        
        
        
        
        
irq     inc $d019
        lda #$fa
        sta $d012
        jsr pnplayer
        jmp $ea7e
pnplayer
        lda system
        cmp #1
        beq pal
        inc ntsctimer
        lda ntsctimer
        cmp #$06
        beq resetntsc
        inc ntsctimer
pal     jsr $1003
        rts
        
resetntsc
        lda #0
        sta ntsctimer
        rts
        
ntsctimer !byte 0
system !byte 0        
button !byte 0
space !byte 0        
        
        jmp *-3
        *=$1000
        !bin "bin\intromusic.prg",,2
        *=$2000
        !bin "bin\killerpic.prg",,2
        *=$4800
        !bin "killersaucers.prg",,2
        
  