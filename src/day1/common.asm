; Returns calibration count in A.
get_line_calibration:

    ld de, $0000; d -> first digit, e -> last digit
    ld bc, $0000; b -> first digit found, c -> last digit found

    get_line_calibration__loop:

    ld a, [hl]
    cp $A
    jp z, get_line_calibration__finished ; Line finished
    cp $0
    jp z, get_line_calibration__finished

    push bc
    call is_calibration_digit
    pop bc
    
    inc hl ; increment address after calling is_calibration_digit
    push af

    jp nz, get_line_calibration__digit_not_found

    ;digit found

    ld a, 0
    cp b
    jp z, get_line_calibration__first_digit_found

    ; not the first digit
    ld c, 1
    pop af
    ld e, a
    jp get_line_calibration__loop

    get_line_calibration__first_digit_found:
    ld b, 1
    pop af
    ld d, a
    jp get_line_calibration__loop

    get_line_calibration__digit_not_found:
    pop af
    jp get_line_calibration__loop

    get_line_calibration__finished:
    inc hl

    ; if c == 0 { d * 11 } else { d * 10 + e } 
    ld a, 0
    cp c
    jp nz, two_digit_found
    add d
    two_digit_found:

    add e
    ; return d * 11
    ld b, $a

    calculation_loop:
    add a, d
    dec b
    jp nz, calculation_loop

    ret

get_calibration:
    ld bc, $0; line counter

    get_calibration__loop:

    push bc

    push de
    call get_line_calibration
    pop de

    push hl

    ld h, d
    ld l, e

    ld b, $0
    ld c, a

    add hl, bc
    
    ld d, h
    ld e, l
    pop hl

    pop bc

    inc bc

    ld a, b
    cp $1

    jp nz, get_calibration__loop

    ld a, c
    cp $f4

    jp nz, get_calibration__loop
    ret

main:

    ld de, $0; result

    ; Get calibration in the first part of the string
    ld hl,$2000
    ld [hl],$2
    ld hl, InputText0
    call get_calibration

    ; Get calibration in the second part of the string
    ld hl,$2000
    ld [hl],$1
    ld hl, InputText1
    call get_calibration
    
    ld hl, RomName
    ld bc, $0702
    push de
    call print_string
    pop de

    ld bc, $0c0d
    call print_u16

    ret
