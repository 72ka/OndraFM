; --------------------------------------------
; test klavesnice, vyuziva A, HL, DE, BC
; --------------------------------------------
; zisti, ci je stlacena jedna alebo dve klavesy, ich kod vrati v DE
;
KEYSCAN:	LD	A, 111b
		OUT	(LS174)	, A 	; mapuj port
		LD	H, LS373/256	; port
		LD      DE, 0FFFFh      ; pociatocna hodnota (do DE sa budu ukladat kody dvoch klaves)
		LD	B, 10		; bude 10 riadkov (vratane joy)
KEYSC0: 	LD	L, B
		DEC	L
		LD	A, (HL)		; nacitaj port
		CPL			; aktivny riadok je 1
		AND	11111b		; zvysok zrus
		JR	NZ, KEYFIND	; bolo nieco stlacene? zisti co
KEYSC1:		DJNZ	KEYSC0		; skus iny riadok
		RET                     ; otestovane vsetky klavesy, koniec
KEYFIND:	LD      C, 05h          ; pociatocna hodnota
KEYCOL: 	RRC     A               ; rotuj do carry
	        JR      NC, KEYNEXT
KEYDOWN:	LD	I, A		; uschovaj stav
		LD      A, L            ; riadok (0-9) sa vynasobi piatimi a pripocita sa stlpec
        	ADD     A, A            ; *2
	        ADD     A, A            ; *4
        	ADD     A, L            ; *5
	        ADD     A, C            ; pripocitaj stlpec,
        	DEC     A               ; teraz je v A kod klavesy 0-49
	        INC     E               ; zvys E, ak tam nic nie je, bude 0
        	JR      NZ, KEYSEC      ; najdena druha klavesa
	        LD      E, A            ; uloz klaves do E
		LD	A, I		; obnov stav
KEYNEXT:	DEC     C               ; skus dalsi stlpec
	        JR      NZ, KEYCOL      ; alebo skonci
       		JR	KEYSC1		; skenuj dalsie riadky
KEYSEC: 	DEC     E               ; vrat naspat
	        LD      D, A            ; druhu klavesu daj do D
        	RET                     ; a tym skonci, mozu byt len dve klavesy naraz
; --------------------------------------------
