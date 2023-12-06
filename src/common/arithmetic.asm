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