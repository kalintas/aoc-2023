SECTION "INPUT_TEXT0", ROMX

InputText0: INCBIN "./src/day3/input0.txt"
InputText0End:

SECTION "INPUT_TEXT1", ROMX

InputText1: INCBIN "./src/day3/input1.txt"
InputText1End:

SECTION "WORK_STACK", WRAM0
GearStack: ds $10
GearSP: ds $1

INCLUDE "./src/common/common.asm"

SECTION "ROM_CONSTANTS", ROM0

RomName:
    db "DAY 3B", 0

INCLUDE "./src/common/print.asm"
INCLUDE "./src/common/util.asm"

DEF TABLE_SIZE EQU 140


push_characters:
    ld a, $0; index

    push_characters__loop:
    cp $5
    ret z
    ret nc

    push af
    call stoi_u16
    jp nz, push_characters__not_number

    pop af
    ; Check a == 0 && e != 3
    add e; Add character count in number.

    cp e
    jp z, push_characters__loop_first_iter   
    ; A > 0
    call push_u16 ; Push the number to stack.
    jp push_characters__loop
    
    push_characters__loop_first_iter:
    ; A == 0
    ; Cannot push if e != 3 
    cp $3
    jp nz, push_characters__loop_cannot_push

    call push_u16 ; Push the number to stack.

    push_characters__loop_cannot_push:
    jp push_characters__loop

    push_characters__not_number:
    pop af
    add 1
    call increment_address
    jp push_characters__loop

get_gear_ratio_sum: 
    
    ld de, $0000; Lower result
    ld bc, $0000; Upper result
    ld hl, InputText0; Start address.

    get_gear_ratio_sum__loop:

    ; Skip non digit, symbol characters
    ld a, [hl]
    cp $0; ; '\0' Finish execution.
    ret z 
    cp $2a ; '*'
    jp nz, get_gear_ratio_sum__loop_skip ; Skip if character is not '*'

    call increment_address

    ; Clear the stack.
    ld a, $0
    ld [WorkStackSP], a

    ; Check sides for digit. Check right.
    ; HL = Right
    push bc
    push de
    
    push hl
    call stoi_u16

    jp nz, get_gear_ratio_sum__right_no_number
    ; Push the integer to stack.
    call push_u16
    get_gear_ratio_sum__right_no_number:
    pop hl

    call push_rom_bank
    push hl
    ; HL = HL - 4
    ld a, l
    sub 4
    ld l, a
    ld a, h
    sbc $0
    ld h, a 
    call update_rom_bank

    ; HL = Left
    ; Check left.
    call push_rom_bank
    push hl

    ; Check if the * has any digit in its left.
    call push_rom_bank
    push hl
    ld bc, $2
    add hl, bc
    call update_rom_bank
    ld a, [hl]
    call is_digit
    pop hl
    call pop_rom_bank
    jp nz, get_gear_ratio_sum__left_no_number

    ; Check if it is a digit.
    ld a, [hl]
    call is_digit

    jp z, get_gear_ratio_sum__left_is_digit
    call increment_address; Increment to next char.

    ; Check if it is a digit again.
    ld a, [hl]
    call is_digit

    jp z, get_gear_ratio_sum__left_is_digit
    call increment_address; Increment to next char.
    get_gear_ratio_sum__left_is_digit:

    call stoi_u16
    jp nz, get_gear_ratio_sum__left_no_number
    call push_u16
    get_gear_ratio_sum__left_no_number:
    pop hl
    call pop_rom_bank

    ; Check up.
    call push_rom_bank
    push hl
    
    ; Get upper left corner.
    ; HL = HL - (TABLE_SIZE + 1)
    ld bc, TABLE_SIZE + 1
    ld a, l
    sub c
    ld l, a
    ld a, h
    sbc b
    ld h, a
    call update_rom_bank

    call push_characters
    pop hl
    call pop_rom_bank

    ; Check bottom.
    ; Get lower left corner.
    ; HL = HL + TABLE_SIZE + 1
    ld bc, TABLE_SIZE + 1
    add hl, bc
    call update_rom_bank

    call push_characters

    pop hl
    call pop_rom_bank

    ; Pop numbers.
    push hl

    call get_stack_length
    cp $2
    jp c, get_gear_ratio_sum__not_a_gear_ratio; Not a gear ratio.

    call pop_u16

    push bc 
    call pop_u16
    ld d, b
    ld e, c
    pop bc

    ; BC = first number, DE = second number
    call mutliply_u16

    call push_u16; Push upper result

    ; BC = current gear ratio
    ld b, h
    ld c, l

    pop hl
    pop de

    ; DE = DE + BC
    ld a, e
    add c
    ld e, a
    ld a, d
    adc b
    ld d, a

    pop bc
    
    jp nc, get_gear_ratio_sum__upper_no_carry
    inc bc
    get_gear_ratio_sum__upper_no_carry:

    ; Add upper result.
    
    push hl

    push bc
    call pop_u16
    ld h, b
    ld l, c
    pop bc

    ; BC = HL + BC
    add hl, bc
    ld b, h
    ld c, l

    pop hl

    jp get_gear_ratio_sum__loop

    get_gear_ratio_sum__not_a_gear_ratio:
    pop hl
    pop de
    pop bc
    get_gear_ratio_sum__loop_skip:
    call increment_address
    jp get_gear_ratio_sum__loop

main:

    call get_gear_ratio_sum
    
    ld hl, $0d0d
    call print_u32

    ld hl, RomName
    ld bc, $0702
    call print_string

    ret