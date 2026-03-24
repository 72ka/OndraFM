; pripraveno pro TASM i SJASMPlus

; detekce SjASMPlus
	IFDEF __SJASMPLUS__
	OUTPUT "__ondrafm.bin"
	ELSE
#define 	EQU 	.equ
#define 	END 	.end
#define 	DB   	.DB
#define 	DW   	.DW
#define 	DM	.TEXT
#define 	ORG	.org
	ENDIF

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

	IFDEF __SJASMPLUS__
	include "main.asm"
	include "keyboard.asm"
	include "mainprn.asm"
	include "hexaprn.asm"
	include "font6x8f.asm"
	include "loader.asm"
	include "txd.asm"
	include "beep.asm"
	include "memtest.asm"
	include "sort.asm"
	ELSE
#include "main.asm"
#include "keyboard.asm"
#include "mainprn.asm"
#include "hexaprn.asm"
#include "font6x8f.asm"
#include "loader.asm"
#include "txd.asm"
#include "beep.asm"
#include "memtest.asm"
#include "sort.asm"
	ENDIF
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
