;**********************************
;*                                *
;*         killer saucers         *
;*                                *
;* by richard bayliss (c)2020 tnd *
;*                                *
;**********************************
;
;note: title screen as separate code

;---- variables ---

scn = $0400 ;hw screen ram
col = $d800 ;hw colour ram
dat = $3000 ;screen data
dat2 = $3400 ;colour data
sfxinit = $1000 ;init sfx
sfxplay = $1003 ;play sfx
scorepos = $0407 ;hw screen pos for score
hiscorepos = $0422
gopos = $04d7 ;game over text screen 
gocol = $d8d7 ;game over text colour 
lcpos = $04d5
lccol = $d8d5
missilepos = $07d4
livespos = $0415 ;lives position text 
levpos = $041c
bombrangeleft = $0c
bombrangeright = $a4
bombrangetop = $36
bombrangebottom = $fa
maxshots = 50
starchar = $3fe0
lazerleft = $3b60
lazerright = $3b68
musicinit = $9000
musicplay = $9003

            !TO "KILLERSAUCERS.PRG",CBM
;BASIC SYS: 2061
; 10 SYS2061

*=$0801

        !byte    $0B, $08, $0A, $00, $9E, $32, $30, $36, $31, $00, $00, $00

        * = $080d
       
        lda $02a6
        sta system
        
        sei
        lda #$36
        sta $01

        cli
        jsr LoadHiScores
        lda #$35
        sta $01
        cli
        jmp $6000
        
        *=$0900         
        !src "diskaccess.asm"

;Import sound effects 
        * = $1000
        !bin "bin\gamesfx.prg",,2

;Import game sprites
        * = $2000
        !bin "bin\gamesprites.bin"
;Import game screen 
        * = $3000
        !bin "bin\gamescreen.bin"
;Import game colour attributes 
        * = $3400
       !bin "bin\gamecolours.bin"
;Import charset data
        * = $3800
        !bin "bin\gamechars.bin"
;Game code
        * = $4000
        !src "gamecode.asm"

;Title screen code
        * = $6000
        !src "titlescreen.asm"
       ;' * = $7000
        !src "endscreen.asm"

          

            *=$9000
           !bin "bin\music.prg",,2