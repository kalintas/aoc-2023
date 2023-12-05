
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

; Does a integer division with given parameter.
; Parameter: BC -> Upper part of the integer, DE -> Lower part of the integer
; Effects: BC, DE -> result, A -> remainder
; Mutates: HL
divide_u32_by_10:

    ld hl, $ffff
    push hl
    push hl

    divide_u32_by_10__loop:

    ; Increment result.
    pop hl; DE
    ; HL += 1
    ld a, l
    add $1
    ld l, a
    ld a, h
    adc $0
    ld h, a
    
    jp nc, divide_u32_by_10__loop_no_carry

    pop hl
    ; HL += 1
    ld a, l
    add $1
    ld l, a
    ld a, h
    adc $0
    ld h, a
    push hl
    ld hl, $0000
    divide_u32_by_10__loop_no_carry:
    push hl

    ; DE - 10
    ld a, e
    sub $a
    ld e, a
    jp nc, divide_u32_by_10__loop

    ld a, d
    sub $1
    ld d, a
    jp nc, divide_u32_by_10__loop

    ld a, c
    sub $1
    ld c, a
    jp nc, divide_u32_by_10__loop

    ld a, b
    sub $1
    ld b, a
    jp nc, divide_u32_by_10__loop

    ; Division ended

    ld a, e
    add $a; value in A is the remainder

    pop hl
    ld d, h
    ld e, l
    pop hl
    ld b, h
    ld c, l

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

; Does a integer multiplication with given parameters.
; Parameter: BC -> lhs, DE -> rhs
; Effects: HL -> result of BC * DE
mutliply_u16:
    
    ; Find the max and iterate with the min
    ; BC = max(BC, DE)

    ld a, d
    cp b
    jp c, mutliply_u16__bc_is_bigger
    ld a, c
    cp e
    jp c, mutliply_u16__bc_is_bigger

    ld h, d
    ld l, e

    ld d, b
    ld e, c

    ld b, h
    ld c, l

    mutliply_u16__bc_is_bigger:

    ld hl, $0000

    mutliply_u16__loop:
    
    ld a, d
    cp $0
    jp nz, mutliply_u16__d_non_zero 
    ld a, e
    cp $0
    ret z; DE = 0. Multiplication is finished

    mutliply_u16__d_non_zero:

    add hl, bc

    dec de

    jp mutliply_u16__loop


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

    
; Advances HL until parameter B encountered.
; Effects: HL -> address right after finding B.
; Mutates: AF
advance_until:

    advance_until__loop:
    ld a, [hli]
    cp b
    jp nz, advance_until__loop
    ret

; Converts the string in the address HL to a integer.
; Effects: HL -> address right after the integer, BC -> integer representation of the given string.
; Mutates: BC, DE, AF
stoi_u16:

    ld bc, $0000 ;Result

    stoi_u16__loop:

    ld a, [hl]
    call is_digit
    ret nz

    inc hl
    
    ; Convert to integer.
    sub $30

    ; BC = BC * 10
    push af
    ld de, $a
    push hl
    call mutliply_u16
    ld b, h
    ld c, l

    pop hl
    pop af

    ; BC = BC + A
    add c
    ld c, a
    ld a, b
    adc $0
    ld b, a  

    jp stoi_u16__loop

