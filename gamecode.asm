;Game code:
offsetposition = $da
starting_level = 0        
;switch off irq and setup game
;screen.

         sei
         
         ldx #$48
         ldy #$ff
         lda #$81
         sta $dc0d
         sta $dd0d
         stx $fffe
         sty $ffff
         lda #$00
         sta $d019
         sta $d01a
         ldx $fb
         txs
         ldx #$00
nosoundg  lda #$00
         sta $d400,x
         inx
         cpx #$18
         bne nosoundg
;prepare hardware properties

         lda #$1e   ;char @ $3800
         sta $d018
         lda #$18   ;screen h mode
         sta $d016
         lda #$0b
         sta $d022
         lda #$01
         sta $d023
         lda #$05   ;border colour
mkdat    lda dat,x ;first segment 2
         lda #$00   ;screen colour
         sta $d021
         lda #$00   ;no sprites yet
         sta $d015
         lda #$00
         sta $d020
    
         lda #$0b
         sta $d025
         lda #$01
         sta $d026
         lda #$ff
         sta $d01c
         lda #$00
         sta $d01b
         sta $d017
         lda #$01
         sta levelcounter
         lda #$33
         sta lives

         lda #$39
         sta missilecounter
         sta missilecounter+1
        
         ldx #0
copystartspeed
         lda startspeed,x
         sta enemy1speed,x
         sta enemy1speedbackup,x
         inx
         cpx #$0a
         bne copystartspeed

;zero the player score

         ldx #$05
zeroscor lda #$30
         sta score,x
         lda hiscore,x
         sta hiscorepos,x
         dex
         bpl zeroscor
        
continuegame
          ldx #$00
pn        lda dat,x
          sta $0400,x
          inx
          cpx #$28
          bne pn
          
          lda #starting_level
          sta levelpointer
 
;prepare and setup irq raster
;interrupts
         
          ldx #<irq
          ldy #>irq
          lda #$36
          sta $d012
          stx $fffe
          sty $ffff
          lda #$7f
          sta $dc0d
          lda #$1b
          sta $d011
          lda #$01
          sta $d01a
          lda #$00
          jsr sfxinit
          lda #maxshots
          sta shotcount
        
          cli
nextlevel
        ldx levelpointer
        lda levelspeedtablelow,x
        sta setuplevelspeedtable+1
        lda levelspeedtablehi,x
        sta setuplevelspeedtable+2
        lda fireintensity,x 
        sta enemybulletdelayamount
        lda firespeedtable,x
        sta alienbulletspeed
        inx
        cpx #9
        beq GameRestart
        lda #maxshots
        sta shotcount
        jmp setupnewlevel
GameRestart
        ldx #0
        stx levelpointer 
        jmp endscreen
setupnewlevel
        ldx #$00
setuplevelspeedtable
        lda $ffff,x 
        sta levelspeedinstr,x
        inx
        cpx #level1speedtableend-level1speedtable 
        bne setuplevelspeedtable

          ;prepare and draw main game screen

         ldx #$00
drawscr  ldy dat,x
         lda dat2,y
         sta $d800,x
         ldy dat+$100,x
         lda dat2,y
         sta $d900,x
         ldy dat+$200,x
         lda dat2,y
         sta $da00,x
         ldy dat+$2e8,x
         lda dat2,y
         sta $dae8,x
         lda dat+40,x
         sta $0400+40,x
         lda dat+$100,x
         sta $0500,x
         lda dat+$200,x
         sta $0600,x
         lda dat+$2e8,x
         sta $06e8,x
         inx
         bne drawscr

         ldx #$00
restorescorepanel
         lda score,x
         sta scorepos,x
         lda hiscore,x
         sta hiscorepos,x
         inx
         cpx #6
         bne restorescorepanel
         

          lda #$00
          jsr sfxinit
          lda levelcounter
          clc
          adc #$30
          sta levpos
          lda lives
          sta livespos
         lda #$39
         sta missilecounter
         sta missilecounter+1
         lda missilecounter
         sta missilepos
         lda missilecounter+1
         sta missilepos+1

        ;setup game sprites

         ldx #$00
scnclrsp   lda startpos,x
         sta objpos,x
         inx
         cpx #$10
         bne scnclrsp
         lda player
         sta $07f8
         lda bullet
         sta $07f9
         lda saucer1
         sta $07fa
         lda saucer2
         sta $07fb
         lda saucer3
         sta $07fc
         lda saucer4
         sta $07fd
         lda bullet2
         sta $07fe
         lda saucer1
         sta $07ff
         lda #$0f
         sta $d027
         lda #$0a
         sta $d028
         ldx #$00
colrize lda colinstr,x
         sta $d029,x
         inx
         cpx #6
         bne colrize
        
;zero the y position for enemy
;speed, so at the start of the
;game the enemies move x only.

          ldx #$00
zeroy     lda #$00
          sta enemy1speed+1,x
          inx
          inx
          cpx #$0a
          bne zeroy
          lda #0
          sta playerdead
          sta bulletdead
          lda #$ff
          sta $d015

          jmp gameloop

;maintain game interrupt in action

irq      sta gstacka+1
         stx gstackx+1
         sty gstacky+1
         asl $d019
         lda $dc0d
         sta $dd0d
         lda #$fa
         sta $d012
         jsr starfield
         lda #$01
         sta rt
         jsr sfxplay
gstacka  lda #0
gstackx  ldx #0
gstacky  ldy #0
         rti
         

starfield
       
         jsr animlazer1
         jsr animlazer2
         jsr animpixel1
         rts


animlazer1
         ldx #7
aniloop  lda lazerleft,x
         asl
         rol lazerleft,x
         dex
         bpl aniloop 
         rts
animlazer2
         ldx #7
aniloop2 lda lazerright,x
         lsr
         ror lazerright,x
         dex
         bpl aniloop2
         rts

animpixel1
         lda $3fe1
         asl
         rol $3ff9
         rol $3ff1
         rol $3fe9
         rol $3fe1
         lda $3fe3
         asl
         rol $3ffb
         rol $3ff3
         rol $3feb
         rol $3fe3
         lda $3fe3
         asl
         rol $3ffb
         rol $3ff3
         rol $3feb
         rol $3fe3
         lda $3fe5
         asl
         rol $3ffd
         rol $3ff5
         rol $3fed
         rol $3fe5
         lda $3fe5
         asl
         rol $3ffd
         rol $3ff5
         rol $3fed
         rol $3fe5
         lda $3fe5
         asl
         rol $3ffd
         rol $3ff5
         rol $3fed
         rol $3fe5
         lda $3fe7
         asl
         rol $3fff
         rol $3ff7
         rol $3fef
         rol $3fe7
         rts


;main game loop

gameloop lda #$00
         sta rt
         cmp rt
         beq *-3
         jsr routines
        
         jmp gameloop

expand   ldx #$00
exloop   lda objpos+1,x
         sta $d001,x
         lda objpos,x
         asl a
         ror $d010
         sta $d000,x
         inx
         inx
         cpx #$10
         bne exloop
         rts
        ;lda bulletdead

;setup sprite animation

animspr  lda animdelay
         cmp #$04
         beq doanim
         inc animdelay
         rts
doanim   lda #$00
         sta animdelay
         ldx animpointer
         lda bulletframe1,x
         sta bullet
         lda saucer1frame,x
         sta saucer1
         lda saucer2frame,x
         sta saucer2
         lda saucer3frame,x
         sta saucer3
         lda saucer4frame,x
         sta saucer4
         lda bullet2frame,x
         sta bullet2
         inx
         cpx #4
         beq animexit
         inc animpointer
         rts
animexit ldx #$00
         stx animpointer
         rts

;player control

playercontrol ;
          lda playerdead
          cmp #$01
          beq killplayer
          jmp moveplayer

;the player dies ... kill it
;and then respawn

killplayer ;
         lda pexplodedelay
         cmp #$02
         beq okaytoblowup
         inc pexplodedelay
         rts
okaytoblowup ;
         lda #$00
         sta pexplodedelay
         ldx pexplodepointer
         lda pexplodeinstr,x
         sta $07f8
         lda #$07
         sta $d027
         inx
         cpx #$10
         beq loselive
         inc pexplodepointer
         rts
loselive dec lives
         lda lives 
        
         sta livespos
         lda lives
         cmp #$30
         beq gameover
         ldx #$00
         stx pexplodepointer
         lda #$00
         sta pexplodedelay
         sta playerdead
         lda #$80
         sta $07f8
         lda #$0f
         sta $d027
         lda missilecounter
         sta missilepos
         lda missilecounter+1
         sta missilepos+1
         jmp nextlevel
         rts

;last life lost:
;game over

gameover        
         lda #0
         sta $d015
         sta $ed
         ldx #$00
copygotext
         lda gotext,x
         cmp #$20
         beq skipg
         sta gopos,x
         lda #2
         sta gocol,x
skipg    inx
         cpx #gotextend-gotext
         bne copygotext
         
         lda #5
         jsr sfxinit

;check if the player has
;a new hi score then if
;so, make the player 
;score a new hi score

         lda score
         sec 
         lda hiscore+5
         sbc score+5
         lda hiscore+4
         sbc score+4
         lda hiscore+3
         sbc score+3
         lda hiscore+2
         sbc score+2
         lda hiscore+1
         sbc score+1
         lda hiscore
         sbc score
         bpl nohiscore

         ldx #$05
makenewhi
         lda score,x
         sta hiscore,x
         
         sta hiscorepos,x
         dex
         bpl makenewhi
         lda #1
         sta $ed
         
nohiscore        
        lda #0
        sta firebutton
gameoverloop
        lda $dc00 
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton
        bmi gameoverloop
        bvc gameoverloop
        lda $ed
        cmp #1
        beq savehs
exitgo       
         jmp $6000 ;CHANGE TO JUMP TO HI-SCORE CHECKER
savehs  jsr SaveHiScores
        lda #$35
        sta $01
          jmp exitgo

moveplayer 
left     lda #4
         bit $dc00
         bne right
         lda objpos
         sec
         sbc #2
         cmp #$0c
         bcs leftok
         lda #$0c
leftok   sta objpos
right    lda #8
         bit $dc00
         bne fire
         lda objpos
         clc
         adc #2
         cmp #$a2
         bcc rightok
         lda #$a2
rightok  sta objpos
fire     lda $dc00
         lsr
         lsr 
         lsr
         lsr 
         lsr
         bit firebutton
         ror firebutton
         bmi nojoy1
         bvc nojoy1
         lda #0
         sta firebutton
         lda missilecounter
         cmp #$30
         bne missilecountok
         lda missilecounter+1
         cmp #$30
         bne missilecountok 
         lda #$30
         sta missilecounter
         sta missilecounter+1
         lda #7
         jsr sfxinit
         lda #$39
         sta missilecounter
         sta missilecounter+1
         lda #0
         ldx #0
         sta pexplodedelay
         stx pexplodepointer
         lda #1
         sta playerdead

         jmp killplayer 
nojoy1
         jmp nojoy
missilecountok
         
         lda objpos+2
         cmp #$00
         bne nojoy
        ;lda bulletdead
        ;cmp #$01
        ;beq nojoy
         lda objpos
         sta objpos+2
         lda objpos+1
         sta objpos+3
         lda #$01
         jsr sfxinit
         dec missilecounter+1
         lda missilecounter+1
         cmp #$2f
         bne missok 
         lda #$39
         sta missilecounter+1
         dec missilecounter 
         lda missilecounter
         cmp #$2f 
         bne missok
         lda #$30
         sta missilecounter
         sta missilecounter+1
missok   lda missilecounter
         sta missilepos
         lda missilecounter+1
         sta missilepos+1
nojoy    rts

;bullet mover routine

movebullet lda bulletdead
        cmp #$01
        beq explodebullet
        lda bullet
        sta $07f9
        lda #$03
        sta $d028
        lda objpos+3
        sec
        sbc #8
        cmp #$0a
        bcs notout
        lda #$00
        sta objpos+2
notout  sta objpos+3
        rts

explodebullet  
        lda #$07
        sta $d028
        lda explodedelay
        cmp #$01
        beq explodeok
        inc explodedelay
        rts
explodeok lda #$00
        sta explodedelay
        ldx explodepointer
        lda explodeinstr,x
        sta $07f9
        inx
        cpx #8
        beq rescnclrbullet
        inc explodepointer
        rts

rescnclrbullet ldx #$00
        stx objpos+$02
        stx objpos+$03
        stx explodepointer
        lda #$00
        sta bulletdead
        rts

;test and move enemies accordingly

testenemies 
        jsr enemyanim
        jsr movefrominstr
        jsr enemybullet
        rts

;object type and colour

enemyanim ;
frame1  lda saucer1
        sta $07fa
colour1 lda #$0e
        sta $d029
;       rts

enemy2anim ;
frame2  lda saucer2
        sta $07fb
colour2 lda #$0d
        sta $d02a
;       rts

frame3  lda saucer3
        sta $07fc
colour3 lda #$0a
        sta $d02b
;       rts

frame4  lda saucer4
        sta $07fd
colour4 lda #$0c
        sta $d02c
;       rts

frame5  lda saucer1
        sta $07fe
colour5 lda #$04
        sta $d02d
;       rts

        lda bullet2
        sta $07ff
        lda #$0a
        sta $d02e
        rts

;move all enemy objects according to
;the speed table read

movefrominstr ;
        ldx #$00
movloop lda objpos+4,x
        clc
        adc enemy1speed,x
        sta objpos+4,x
        lda objpos+5,x
        clc
        adc enemy1speed+1,x
        sta objpos+5,x
        inx
        inx
        cpx #$0a
        bne movloop

        rts

;kamikaze ... call a loop that
;checks for the player"s 
;horizontal position

testkamikaze ;
          lda playerdead
          cmp #$01
          beq skipkamikaze
          ldx #$00
kamiloop  lda objpos+5,x
          cmp #$00
          bne kcheck
          jmp skipkamikaze2
kcheck    lda objpos+4,x
          cmp collision
          bcc skipkamikaze2
          cmp collision+1
          bcs skipkamikaze2
          jmp kamikazeon
skipkamikaze2 inx
              inx
          cpx #$0a
          bne kamiloop
skipkamikaze rts
kamikazeon inc kamikazetime
           lda kamikazetime
           cmp #$19
           beq chargetoplayer
           rts
chargetoplayer 
           
           ;lda enemy1speed,x
           ;sta enemy1speedbackup,x
           lda #3
           sta enemy1speed+1,x
           lda #$00
           sta enemy1speed,x
           lda #$00
           sta kamikazetime
           lda #9
           jsr sfxinit
           rts

;test kamikaze position - enemies
;should stop after leaving the
;screen ... or offset!

testexit 
          ldx #$00
leaveloop lda objpos+5,x
          cmp #$f8
          bcc inscnclr
         
          lda enemy1speedbackup,x
          sta enemy1speed,x
          lda #$00
          sta objpos+5,x
          sta enemy1speed+1,x
          rts
inscnclr  inx
          inx 
          cpx #$0a
          bne leaveloop
          rts
         
;enemy bullet routine ....

enemybullet ;
        lda objpos+15
        clc
        adc alienbulletspeed
        cmp #$f2
        bcc inscene
        lda #$00
        sta objpos+14
        sta objpos+15
        rts
inscene 
        sta objpos+15
        rts
        
;test enemy firing, by calling a
;simple loop and then check
;which enemy can shoot.

testenemyfire 
        inc enemybulletdelay
        lda enemybulletdelay
        cmp enemybulletdelayamount
        bne notspawnbullet
        lda #$00
        sta enemybulletdelay
        inc enemybullettime
        lda enemybullettime
        cmp enemybulletamount
        bne notspawnbullet
        lda #$00
        sta enemybullettime
        lda bull2rnd
        cmp #$05
        beq rescnclrbullf
        inc bull2rnd
        jsr pickfiring
notspawnbullet rts
rescnclrbullf lda #$00
         sta bull2rnd
pickfiring 
         sta bull2store
         lda bull2store
         cmp #$00
         bne notsau1fire
         jmp sau1fire
notsau1fire
         cmp #$01
         bne notsau2fire
         jmp sau2fire
notsau2fire 
         cmp #$02
         bne notsau3fire
         jmp sau3fire
notsau3fire 
         cmp #$03
         bne notsau4fire
         jmp sau4fire
notsau4fire 
         cmp #$04
         bne notsau5fire
         jmp sau5fire
notsau5fire 
         rts
sau1fire lda objpos+14
         cmp #$00
         bne nos1fire
         lda objpos+5
         cmp #$00
         beq nos1fire
         lda objpos+4
         sta objpos+14
         lda objpos+5
         sta objpos+15
         jmp testbombsfx
nos1fire rts
         
sau2fire lda objpos+14
         cmp #$00
         bne nos2fire
         lda objpos+7
         cmp #$00
         beq nos2fire
         lda objpos+6
         sta objpos+14
         lda objpos+7
         sta objpos+15
         jmp testbombsfx
nos2fire rts
         
sau3fire lda objpos+14
         cmp #$00
         bne nos3fire
         lda objpos+9
         cmp #$00
         beq nos3fire
         lda objpos+8
         sta objpos+14
         lda objpos+9
         sta objpos+15
         jmp testbombsfx
      
nos3fire rts
sau4fire lda objpos+14
         cmp #$00
         bne nos4fire
         lda objpos+11
         cmp #$00
         beq nos4fire
         lda objpos+10
         sta objpos+14
         lda objpos+11
         sta objpos+15
         jmp testbombsfx
nos4fire rts
sau5fire lda objpos+14
          cmp #$00
          bne nos4fire
          lda objpos+13
          cmp #$00
          beq nos5fire
          lda objpos+12
          sta objpos+14
          lda objpos+13
          sta objpos+15
          jmp testbombsfx
nos5fire rts

;saucer bomb sound fx
;this only takes place
;if bullet is in range
;of the game screen
;in order to prevent
;constant firing sfx

testbombsfx
           lda objpos+14
           cmp #bombrangeleft 
           bcc nobombsfx 
           cmp #bombrangeright
           bcs nobombsfx 
           lda objpos+15
           cmp #bombrangetop
           bcc nobombsfx 
           cmp #bombrangebottom
           bcs nobombsfx
           lda #$03
           jsr sfxinit
nobombsfx  rts
      
;collision routine

testcollision 
        lda objpos
        sec
        sbc #$06
        sta collision
        clc
        adc #$0c
        sta collision+1
        lda objpos+1
        sec
        sbc #$0c
        sta collision+2
        clc
        adc #$18
        sta collision+3
        lda objpos+2
        sec
        sbc #$06
        sta collision+4
        clc
        adc #$0c
        sta collision+5
        lda objpos+3
        sec
        sbc #$0c
        sta collision+6
        clc
        adc #$18
        sta collision+7
        jsr bullcoll
        jsr playercoll
        jsr bull2player
        rts

;enemy to bullet collision

bullcoll 
        jsr enemy1tobull
        jsr enemy2tobull
        jsr enemy3tobull
        jsr enemy4tobull
        jsr enemy5tobull
        rts

;enemy 1 to bullet

enemy1tobull 
        lda objpos+4
        cmp collision+4
        bcc nothit1
        cmp collision+5
        bcs nothit1
        lda objpos+5
        cmp collision+6
        bcc nothit1
        cmp collision+7
        bcs nothit1
        jmp killtestenemy1
nothit1 rts

;enemy 2 to bullet

enemy2tobull 
         lda objpos+6
         cmp collision+4
         bcc nothit2
         cmp collision+5
         bcs nothit2
         lda objpos+7
         cmp collision+6
         bcc nothit2
         cmp collision+7
         bcs nothit2
         jmp killtestenemy2
nothit2 rts

;enemy 3 to bullet

enemy3tobull 
         lda objpos+8
         cmp collision+4
         bcc nothit3
         cmp collision+5
         bcs nothit3
         lda objpos+9
         cmp collision+6
         bcc nothit3
         cmp collision+7
         bcs nothit3
         jmp killtestenemy3
nothit3 rts

;enemy 4 to bullet

enemy4tobull 
         lda objpos+10
         cmp collision+4
         bcc nothit4
         cmp collision+5
         bcs nothit4
         lda objpos+11
         cmp collision+6
         bcc nothit4
         cmp collision+7
         bcs nothit4
         jmp killtestenemy4
nothit4 rts

;enemy 5 to bullet

enemy5tobull 
         lda objpos+12
         cmp collision+4
         bcc nothit5
         cmp collision+5
         bcs nothit5
         lda objpos+13
         cmp collision+6
         bcc nothit5
         cmp collision+7
         bcs nothit5
         jmp killtestenemy5
nothit5 rts

;enemy to player collision ...

playercoll 
         ldx #$00
colloop lda objpos+4,x
        cmp collision
        bcc nothit6
        cmp collision+1
        bcs nothit6
        lda objpos+5,x
        cmp collision+2
        bcc nothit6
        cmp collision+3
        bcs nothit6
        jmp shiphit
        rts
nothit6 inx
        inx
        cpx #$0a
        bne colloop
        rts
shiphit lda playerdead
        cmp #$01
        beq ignorekilled
        lda #$01
        sta playerdead
       
        lda #0
        sta objpos+5,x 
        sta enemy1speed+1,x
        lda enemy1speedbackup,x
        sta enemy1speed,x
        
        lda #$04
        jsr sfxinit
       

ignorekilled 
        rts

;enemy bullet to player collision

bull2player 
        lda playerdead
        cmp #$01
        beq nop2
        lda objpos+14
        cmp collision
        bcc nop2
        cmp collision+1
        bcs nop2
        lda objpos+15
        cmp collision+2
        bcc nop2
        cmp collision+3
        bcs nop2
        lda #$00
        lda #$00
        sta objpos+14
        sta pexplodedelay
        lda #$01
        sta playerdead
nop2    rts

;---------------------------------
;killtest enemy objects
;---------------------------------

killtestenemy1 
         lda bulletdead
         cmp #$01
         beq enemy1nodie
         
         lda #$00
         sta objpos+5
         sta enemy1speed+1
         lda enemy1speedbackup
         sta enemy1speed
         jsr initbullexp
         lda #$01
         sta bulletdead

         jsr addscore
         lda frame1+1
         sta scorezone
         jsr addscore
enemy1nodie 
         rts

killtestenemy2 
         lda bulletdead
         cmp #$01
         beq enemy2nodie
         lda objpos+7
         cmp #$00
         beq enemy2nodie
         lda #$00
         sta objpos+7
         sta enemy2speed+1
         lda enemy2speedbackup
         sta enemy2speed
         jsr initbullexp
         lda #$01
         sta bulletdead
         lda frame2+1
         sta scorezone
         jsr addscore
enemy2nodie 
         rts

killtestenemy3 
         lda bulletdead
         cmp #$01
         beq enemy3nodie
         lda objpos+9
         cmp #$00
         beq enemy3nodie
         lda #$00
         sta objpos+9
         sta enemy3speed+1
         lda enemy3speedbackup 
         sta enemy3speed
         jsr initbullexp
         lda #$01
         sta bulletdead
         lda frame3+1
         sta scorezone
         jsr addscore
enemy3nodie rts

killtestenemy4 
         lda bulletdead
         cmp #$01
         beq enemy4nodie
         lda objpos+11
         cmp #$00
         beq enemy4nodie
         lda #0
         sta objpos+11
         sta enemy4speed+1
         lda enemy4speedbackup
         sta enemy4speed
         jsr initbullexp
         lda #$01
         sta bulletdead
         lda frame4+1
         sta scorezone
         jsr addscore
enemy4nodie rts

killtestenemy5 
         lda bulletdead
         cmp #$01
         beq enemy5nodie
         lda objpos+13
         cmp #$00
         beq enemy5nodie
         lda #0
         sta objpos+13
         sta enemy5speed+1
         lda enemy5speedbackup
         sta enemy5speed
         jsr initbullexp
         lda #$01
         sta bulletdead
         lda frame5+1
         sta scorezone
         jsr addscore
enemy5nodie rts
initbullexp
         lda explodeframe
         sta $07f9
         rts
;scoring ... add points

addscore 
          lda scorezone
          cmp #<saucer1
          beq score500
          cmp #<saucer2
          beq score300
          cmp #<saucer3
          beq score200
          cmp #<saucer4
          beq score100
          rts

score500 jsr scorecalc
         jsr scorecalc
score300 jsr scorecalc
score200 jsr scorecalc
score100 jsr scorecalc
         dec shotcount
         lda shotcount
         cmp #0
         beq levelcomplete
         rts

;destroy all of the enemies on screen
;then display the level complete !text

levelcomplete
         lda #0
         sta explodedelay
         ldx #0
         stx explodepointer
         ldx #$00
copyexpframe
         lda explodeframe,x
         sta $07f9,x
         inx
         cpx #7
         bne copyexpframe
         lda #6
         jsr sfxinit
         
lcloop
         lda #$00
         sta rt
         cmp rt
         beq *-3
         jsr expand
         jsr destroyall
             
         jmp lcloop

;destroy all of the enemies on screen 
;by forcing an explosion on all visible
;sprites

destroyall      
        lda explodedelay
        cmp #$02
        beq dolcexplosion
        inc explodedelay
        rts
dolcexplosion
        lda #0
        sta explodedelay
        ldx explodepointer
        lda explodeframe,x
        sta $07f9
        sta $07fa
        sta $07fb
        sta $07fc
        sta $07fd
        sta $07fe
        sta $07ff
        lda #$07
        sta $d028
        sta $d029
        sta $d02a
        sta $d02b
        sta $d02c
        sta $d02d
        sta $d02e
        inx
        cpx #8
        beq lcexplodeend
        inc explodepointer
        rts

;award ammo bonus to score points
        
lcexplodeend
      
        lda #0
        sta $d015
        sta ammobonustime 
         ldx #0
zeroplace        
        lda $d001,x
        sta objpos+1,x
        inx
        inx
        cpx #$10
        bne zeroplace
        

countdownloop
        lda #0
        sta rt 
        cmp rt
        beq *-3
        jsr dobonus
        jmp countdownloop

dobonus
         lda ammobonustime
         cmp #4
         beq takeammoandgivepoints
         inc ammobonustime
         rts
takeammoandgivepoints
         lda #0
         sta ammobonustime
         jsr score500
         dec missilecounter+1
         lda missilecounter+1
         cmp #$2f
         bne bonusmcountok
         lda #$39
         sta missilecounter+1
         dec missilecounter
         lda missilecounter
         cmp #$2f
         beq stopbonus
bonusmcountok
         lda missilecounter+1
         sta missilepos+1
         lda missilecounter 
         sta missilepos
         lda #8
         jsr sfxinit
         rts
stopbonus 
         lda #$30
         sta missilecounter 
         sta missilecounter+1
         sta missilepos 
         sta missilepos+1

        ldx #$00
copylctext
        lda lctext,x
        cmp #$20
        beq skiplc
        sta lcpos,x
        lda #5
        sta lccol,x
skiplc  inx
        cpx #lctextend-lctext 
        bne copylctext
        lda #3
        jsr sfxinit
        lda #0
        sta firebutton
waitnext      
        lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton
        bmi waitnext
        bvc waitnext
        lda #0
        sta firebutton
        inc levelcounter
        inc levelpointer
        lda levelcounter
        cmp #9
        beq resetlevelcounter
        jmp nextlevel
resetlevelcounter
        lda #1
        sta levelcounter
        jmp nextlevel


scorecalc inc score+4
          ldx #$04
loopscore lda score,x
          cmp #$3a
          bne scoreok
          lda #$30
          sta score,x
          inc score-1,x
scoreok   dex
          bne loopscore
          lda #2
          jsr sfxinit
          ldx #$05
masterpanel
          lda score,x
          sta scorepos,x
          dex
          bpl masterpanel
          rts
          
;bullet death routine ...

          ldx #$00
          stx explodepointer
          stx explodedelay
          rts
          
;randomizer routine

randomizer ldx randpointer
           lda levelspeedinstr,x
           sta levelspeedstore
           lda colinstr,x
           sta colstore
           lda randyinstr,x
           sta newyposstore
           inx
           cpx #42
           beq rescnclrrp
           inc randpointer
           jsr checkenemypos
           rts

rescnclrrp    ldx #$00
            stx randpointer
checkenemypos inc saucerpudefpointer
            lda saucerpudefpointer
            cmp saucerpudefmax
            bne saucerpudefok
            lda #$00
            sta saucerpudefpointer
saucerpudefok ldx saucerpudefpointer
            lda saucerpudeflo,x
           sta saucerlostore
           lda saucerpudefhi,x
           sta saucerhistore
           jsr readposenemy1
           jsr readposenemy2
           jsr readposenemy3
           jsr readposenemy4
           jsr readposenemy5
           rts

;check if the enemy has left the screen

readposenemy1 
           lda objpos+4
            cmp #offsetposition
            bne inscnclr1
           
            jmp storenextenemy1
waitnext1   ;Force wait until poissible position is met
            jmp randomizer

inscnclr1     rts

;store the next enemy, but prevent 
;sprite overlapping outside the 
;game screen.

storenextenemy1 lda colstore
            sta colour1+1
           lda saucerlostore
            sta frame1+1
            lda saucerhistore
            sta frame1+2
             lda #$00
            sta enemy1speed+1
            lda levelspeedstore
            sta enemy1speed
            sta enemy1speedbackup
            
            lda newyposstore
         
            sta objpos+5
            rts
selectnewypos 
            rts
            
readposenemy2 
            lda objpos+6
            cmp #offsetposition
            bne inscnclr2
          
            
            jmp storenextenemy2
waitnext2   
            
inscnclr2     rts
storenextenemy2 lda colstore
            sta colour2+1
            lda saucerlostore
            sta frame2+1
            lda saucerhistore
            sta frame2+2
            lda #$00
            sta enemy2speed+1
           
            lda levelspeedstore
            sta enemy2speed
            sta enemy2speedbackup
            lda newyposstore
            
            sta objpos+7
           
p2d         rts
            
overlap2    sec
            sbc #$10
            sta objpos+6
            rts
;
readposenemy3 
            lda objpos+8
            cmp #offsetposition
            bne inscnclr3
           
          
            
            jmp storenextenemy3
waitnext3   
inscnclr3   rts
storenextenemy3 lda colstore
            sta colour3+1
            lda saucerlostore
            sta frame3+1
            lda saucerhistore
            sta frame3+2
            lda #$00
            sta enemy3speed+1
           
            lda levelspeedstore
            sta enemy3speed
            sta enemy3speedbackup
            lda newyposstore
            sta objpos+9
           
            rts

readposenemy4 
            lda objpos+10
            cmp #offsetposition
            bne inscnclr4
           
            
          
            jmp storenextenemy4
waitnext4     
          
inscnclr4     rts

storenextenemy4 
            lda colstore
            sta colour4+1
            lda saucerlostore
            sta frame4+1
            lda saucerhistore
            sta frame4+2
            lda #$00
            sta enemy4speed+1
            
            lda levelspeedstore
            sta enemy4speed
            sta enemy4speedbackup
            lda newyposstore
            
            sta objpos+11
          
            rts
   
readposenemy5 
            lda objpos+12
            cmp #offsetposition
            bne inscnclr5
           
         ; jmp storenextenemy5
            lda colstore
            sta colour5+1
            lda saucerlostore
            sta frame5+1
            lda saucerhistore
            sta frame5+2
            lda #$00
            sta enemy5speed+1
            
            
            lda levelspeedstore
            sta enemy5speed
            sta enemy5speedbackup
            lda newyposstore
            sta objpos+13
            
waitnext5    
inscnclr5     rts

;game loop routines

routines    jsr expand
            jsr animspr
            jsr playercontrol
           jsr movebullet
          jsr testenemies
          jsr testenemyfire
          jsr testcollision
          jsr testkamikaze
          jsr testexit
          jsr randomizer
          rts

;game pointers

;
rt       !byte 0,0 ;raster timer

;player amount of lives
lives !byte 3
;sprite animation routine counters
animdelay !byte 0
animpointer !byte 0
;sprite frames set by default 
;(at start of a new game)
player !byte $80
bullet !byte $81
explosion !byte $85
saucer1 !byte $89
saucer2 !byte $8d
saucer3 !byte $91
saucer4 !byte $95
bullet2 !byte $95
;bullet random selector
bull2rnd !byte 0
;bullet to saucer selected
bull2store !byte 0
;bullet dead (to activate exploding bullet)
bulletdead !byte 0
;speed table for each flying saucer 
shotintensity !byte 0
;bullet fire enabled (if counter is set)
enemybulletallowed !byte 0

;bullet is an exception
enemy1speed !byte $01,$00
enemy2speed !byte $fe,$00
enemy3speed !byte $02,$00
enemy4speed !byte $ff,$00
enemy5speed !byte $03,$00
;backup for each enemy, in order to
;avoid a pretty difficult kamikaze 
;situation
enemy1speedbackup !byte 0,0
enemy2speedbackup !byte 0,0
enemy3speedbackup !byte 0,0
enemy4speedbackup !byte 0,0
enemy5speedbackup !byte 0,0
;sprite explosion delay and animation control
explodedelay !byte 0
explodepointer !byte 0
pexplodedelay !byte 0
pexplodepointer !byte 0
;player death counter
playerdead !byte 0
;time before select kamikaze wave
kamikazetime !byte 0
;time before launching next bullet
enemybullettime !byte 0
enemybulletamount !byte $07
enemybulletdelay !byte 0
enemybulletdelayamount !byte $32
;saucer defintion values - according to 
;level. this will be based on points
;scored per shot/
saucerpudef !byte 3
saucerpudefmax !byte 3
;random saucer anim type selection 
saucerlostore !byte <saucer1
saucerhistore !byte >saucer1
;new vertical start position for each saucer 
newyposstore !byte 0
levelspeedstore !byte 0
;random pointer
randpointer !byte 0
;saucer colour selected from table
colstore !byte 0
saucerpudefpointer !byte 0
;saucertypemax !byte 3
scorezone !byte 0
;number of saucers to shoot
shotcount !byte 0
;the level counter 
levelcounter !byte 0
levelpointer !byte 0
;the amount of missiles the player has at its
;disposal
missilecounter !byte 0,0
;a timer delay for awarding bonus ammo to the player
ammobonustime !byte 0
;fire button check (less sensitivity)
firebutton !byte 0
;fire bullet speed
alienbulletspeed !byte 4

;sprite position tables
objpos  !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

;sprite start position table
startpos !byte $58,$d0
         !byte $00,$00
         !byte $b0,$00
         !byte $60,$00
         !byte $70,$00
         !byte $80,$00
         !byte $90,$00
         !byte $00,$00

;sprite start speed table
startspeed
         !byte $01,$00
         !byte $ff,$00
         !byte $01,$00
         !byte $ff,$00
         !byte $01,$00
         
;collision table
collision !byte 0,0,0,0,0,0,0,0,0

;sprite animation tables
bulletframe1 !byte $81,$82,$83,$84
pexplodeinstr !byte $85,$86,$87,$88,$87,$86,$85,$85
explodeinstr !byte $85,$86,$87,$88,$87,$86,$85,$85
saucer1frame !byte $89,$8a,$8b,$8c
saucer2frame !byte $8d,$8e,$8f,$90
saucer3frame !byte $91,$92,$93,$94
saucer4frame !byte $95,$96,$97,$96
bullet2frame !byte $98,$99,$9a,$9b
explodeframe !byte $85,$86,$87,$88,$88,$88,$87,$86

;lo+hi !byte small table for saucer type selection
saucerpudeflo !byte <saucer1,<saucer2,<saucer3,<saucer4
saucerpudefhi !byte >saucer1,>saucer2,>saucer3,>saucer4

;colour table for selecting the colour of the saucers
colinstr ;
        !byte $0e,$0a,$03,$0d,$05,$0c,$0f
        !byte $0a,$0e,$0f,$03,$0c,$0a,$0e
        !byte $0c,$0a,$0e,$03,$0d,$0f,$0c
        !byte $0e,$0a,$0f,$0d,$03,$0c,$0a
        !byte $0d,$0e,$0f,$03,$0a,$0c,$0d
        !byte $0a,$03,$0d,$0e,$0c,$0f,$0e
        !byte $03,$0e,$0d,$0f,$0c,$0a,$0e
colinstrend !byte 0

;self-mod level speed table
levelspeedinstr ;
        !byte $01,$ff,$01,$01,$ff,$ff,$01
        !byte $ff,$01,$ff,$01,$01,$ff,$01
        !byte $01,$ff,$01,$01,$ff,$01,$ff
        !byte $ff,$01,$ff,$01,$ff,$01,$ff
        !byte $01,$ff,$ff,$01,$01,$ff,$01
        !byte $ff,$01,$ff,$01,$ff,$ff,$01
        !byte $ff,$01,$ff,$ff,$01,$01,$ff
levelspeedinstrend  !byte 0

;random start y-position table for the
;killer saucers
randyinstr ;
        !byte $40,$b0,$80,$40,$50,$70,$90
        !byte $a0,$80,$60,$b0,$b0,$70,$40
        !byte $50,$70,$40,$80,$60,$a0,$50
        !byte $40,$70,$60,$50,$90,$b0,$60
        !byte $a0,$80,$70,$60,$50,$b0,$40
        !byte $40,$90,$60,$50,$80,$50,$40
        !byte $40,$70,$70,$50,$90,$b0,$60
randyinstrend  !byte $40

;score table
scoreinstr !byte 0,1,2,3
scoreinstrend ;
;score !bytes + hi score
score  !byte $30,$30,$30,$30,$30,$30
HiScoreStart
hiscore !byte $30,$30,$30,$30,$30,$30
HiScoreEnd
;game over !text
!ct scr
gotext
        !text "game over"
gotextend
;level complete !text
lctext  !text "level complete"
lctextend

;Level parameter tables  - Enemy speed

level1speedtable
        !byte $01,$ff,$01,$01,$ff,$ff,$01
        !byte $ff,$01,$ff,$01,$01,$ff,$01
        !byte $01,$ff,$01,$01,$ff,$01,$ff
        !byte $ff,$01,$ff,$01,$ff,$01,$ff
        !byte $01,$ff,$ff,$01,$01,$ff,$01
        !byte $ff,$01,$ff,$01,$ff,$ff,$01
        !byte $ff,$01,$ff,$ff,$01,$01,$ff
level1speedtableend

level2speedtable
        !byte $01,$ff,$01,$01,$ff,$01,$ff
        !byte $ff,$01,$ff,$01,$ff,$ff,$01
        !byte $ff,$ff,$ff,$01,$01,$01,$ff
        !byte $01,$ff,$01,$ff,$ff,$01,$ff
        !byte $ff,$01,$ff,$01,$01,$ff,$ff
        !byte $01,$ff,$01,$ff,$01,$ff,$01
        !byte $01,$ff,$01,$ff,$01,$ff,$ff
level2speedtableend

level3speedtable
        !byte $01,$01,$ff,$ff,$02,$01,$ff
        !byte $01,$01,$fe,$01,$ff,$01,$ff
        !byte $01,$02,$ff,$fe,$01,$02,$01
        !byte $01,$01,$fe,$01,$fe,$ff,$01
        !byte $01,$01,$ff,$01,$ff,$01,$fe
        !byte $01,$01,$fe,$01,$ff,$01,$fe
        !byte $ff,$01,$ff,$02,$ff,$01,$fe
level3speedtableend

level4speedtable
        !byte $01,$02,$fe,$01,$01,$ff,$01
        !byte $01,$fe,$ff,$ff,$01,$01,$ff
        !byte $fe,$02,$01,$01,$ff,$ff,$01
        !byte $01,$fe,$ff,$ff,$02,$fe,$02
        !byte $01,$ff,$01,$fe,$01,$01,$ff
        !byte $01,$ff,$02,$fe,$01,$ff,$01
        !byte $01,$ff,$01,$ff,$01,$ff,$01
level4speedtableend

level5speedtable
        !byte $01,$fe,$01,$02,$fe,$ff,$01
        !byte $fe,$01,$01,$ff,$02,$01,$ff
        !byte $02,$ff,$fe,$02,$01,$fe,$01
        !byte $ff,$fe,$fe,$02,$02,$ff,$01
        !byte $ff,$fe,$02,$ff,$02,$ff,$01
        !byte $ff,$02,$fe,$01,$ff,$01,$fe
        !byte $ff,$01,$fe,$fe,$02,$02,$02
level5speedtableend

level6speedtable
        !byte $02,$fe,$fe,$02,$01,$ff,$02
        !byte $fe,$02,$02,$fe,$01,$ff,$02
        !byte $fe,$fe,$02,$01,$ff,$01,$ff
        !byte $fe,$02,$fe,$01,$ff,$01,$fe
        !byte $fe,$02,$01,$fe,$ff,$fe,$fe
        !byte $02,$fe,$01,$fe,$ff,$02,$01
        !byte $02,$02,$fe,$01,$ff,$02,$fe
level6speedtableend

level7speedtable
        !byte $02,$fe,$02,$02,$fe,$fe,$02
        !byte $02,$fe,$02,$fe,$fe,$02,$02
        !byte $02,$02,$fe,$02,$02,$fe,$fe
        !byte $fe,$02,$fe,$fe,$02,$02,$fe
        !byte $02,$02,$fe,$02,$fe,$fe,$02
        !byte $02,$fe,$02,$fe,$02,$02,$fe
        !byte $fe,$02,$02,$fe,$02,$fe,$02
level7speedtableend

level8speedtable
        !byte $02,$fe,$02,$02,$fe,$02,$fd
        !byte $03,$fd,$02,$03,$02,$02,$03
        !byte $02,$fd,$03,$02,$fe,$02,$fe
        !byte $fd,$03,$fd,$03,$02,$fe,$03
        !byte $fd,$03,$fd,$02,$fe,$03,$fd
        !byte $03,$02,$fe,$03,$02,$03,$fe
        !byte $fe,$03,$03,$fd,$fd,$03,$fd
level8speedtableend

;Level tables for level speed (low/hi !byte pointers)

levelspeedtablelow      !byte <level1speedtable
                        !byte <level2speedtable
                        !byte <level3speedtable
                        !byte <level4speedtable
                        !byte <level5speedtable
                        !byte <level6speedtable
                        !byte <level7speedtable
                        !byte <level8speedtable
levelspeedlowtableend

levelspeedtablehi       !byte >level1speedtable
                        !byte >level2speedtable
                        !byte >level3speedtable
                        !byte >level4speedtable
                        !byte >level5speedtable
                        !byte >level6speedtable
                        !byte >level7speedtable
                        !byte >level8speedtable
levelspeedtablehiend

;Level enemy firing intensity (Should increase every
;level.

fireintensity                   
                        !byte $08,$07,$06,$05,$04,$03,$02,$01
fireintensityend

firespeedtable
                        !byte $04,$04,$04,$04,$05,$05,$06,$06
firespeedtableend


        !byte 0
!ct scr
