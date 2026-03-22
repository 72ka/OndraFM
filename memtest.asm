; say Hello
MEMTEST:	CALL	CLS
		LD	HL, 256*15+TOPLINE
		CALL	SETPOS
		CALL	INVERSE
		LD	HL, MEMTEXT
		CALL	SHTEXT
		LD	C, 128		; zapipaj a zhasni LED
		LD	B, 5
		CALL	BEEP
		CALL	NORMAL
; mem test 1
		LD	HL, TEST1	; start
		LD	DE, $FFFF-TEST1	; lenght
MEMCHCK:	LD	C, (HL)		; get byte
		LD	A, $55
		LD	(HL), A		; put new value
		CP	(HL)		; check it
		JR	NZ, MEMERR	; report error
		CPL			; another value
		LD	(HL), A		; put new value
		CP	(HL)		; check it
		JR	NZ, MEMERR	; report error
		LD	(HL), C		; restore original value
		INC	HL
		DEC	DE
		LD	A, D
		OR	E
		JR	NZ, MEMCHCK
; here start first test and finish second test
TEST1		EQU	$
; mem test 2
		LD	HL, $0000	; start
		LD	DE, TEST1
MEMCHCK1:	LD	C, (HL)		; get byte
		LD	A, $55
		LD	(HL), A		; put new value
		CP	(HL)		; check it
		JR	NZ, MEMERR	; report error
		CPL			; another value
		LD	(HL), A		; put new value
		CP	(HL)		; check it
		JR	NZ, MEMERR	; report error
		LD	(HL), C		; restore original value
		INC	HL
		DEC	DE
		LD	A, D
		OR	E
		JR	NZ, MEMCHCK1
		LD	HL, 256*18+TOPLINE+4
		CALL	SETPOS
		LD	HL, MEMOK
		CALL	SHTEXT
		LD	HL, 40000
		CALL	WAIT
		JP	DVIEW

MEMERR:		PUSH	HL
		LD	HL, 256*15+TOPLINE+4
		CALL	SETPOS
		LD	HL, MEMTERR
		CALL	SHTEXT
		POP	HL
		LD	A, $80		; no leading char
		CALL	PRN_DEC		; print address
		JR	$
		
; -------------------------------------
; print 16 bit decadic number
; -------------------------------------
; input
; HL:	number to print
; A:	leading char, if zero (" " or "0" or something else, no leading char if MSB set)
;
; changed
; AF, D, BC (HL, E in printing routine)
;
PRN_DEC: 	LD	E, A		; store leading char
		LD	BC, -10000	; five divisions
		CALL	PRN_DIG
		LD	BC, -1000
		CALL	PRN_DIG
		LD	BC, -100
		CALL	PRN_DIG
		LD	BC, -10
		CALL	PRN_DIG
		LD	A, '0'		; convert to char
		ADD	A, L
		JP	SHMCHAR		; always print last number
; divide
PRN_DIG: 	XOR	A		; start with zero
PRN_DIG1: 	ADD	HL, BC		; sub
		INC	A		; counter
		JR	C, PRN_DIG1	; remaining?
		SBC	HL, BC		; discard last addition
		DEC	A
		JR	Z, PRN_DIG2	; print zero or leading char
                LD	E, '0'		; change conversion const
PRN_DIG2:	BIT	7, E		; print leading char?
		RET	NZ		; no leading chars
		PUSH	HL		; prepare for print
		PUSH	DE
		ADD	A, E		; convert to char (number or space)
		CALL	SHMCHAR		; show it
		POP	DE
		POP	HL
		RET
;
MEMTEXT:	DM	"Ondra memory test"
		DB	0
MEMOK:		DM	"Memory OK"
		DB	0
MEMTERR:	DM	"Memory error at "
		DB	0