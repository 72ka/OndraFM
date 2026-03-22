; --------------------------------------------
; rutina pre vykreslenie jedneho znaku
; --------------------------------------------
; vypocet pozicie matrice pre dany znak
ONECHAR:	SUB	20h		; az od medzery
		LD	H, 00h
		RL	A		; ascii znaku vynasob 8
		RL	H		; pretecie do H
		RL	A
		RL	H
		RL	A
		RL	H
		LD	L, A
		LD	DE, CHRGEN	; zaciatok tabulky
		ADD	HL, DE		; pripocitaj 8*ascii kod
		EX	DE, HL		; adresa zaciatku znaku je v DE
; --------------------------------------------
; vypocet pozicie vo video RAM	H - stlpec, L - riadok
		LD	A, (POSX)
		RRC	A		; delit styrmi
		RRC	A
		AND	00111111b
		LD	H, A		; uschovaj
		RLC	A
		ADD	A, H		; vynasob tromi
		CPL			; negovat
		LD	H, A
		LD	A, (POSY)
		RLCA	; vynasob 8 (8 liniek na znak)
		RLCA	; ale kvoli posunu bitov staci nasobit 4
		DEC A	; o 2 linky nahoru
		CPL
		LD	L, A
; --------------------------------------------
		LD	IX, INVER	; ukazatel na flag
		LD	B, 8		; 8 liniek
		LD	A, (POSX)
		AND	11b
		JR	Z, SZERO	; stlpec 0
		DEC	A
		JR	Z, SONE 	; stlpec 1
		DEC	H
		DEC	A
		JR	Z, STWO 	; stlpec 2
		DEC	H		; a zostal posledny
; --------------------------------------------
; stvrty
SLAST:		LD	A, (DE)		; nacitaj z matrice
		XOR	(IX+0)
		RRC	A
		RRC	A
		AND	00111111b
		LD	C, A
		LD	A, (HL)
		AND	11000000b
		OR	C		; pridaj druhu polovicu
		LD	(HL), A		; a uloz do video RAM
		RLC	L		; dalsia linka
		DEC	L
		RRC	L
		INC	DE
		DJNZ	SLAST
		RET
; --------------------------------------------
; prvy
SZERO:		LD	A, (DE)		; nacitaj z matrice
		XOR	(IX+0)
		AND	11111100b
		LD	C, A
		LD	A, (HL)
		AND	00000011b
		OR	C
		LD	(HL), A		; a uloz do video RAM
		RLC	L		; dlasia linka
		DEC	L
		RRC	L
		INC	DE
		DJNZ	SZERO
		RET
; --------------------------------------------
; druhy
SONE:		LD	A, (DE)		; nacitaj z matrice
		XOR	(IX+0)
		RLC	A		; dva bity do laveho bajtu
		RLC	A
		AND	00000011b
		LD	C, A
		LD	A, (HL)
		AND	11111100b
		OR	C
		LD	(HL), A		; a uloz do video RAM
		DEC	H		; zvysok zasahuje do bajtu vpravo
		LD	A, (DE)		; nacitaj z matrice
		XOR	(IX+0)
		RLC	A		; styri bity do praveho bajtu
		RLC	A
		AND	11110000b
		LD	C, A
		LD	A, (HL)
		AND	00001111b
		OR	C
		LD	(HL), A		; a uloz do video RAM
		INC	H		; spat na lavy bajt
		RLC	L		; dalsia linka
		DEC	L
		RRC	L
		INC	DE
		DJNZ	SONE
		RET
; --------------------------------------------
; treti
STWO:		LD	A, (DE)		; nacitaj z matrice
		XOR	(IX+0)
		RRC	A		; styri bity do laveho bajtu
		RRC	A
		RRC	A
		RRC	A
		AND	00001111b
		LD	C, A
		LD	A, (HL)
		AND	11110000b
		OR	C
		LD	(HL), A		; a uloz do video RAM
		DEC	H		; zvysok zasahuje do bajtu vpravo
		LD	A, (DE)		; nacitaj z matrice
		XOR	(IX+0)
		RLC	A		; dva bity do praveho bajtu
		RLC	A
		RLC	A
		RLC	A
		AND	11000000b
		LD	C, A
		LD	A, (HL)
		AND	00111111b
		OR	C
		LD	(HL), A		; a uloz do video RAM
		INC	H		; spat na lavy bajt
		RLC	L		; dalsia linka
		DEC	L
		RRC	L
		INC	DE
		DJNZ	STWO
		RET
; --------------------------------------------
