
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
    
    call increment_address ; increment address after calling is_calibration_digit

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
    call increment_address
    
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

    ld de, $0; result

    get_calibration_loop:

    push de
    call get_line_calibration
    pop de

    add e
    ld e, a
    ld a, d
    adc $0
    ld d, a

    ; Check if calibration is finished.
    ld a, [CurrentRomBank]
    cp $2
    jp nz, get_calibration_loop

    ; BC = InputText1End
    push hl
    ld hl, InputText1End
    ld b, h
    ld c, l
    pop hl

    ; Stop execution if HL >= BC

    ld a, h
    cp b
    jp c, get_calibration_loop

    ld a, l
    cp c
    jp c, get_calibration_loop

    ret

main:

    ; Get calibration in the first part of the string
    ld hl,$2000
    ld [hl],$1
    ld hl, InputText0
    call get_calibration

    ld hl, RomName
    ld bc, $0702
    push de
    call print_string
    pop de

    ld bc, $0c0d
    call print_u16

    ret
