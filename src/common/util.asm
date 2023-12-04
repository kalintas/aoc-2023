
; Checks if given 8 bit value is a ascii digit or not.
; Must be in range of [$30, $39]
; Parameter: A -> character to be checked
; Effects: Z -> digit, NZ -> not digit
; Mutates: A, F
is_digit:
    cp $30  
    jp c, is_digit__not_digit
    cp $3A
    jp nc, is_digit__not_digit
    jp z, is_digit__not_digit

    ;It is a digit
    cp a ;Z = 1
    ret 
    is_digit__not_digit:

    ld a, $1
    cp $2 ;Z = 0
    ret

; Does a integer division with given parameter.
; Parameter: DE -> input
; Effects: BC -> result, A -> remainder
; Mutates: HL
divide_u16_by_10:

    ld h, d
    ld l, e

    ; Division result
    ld b, $ff
    ld c, $ff

    divide_u16_by_10__loop:

    inc bc

    ; hl - 10
    ld a, l
    sub $a
    ld l, a
    jp nc, divide_u16_by_10__loop

    ; Carry occured (hl & 0xFF < 10)
    ; Check hl < 10, if so end division

    ld a, h
    sub $1
    ld h, a
    jp nc, divide_u16_by_10__loop 

    ; Division ended    

    ld a, l
    add $a; value in A is the remainder

    ret

; Does a integer multiplication with given parameters.
; Parameter: A -> lhs, B -> rhs
; Effects: A -> result of A * B
; Mutates: C
mutliply_u8:
    
    ; Find the max and iterate with the min.
    ; A = max(A, B)
    cp b 
    jp nc, mutliply_u8__a_is_bigger

    ld c, a
    ld a, b
    ld b, c
    
    mutliply_u8__a_is_bigger:

    ld c, a
    ld a, $0

    cp b
    ret z

    mutliply_u8__loop:

    add a, c

    dec b
    ret z 
    
    jp mutliply_u8__loop


; Does a memory compare in given address.
; Parameter: HL -> lhs address, DE -> rhs address, C -> length in bytes
; Effects: Z -> equal, NZ -> not equal
; Mutates HL, DE, AF, BC
memcmp: 

    ; Check C
    ld a, c
    cp $0
    ret z ; C = 0, Z = 1
    dec c ; Decrement c

    ld a, [hli]
    push hl
    ld h, d
    ld l, e

    push af
    ld a, [hli]
    ld b, a
    pop af

    ; Revert hl
    ld d, h
    ld e, l

    pop hl

    cp b ;compare bytes
    jp z, memcmp
    ; Mem not equal
    ld a, 0
    cp $1
    ret ;Z = 0

    
