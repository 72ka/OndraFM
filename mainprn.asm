; +------------------+--------------------------
; ! The Control Word !
; +------------------+
;
;               +---+---+---+---+---+---+---+---+
;               ! 7 ! 6 ! 5 ! 4 ! 3 ! 2 ! 1 ! 0 !
;               +---+---+---+---+---+---+---+---+
;                 +-+-+   +-+-+   +---+---+   +-- BCD 0 - Binary 16 bit
;                   !       !         !               1 - BCD 4 decades
; +-----------------+----+  !         !
; ! Select Counter       !  !         +---------- Mode Number 0 - 5
; ! 0 - Select Counter 0 !  !
; ! 1 - Select Counter 1 !  !         +----------------------------+
; ! 2 - Select Counter 2 !  !         ! Read/Load                  !
; +----------------------+  !         ! 0 - Counter Latching       !
;                           +---------+ 1 - Read/Load LSB only     !
;                                     ! 2 - Read/Load MSB only     !
;                                     ! 3 - Read/Load LSB then MSB !
;                                     +----------------------------+
; --------------------------------------------
; nastavenie citacov pre 40 znakov na riadok a 255 mikroriadkov
GRINIT:		LD 	A, 32h		; najskor control word
	        OUT	(LS174),A
		LD	B, 14h
		LD	C, 12h
		RRC	C
		IN	A, (C)
		LD	B, 7Ah
		LD	C, 7Ah
		RRC	C
		IN	A, (C)
		LD	BC, 0B2B4h
		RRC	C
		IN	A, (C)
		LD	A, 2h		; citac 0
		OUT	(LS174), A
		LD	BC, 40FFh       ; 64us, 255 liniek (32 znakov na vysku)
		RRC	C
		IN	A, (C)
		LD	A, 12h		; citac 1
		OUT	(LS174),A
		LD	BC, 2F10h
		RRC	C
		IN	A, (C)
		LD	BC, 0001h
		RRC	C
		IN	A, (C)
		LD	A, 22h		; citac 2
		OUT	(LS174), A
		LD	BC, 2938h
		RRC	C
		IN	A, (C)
		LD	BC, 0001h
		RRC	C
		IN	A, (C)
		RET
; --------------------------------------------
; vymazanie obrazovky
CLS:    	LD	HL, 0D800h	; zaciatok VideoRAM
		LD	DE, 0D801h	; posledny stlpec
		LD	BC, 2800h       ; velkost VideoRAM
		DEC     H               ; jeden stlpec navyse
		DEC     D
		INC     B
		XOR     A
		LD	(HL), A
		LDIR
        	RET
; --------------------------------------------
; vymazanie riadku (podla aktualnej pozicie)
CLINE:  	LD      A, 0
	        LD      (POSX), A       ; na zaciatok riadku
        	LD	A, (POSY)
        	RLCA	;		SLA	A		  ; vynasob 8 (8 liniek na znak)
        	RLCA	;		SLA	A     ; ale kvoli posunu bitov staci nasobit 4
        	DEC A	; o 2 linky nahoru
		CPL
		LD	L, A
	        LD      B, 8            ; 8 liniek
        	LD      A, 0            ; bude sa vyplnat 0
CLINE0: 	LD      H, 0FFh         ; stlpec 0
        	LD      C, 40           ; 40 stlpcov
CLINE1: 	LD      (HL), A
	        DEC     H               ; posun na dalsi stlpec
        	DEC     C               ; zniz pocitadlo
	        JR      NZ, CLINE1      ; opakuj na celu linku
		RLC	L
	        DEC     L               ; presun na dalsiu linku
		RRC	L
	        DJNZ    CLINE0          ; opakuj pre vsetky linky
        	RET
; --------------------------------------------
; nastavenie pozicie nasledujuceho znaku
SETPOS:		LD	A, H
		LD	(POSX), A
		LD	A, L
		LD	(POSY), A
		RET
; --------------------------------------------
NORMAL: 	XOR     A
        	LD      (INVER), A
        	RET
INVERSE:	LD      A, 0FFh
        	LD      (INVER), A
        	RET
; --------------------------------------------
; rutina na zobrazenie znaku z reg. A
SHCHAR:		CP	20h		; su to znaky pod medzerou (20h)?
		JP	C, SPCHAR
		JP      ONECHAR
; --------------------------------------------
; zobrazenie znaku a posun pozicie
SHMCHAR:	CP	20h		; su to znaky pod medzerou (20h)?
		JP	C, SPCHAR
		CALL      ONECHAR
		JR        MOVEPOS
; --------------------------------------------
; vypis null-terminated string
SHTEXT: 	LD      A, (HL)
        	OR      A
        	RET     Z               ; skonci, ak je 0
        	INC     HL
        	PUSH    HL
        	CALL    SHMCHAR         ; zobraz znak
        	POP     HL
        	JR      SHTEXT
; --------------------------------------------
; horizontalne vyplnenie znakom
SHHORZ: 	LD      C, A            ; uschovaj znak do C
SHHOR0: 	PUSH    HL
        	PUSH    BC
        	LD      A, C            ; vrat znak
        	CALL    ONECHAR         ; zobraz znak
        	CALL    MOVEPOS         ; posun poziciu vpravo
        	POP     BC
        	POP     HL
        	LD      A, (POSX)       ; posun poziciu nadol
        	OR      A
        	RET     Z               ; posledny stlpec? skonci
        	LD	(POSX), A
        	DJNZ    SHHOR0          ; opakuj B-krat
        	RET
; --------------------------------------------
; vertikalne vyplnenie znakom
SHVERT: 	LD      C, A            ; uschovaj znak do C
SHVER0: 	PUSH    HL
        	PUSH    BC
        	LD      A, C            ; vrat znak
        	CALL    ONECHAR         ; zobraz znak
        	POP     BC
        	POP     HL
        	LD      A, (POSY)       ; posun poziciu nadol
        	INC     A
        	RET     Z               ; posledny riadok? skonci
       		LD	(POSY), A
        	DJNZ    SHVER0          ; opakuj B-krat
        	RET
; --------------------------------------------
MOVEPOS:	LD	A, (POSX)
        	INC	A
		CP	53
		JR	NC, NEWLINE
		LD	(POSX), A
SPCHAR:		RET			; specialne ascii znaky
; --------------------------------------------
NEWLINE:	XOR	A		; vynuluj X
		LD	(POSX), A
		LD	A, (POSY)	; zvys Y
		INC	A
		JR      Z, SCROLL       ; posledny riadok?
		LD	(POSY), A
		RET
; --------------------------------------------
SCROLL:		LD	A, 0
        	LD	(POSY), A
        	RET			; zatial
; --------------------------------------------
LINES252: ; standard ve ViLi ROM, nektere programy (Karel) s tim pocitaji
		LD	A, 2h		; citac 0
		OUT	(LS174), A
		LD	BC, 40F9h       ; 64us, 252 (0xFC) liniek (32 znakov na vysku) FC=>F9
		RRC	C
		IN	A, (C)
		RET
; --------------------------------------------
