; pripraveno pro TASM 
; pro kompilaci pres SjASMPlus nutno zakomentovat vsechna nasledujici #define 
; a nahradit vsechna "#include" za " include" (mezera misto # na zacatku!)

#define 	EQU 	.equ
#define 	END 	.end
#define 	DB   	.DB
#define 	DW   	.DW
#define 	DM	.TEXT
#define 	ORG	.org

; --------------------------------------------
; pstart urcuje zaciatok programu
;
;pstart  EQU 0CFA0h		; tape buffer
pstart  EQU 9000h
; --------------------------------------------
;
;
; --------------------------------------------
; zahlavie prveho bloku dat
; --------------------------------------------
;
 		ORG 	fstart
		DB	01h
		DW	pstart
		DW	length
; --------------------------------------------
; tu zacina program
; --------------------------------------------
                ORG pstart
; --------------------------------------------
; includes
#include "main.asm"
#include "keyboard.asm"
#include "mainprn.asm"
#include "hexaprn.asm"
#include "font6x8f.asm"
;#include "easter.asm"
#include "loader.asm"
#include "txd.asm"
#include "beep.asm"
#include "memtest.asm"
#include "sort.asm"
;
; --------------------------------------------
; hlavicka s adresou sputenia kodu
; --------------------------------------------
lnchr:		DB	02h
		DW	pstart
; --------------------------------------------
; vypocet adries
;
fstart  	EQU 	pstart - 5
length  	EQU 	lnchr - pstart
;
; --------------------------------------------
; koniec programu
; --------------------------------------------
;
		END
; --------------------------------------------
;