;Killer Saucers end screen

endscreen
            
            sei
            ldx #$48
            ldy #$ff
            lda #$81
            stx $fffe
            sty $ffff
            sta $dc0d
            sta $dd0d
            lda #$00
            sta $d019
            sta $d01a
         
            lda #0
            sta $d015
            lda #$ff
            sta $d01c
            lda #$0b 
            sta $d025
            lda #$01
            sta $d026
            sta firebutton
            lda #$1e
            sta $d018
            
            lda #$0b
            sta $d022
            lda #$01
            sta $d023
            
            ldx #$00
clearscreenfull
            lda #$20
            sta $0400,x
            sta $0500,x
            sta $0600,x
            sta $06e8,x
            lda #$00
            sta $d800,x
            sta $d900,x
            sta $da00,x
            sta $dae8,x
            inx
            bne clearscreenfull
            
            ldx #$00
placeend    lda endtext,x
            sta $0400+360,x
            lda endtext+40,x
            sta $0400+400,x
            lda endtext+80,x
            sta $0400+440,x
            lda endtext+120,x
            sta $0400+480,x
            lda endtext+160,x
            sta $0400+520,x
            lda endtext+200,x
            sta $0400+660,x
            lda endtext+240,x
            sta $0400+600,x
            inx
            cpx #40
            bne placeend
           
            ldx #<eirq
            ldy #>eirq
            lda #$7f
            stx $fffe
            sty $ffff
            sta $dc0d
            sta $dd0d
            lda #$36
            sta $d012
            lda #$1b
            sta $d011
            lda #$01
            sta $d01a
            lda #8
            sta $d016
            lda #0
            jsr musicinit
            cli
endloop     lda #0
            sta rt
            cmp rt
            beq *-3
            jsr endcolourwash
            lda $dc00
            lsr
            lsr
            lsr
            lsr
            lsr
            bit firebutton
            ror firebutton
            bmi endloop
            bvc endloop
            ldx #0
            stx levelpointer
            lda #1
            sta levelcounter
            lda #0
            sta firebutton
            sei
            ldx #$31
            ldy #$ea
            stx $0314
            sty $0315
            lda #$81
            sta $dc0d
            sta $dd0d
            lda #$00
            sta $d01a
            sta $d019
            lda #$18
            sta $d016
            jmp continuegame
            
eirq        sta estacka+1
            stx estackx+1
            sty estacky+1
            asl $d019
            lda $dc0d
            sta $dd0d
            lda #$fa
            sta $d012
            lda #1
            sta rt
            jsr musicplayer
estacka     lda #0
estackx     ldx #0
estacky     ldy #0
            rti
            
endcolourwash            
            lda ed
            cmp #1
            beq wishywashy
            inc ed
            rts
wishywashy  lda #0
            sta ed
            jsr scrolcol
            ldx ep
            lda et,x            
            sta $d800+360
            sta $d800+400
            sta $d800+479
            sta $d800+480
            sta $d800+559
            sta $d800+560
            sta $d800+639
            inx
            cpx #$08
            beq resetec
            inc ep
            rts
resetec     lda #0
            sta ep
            rts
scrolcol    ldx #$27
sl          lda $d800+359,x
            sta $d800+360,x
            lda $d800+399,x
            sta $d800+400,x
            lda $d800+479,x
            sta $d800+480,x
            lda $d800+559,x
            sta $d800+560,x
            dex
            bpl sl
            ldx #$00
sl2         lda $d800+441,x
            sta $d800+440,x
            lda $d800+521,x
            sta $d800+520,x
            lda $d800+601,x
            sta $d800+600,x
            inx
            cpx #$28
            bne sl2
            rts
            
            
            
            
ed !byte 0
ep !byte 0
et !byte $0b,$05,$0d,$01,$0d,$05,$0b,$09
!ct scr

endtext     
            !text "...  c o n g r a t u l a t i o n s  ... " 
            !text "                                        "
            !text " cyber city has been saved ... however, "
            !text "the bad news is that you have entered a "
            !text "time loop and will have to fight again!!"
            !text "                                        "
            !text "         press fire to continue         "
            
            