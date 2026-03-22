;------------------------------------------------------------
; Bubble sort for 11 byte long strings placed on 16-byte boundaries
; 5th bit of flags on 12th byte taken into account first
; base address = 0x8000
;------------------------------------------------------------
SORT_FILENAMES:
        ld a, 040h            ; 64 us total per line
        in   a,(5)            ; only 10 lines (RORed) to be shown (for speed-up)
        ld   hl,31            ; last text row
        call NORMAL    ; write text "Sorting files..." 
        call SETPOS
        call CLINE
        ld hl, TEXT_SORTING
        call SHTEXT

        ld      a, (RECORDS)
        ld      c, a
        dec     a
        jr      z, sort_exit     ; only 1 file => do not sort

        ld      ix, RECLIST       ; left record address
        ld      iy, RECLIST+010h  ; right record address

        ld      a, (RECLIST)
        cp      '.'              ; is first record ".."" ?
        jr      nz, sort_nodot   ; if not, include it in sorting

        ld      ix, RECLIST+010h ; otherwise exclude it and move to the next 
        ld      iy, RECLIST+020h ; item
        dec     c                ; sort one item less as .. won't be sorted
        jr      z, sort_exit     ; only 1 file => do not sort
        
        
sort_nodot:
        push    ix
        push    iy
        push    bc
sort_outer_loop:
        pop     bc
        pop     iy
        pop     ix
        ld      a, c
        dec     a
        jr      z, sort_exit
        ld      c, a
        push    ix
        push    iy
        push    bc

sort_inner_loop:
        push    bc
        push    ix
        push    iy
        call    CMP12_IX_IY
        jr      nc, sort_no_swap
        pop     iy
        pop     ix
        push    ix
        push    iy
        call    SWAP12_IX_IY
sort_no_swap:
        pop     iy
        pop     ix
        pop     bc

        ld      de, 16
        add     ix, de
        add     iy, de
        dec     c
        jr      nz, sort_inner_loop
        jr      sort_outer_loop
sort_exit:
        jp RET_FROM_SORT   ; sorted, set video counters and print all 

TEXT_SORTING:		DM	"Sorting files..."
		DB	0


;------------------------------------------------------------
; CMP12_IX_IY  compare 12 bytes of (IX) vs (IY)
;
; if the 1st is file and 2nd directory, return with NZ and C (swap)
; if the 1st is directory and 2nd file, return with NZ and NC (no swap)
; if both are file or both are directories, compare filenames
; if 1st is higher (later in alphabet), return with NZ and C (swap)
; otherwise return with NZ and NC (no swap)
; never should return with Z (same filename => duplicity)
;------------------------------------------------------------
CMP12_IX_IY:
        ld      a,(ix+11)   ; flags for left
        and      020h       ; only dir flag
        ld      h, a
        ld      a,(iy+11)   ; flags for right
        and     020h        ; only dir flag
        cp      h           ; directories first, carry will be set for swap
        jr      nz, cmp12_done    ; file and dir => do not compare names
        ld      b, 11              ; same type => compare 11 characters of filename
cmp12_loop:
        ld      a, (ix)
        ld      h, a
        ld      a, (iy)
        cp      h
        jr      nz, cmp12_done
        inc     ix
        inc     iy
        djnz    cmp12_loop
        xor     a                ; equality, should never get here
cmp12_done:
        ret

;------------------------------------------------------------
; SWAP12_IX_IY - swaps 12 bytes between IX and IY 
;------------------------------------------------------------
SWAP12_IX_IY:
        ld      b, 12
swap12_loop:
        ld      a, (ix)
        ld      h, a
        ld      a, (iy)
        ld      (ix), a
        ld      a, h
        ld      (iy), a
        inc     ix
        inc     iy
        djnz    swap12_loop
        ret
