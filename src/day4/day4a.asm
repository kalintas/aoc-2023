SECTION "INPUT_TEXT0", ROMX

InputText0: INCBIN "./src/day4/input0.txt"
InputText0End:

SECTION "INPUT_TEXT1", ROMX

InputText1: INCBIN "./src/day4/input1.txt"
InputText1End:

INCLUDE "./src/common/common.asm"

SECTION "ROM_CONSTANTS", ROM0

RomName:
    db "DAY 4A", 0

INCLUDE "./src/common/print.asm"
INCLUDE "./src/common/util.asm"

; D = winning number
; Calculate result += 2^D
winning_number_callback:
    
    ld a, d
    cp $0
    ret z

    ld bc, $0001 ; Points

    winning_number_callback__loop:

    dec d
    jp z, winning_number_callback__loop_end
    
    ; Shift BC left.
    sla c
    rl b
    jp winning_number_callback__loop
    winning_number_callback__loop_end:

    push hl

    ld hl, sp+$0
    ld sp, WorkRam + 4

    ; BCDE += BC
    pop de
    ; DE += BC
    ld a, e
    add c
    ld e, a
    ld a, d
    adc b
    ld d, a

    pop bc

    jp nc, winning_number_callback__bc_no_carry 
    inc bc
    winning_number_callback__bc_no_carry:

    push bc
    push de

    ld sp, hl
    
    pop hl

    ret

INCLUDE "./src/day4/common.asm"

main:

    ; Initialize ram.
    ld a, $0
    ld [WorkRam], a
    ld [WorkRam + 1], a
    ld [WorkRam + 2], a
    ld [WorkRam + 3], a

    call iterate_winning_numbers

    ; Retrieve result
    ld hl, sp+$0
    ld sp, WorkRam + 4
    pop de
    pop bc
    ld sp, hl

    ld hl, $0c0d
    call print_u32

    ld hl, RomName
    ld bc, $0702
    call print_string

    ret