
SECTION "INPUT_TEXT0", ROMX

InputText0: INCBIN "./src/day1/input0.txt"
InputText0End:

SECTION "INPUT_TEXT1", ROMX

InputText1: INCBIN "./src/day1/input1.txt"
InputText1End:

INCLUDE "./src/common/common.asm"

SECTION "ROM_CONSTANTS", ROM0

RomName:
    db "DAY 1A", 0

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
    ld a, c

    ret
