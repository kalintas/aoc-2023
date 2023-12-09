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
; Uses long division as algorithm. 
; Parameter: BC -> Upper part of the integer, DE -> Lower part of the integer
; Effects: BC, DE -> result, A -> remainder
; Mutates: HL, WorkRam[0..8]
divide_u32_by_10:

    ld hl, WorkRam
    ld a, e
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, c
    ld [hli], a
    ld a, b
    ld [hli], a
    ld a, $00
    ; Set quotient to zero
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a

    push bc
    ld bc, $0
    call push_u16 ; Remainder
    pop bc


    ld a, 31; Index of the current bit.

    divide_u32_by_10__loop:

    ; R = R << 1
    ; R(0) = N(i)
    push bc
    push af

    ; A / 8
    sra a
    sra a
    sra a

    ld hl, WorkRam
    ; HL += A
    add l
    ld l, a
    ld a, h
    adc $0
    ld h, a

    ld a, [hl]
    ld b, a
    pop af
    ; B = Current nibble of the input.

    push af
    and $7 ; A & 0x7

    ; Get the bit at the 
    divide_u32_by_10__numerator_loop:
    sub $1
    jp c, divide_u32_by_10__numerator_loop_end
    sra b
    jp divide_u32_by_10__numerator_loop
    divide_u32_by_10__numerator_loop_end:
    
    ld a, b
    and $1

    call pop_u16
    ; BC = remainder
    ; R <<= 1
    ; R |= A
    sla c
    rlc b

    or c
    ld c, a

    call push_u16

    pop af
    pop bc

    ; if R >= D then
    ;   R = R - D
    ;   Q(i) = 1
    push bc
    push af
    call pop_u16
    ; BC = remainder

    ld a, b
    cp $0
    jp nz, divide_u32_by_10__remainder_not_valid

    ld a, c
    cp 10
    jp c, divide_u32_by_10__remainder_valid

    divide_u32_by_10__remainder_not_valid:

    ; R = R - 10
    ld a, c
    sub 10
    ld c, a
    
    pop af

    ; Start

    push af
    ; A / 8
    sra a
    sra a
    sra a

    ld hl, WorkRam + 4
    ; HL += A
    add l
    ld l, a
    ld a, h
    adc $0
    ld h, a
    pop af

    push bc
    push af
    and $7 ; A & 0x7

    ld b, $1

    ; Get the bit at the 
    divide_u32_by_10__quotient_loop:
    sub $1
    jp c, divide_u32_by_10__quotient_loop_end
    sla b
    jp divide_u32_by_10__quotient_loop
    divide_u32_by_10__quotient_loop_end:

    ld a, [hl]
    or b
    ld [hl], a
    pop af
    pop bc

    ; End
    push af

    divide_u32_by_10__remainder_valid:
    call push_u16
    pop af
    pop bc

    sub 1
    jp nc, divide_u32_by_10__loop

    ld hl, WorkRam + 4
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a

    push bc
    call pop_u16
    ld a, c
    pop bc

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
; Effects: HL -> lower result, BC -> upper result
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
    push bc
    ld bc, $0000
    call push_u16
    pop bc

    mutliply_u16__loop:
    
    ld a, d
    cp $0
    jp nz, mutliply_u16__d_non_zero 
    ld a, e
    cp $0
    jp z, mutliply_u16__loop_end; DE = 0. Multiplication is finished

    mutliply_u16__d_non_zero:

    dec de
    add hl, bc

    jp nc, mutliply_u16__loop 

    ; Carry occured. Increase upper result.

    push bc
    call pop_u16
    inc bc
    call push_u16
    pop bc

    jp mutliply_u16__loop
    mutliply_u16__loop_end:

    call pop_u16    
    ret