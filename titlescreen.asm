;-------------------------
;Title screen code
;-------------------------

         sei
         ldx $fb
         txs
         ldx #$ff
         ldy #$48
         lda #$81
         sta $dc0d
         sta $dd0d
         stx $fffe
         sty $ffff
         lda #$00
         sta $d019
         sta $d01a
         ldx #$00
nosound  lda #$00
         sta $d400,x
         inx
         cpx #$18
         bne nosound
         ldx #0
         stx tcolpointer
         lda #$00
         sta $d020
         sta $d021
         lda #$1e
         sta $d018
         lda #$08
         sta $d016
         ldx #$00
drawts2   lda titlescreenmap,x
         sta $0400,x
         lda titlescreenmap+$100,x
         sta $0500,x
         lda titlescreenmap+$200,x
         sta $0600,x
         lda titlescreenmap+$2e8,x
         sta $06e8,x
         lda #$00
         sta $d800,x
         sta $d900,x
         sta $da00,x
         sta $dae8,x
         inx
         bne drawts2
         
         lda #$1b
         sta $d011
         lda #<scrolltext
         sta messread+1
         lda #>scrolltext
         sta messread+2
         ldx #<tirq
         ldy #>tirq
         lda #$7f
         stx $fffe
         sty $ffff
         ldx #<nmi
         ldy #>nmi
         stx $fffa
         sty $fffb
         
         sta $dc0d
         lda #$36
         sta $d012
         lda #$1b
         sta $d011
         lda #$01
         sta $d01a
         lda #$00
         jsr musicinit
         lda #0
         sta firebutton
         
         cli
titleloop
         lda #0
         sta rt
         cmp rt
         beq *-3
         jsr doscroll
         jsr colourscroll
         lda $dc00
         lsr
         lsr
         lsr
         lsr
         lsr
         bit firebutton
         ror firebutton
         bmi titleloop
         bvc titleloop
        
         jmp $4000 ;game
        !byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        
tirq     sta tstacka1+1
         stx tstackx1+1
         sty tstacky1+1
         asl $d019
         lda $dc0d
         sta $dd0d
         lda xpos
         sta $d016
         lda #$22
         sta $d012
         
         
        
         
       
         ldx #<tirq2
         ldy #>tirq2
         stx $fffe
         sty $ffff
tstacka1       
         lda #$00
tstackx1
         ldx #$00
tstacky1
         ldy #$00
nmi      rti       
         
tirq2    sta tstacka2+1
         stx tstackx2+1
         sty tstacky2+1
         asl $d019
         lda #8
         sta $d016
         ldy $d012

         ldx #rastertableend-rastertable 
rasloop
         lda rastertable,x
         cpy $d012
         beq *-3
         sta $d021
         nop
         iny
         dex
         bpl rasloop
         
         
         sta $d021
         
         lda #$f0
         sta $d012
         lda #1
         sta rt
         jsr musicplayer
         
         ldx #<tirq
         ldy #>tirq
         stx $fffe
         sty $ffff
tstacka2 lda #$00
tstackx2 ldx #$00
tstacky2 ldy #$00
         rti
musicplayer
         lda system
         cmp #1
         beq pal
         inc ntsctimer
         lda ntsctimer
         cmp #6
         beq resetntsc
pal      jsr musicplay
         rts
resetntsc       
         lda #0
         sta ntsctimer
         rts
       
doscroll lda xpos
         sec
         sbc #2
         and #7
         sta xpos
         bcs exitscroll
         ldx #$00
scrolloop 
         lda $07c1,x
         sta $07c0,x
         inx
         cpx #$27
         bne scrolloop
messread lda scrolltext
         cmp #$00
         bne storechar
         lda #<scrolltext
         sta messread+1
         lda #>scrolltext
         sta messread+2
         jmp messread
storechar 
         sta $07e7
         inc messread+1
         bne exitscroll
         inc messread+2
exitscroll
         rts
colourscroll
         lda tcoldelay
         cmp #2
         beq tcoldelok
         inc tcoldelay
         rts
tcoldelok
         lda #0
         sta tcoldelay
         ldx tcolpointer 
         lda titlecolourtable1,x
         sta $da7f
         lda titlecolourtable2,x
         sta $dad0 
         lda titlecolourtable3,x
         sta $db6f 
         lda titlecolourtable4,x
         sta coltemp
         lda titlecolourtable5,x
         sta $d800 
         inx    
         cpx #8
         beq loopflash
         inc tcolpointer 
         jmp setcharflash
         rts
loopflash
         ldx #0
         stx tcolpointer
setcharflash
         ldx #$00
pullback lda $da59,x
         sta $da58,x
         lda $db49,x
         sta $db48,x
         lda coltemp
         sta $dbc0,x
         inx
         cpx #$27
         bne pullback
         ldx #$27
pushfwd  lda $dad0-1,x
         sta $dad0,x
         
         lda $d800-1,x
         sta $d800,x
         dex
         bpl pushfwd
         rts

system      !byte 0
ntsctimer   !byte 0
xpos        !byte 0         
tcolpointer !byte 0
tcoldelay   !byte 0
coltemp !byte 0

titlecolourtable1
            !byte $06,$0e,$03,$01,$03,$0e,$06,$00
titlecolourtable2
            !byte $00,$02,$0a,$07,$01,$07,$0a,$02
titlecolourtable3
            !byte $09,$05,$0d,$01,$0d,$05,$09,$00
titlecolourtable4
            !byte $00,$0b,$0c,$0f,$01,$0f,$0c,$0b
titlecolourtable5
            !byte $09,$08,$07,$01,$07,$08,$09,$00

                !byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

rastertable
        !byte $00,$00,$09,$00,$09,$02,$08,$0a,$07,$07
        !byte $07,$01,$01,$01,$01,$01
        !byte $01,$01,$01,$01,$01,$01,$01,$01
        !byte $01,$01,$01,$01,$01,$01,$01,$01
        !byte $01,$01,$01,$01,$01,$01,$01,$01
        !byte $01,$01,$01,$01,$01,$01,$01,$01
        !byte $01,$01,$01,$01,$01,$01,$01,$01
        !byte $01,$01,$01,$01,$01,$01,$01,$01
        !byte $01,$01,$01,$01,$01,$01,$01,$01
        !byte $01,$01,$01,$01,$01,$01,$01
      
        
        !byte $03,$03,$03,$0e,$04,$06,$00,$06,$00
         !byte $00,$00,$00,$00,$00,$00,$00,$00
        !byte $00,$00,$00,$00,$00,$00,$00,$00
        !byte $00,$00,$00,$00,$00,$00,$00,$00
        !byte $00,$00,$00,$00,$00,$00,$00,$00
        
rastertableend
        !byte 0
titlescreenmap
        !bin "bin/titlescreen.bin"
!ct scr
scrolltext  !text " ... the new dimension proudly presents ... killer "
            !text "saucers ...    code, graphics, sound effects and music b"
            !text "y richard bayliss ...   (c) 2020 the new dimension "
            !text "...   you are welcome to copy this game for free bu"
            !text "t you are not allowed to sell it without permission"
            !text " from the new dimension ...   game instructions: "
            !text "plug a joystick into port 2 ...   breaking news ale"
            !text "rt ...   cyber city is under attack from incoming k"
            !text "iller saucers ...   your mission is to control your"
            !text " grounded vehicle and blast your rockets at the kil"
            !text "ler saucers ...   scoring points vary based on the "
            !text "type of killer saucer which you are fighting against "
            !text "...   beware, the killer saucers will a"
            !text "lso fight back in two different ways ...   the firs"
            !text "t is by dropping bombs at a random position ...   t"
            !text "he second is where they kamikaze towards you ...   "
            !text "also avoid running out of rockets ...   if you run "
            !text "out of rockets, get hit by the killer saucers or th"
            !text "eir bullets, you will lose a life ...   you do not "
            !text "get extra lives in this game either as it is a high "
            !text "score attack challenge ...   to complete"
            !text " each level you must shoot 50 killer saucers ...   "
            !text "for every level complete you will be awarded bonus "
            !text "points, based on your remainder of rockets ...   "
            !text "there are 8 levels to complete, and good reflex and "
            !text "reaction is highly recommended ...   can you save "
            !text "cyber city from alien attack? ...  good luck ...   "
            !text "this game was originally started as part of thec64 commodore format power "
            !text "pack tape challenge ...   the challenge was to design and "
            !text "develop a type in style c64 game using utilities that were "
            !text "featured on the power pack cover tapes ...   unfortunately "
            !text "i got into difficulties with the 6510 assembler, gave up "
            !text "and finished this game using cross platform utilities ...   "
            !text "i do hope you like the result ...   "
            !text "if you would like to see more new games from t.n.d and its contributors please "
            !text "visit tnd64.unikat.sk, download what you want for free "
            !text "and have fun ...    i shall see you next time ...   bye for now ...   "
            !text "                                                    "
            !byte 0
            
           
            
            
   
            
            !byte 0
            
            !byte 0

 