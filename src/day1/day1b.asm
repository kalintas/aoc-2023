
SECTION "INPUT_TEXT0", ROMX

InputText0: INCBIN "./src/day1/input0.txt"
InputText0End:

SECTION "INPUT_TEXT1", ROMX

InputText1: INCBIN "./src/day1/input1.txt"
InputText1End:

INCLUDE "./src/common/common.asm"

SECTION "ROM_CONSTANTS", ROM0

RomName:
    db "DAY 1B", 0
DigitStrings:
    db $4, "zero"
    db $3, "one"
    db $3, "two"
    db $5, "three"
    db $4, "four"
    db $4, "five"
    db $3, "six"
    db $5, "seven"
    db $5, "eight"
    db $4, "nine"

INCLUDE "./src/common/print.asm"
INCLUDE "./src/common/util.asm"

INCLUDE "./src/day1/common.asm"

; Parameters: A -> digit, HL -> address of the digit
; Effects: A -> digit, Z -> digit, NZ -> not digit
is_calibration_digit:
    
    ld c, a ; a - $30
    ld b, a ; original a value
    sub $30
    ld c, a
    ld a, b

    call is_digit
    jp nz, is_calibration_digit_not_digit
    
    ld a, c
    ret

    is_calibration_digit_not_digit:

    ; Is not a real digit.
    ; Check for string digits.("one", "two")

    push de

    ld b, $0 ; current string index
    ld de, DigitStrings ; pointer to current string

    is_calibration_digit_compare_loop:

    push hl
    ld h, d
    ld l, e
    ld a, [hl]
    ld c, a
    pop hl

    inc de

    push hl
    push bc
    push de
    call memcmp
    pop de
    pop bc
    pop hl
    jp z, is_calibration_digit_compare_finished

    ; Increment current pointer
    ld a, e
    add a, c
    ld e, a
    ld a, 0
    adc d
    ld d, a

    ; Increment index
    inc b
    ld a, $a
    cp b
    jp nz, is_calibration_digit_compare_loop

    is_calibration_digit_compare_finished:
    ld a, b; b -> digit 
    
    pop de
    
    cp $a
    jp c, is_calibration_digit_carry

    cp $0 ; Z = 0 (Not a digit)
    ret

    is_calibration_digit_carry:

    cp a; Z = 1 (Is a digit)
    ret
