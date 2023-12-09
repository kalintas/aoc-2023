SECTION "INPUT_TEXT0", ROMX

InputText0: INCBIN "./src/day3/input0.txt"
InputText0End:

SECTION "INPUT_TEXT1", ROMX

InputText1: INCBIN "./src/day3/input1.txt"
InputText1End:

INCLUDE "./src/common/common.asm"

SECTION "ROM_CONSTANTS", ROM0

RomName:
    db "DAY 3A", 0

INCLUDE "./src/common/print.asm"
INCLUDE "./src/common/util.asm"

DEF TABLE_SIZE EQU 140

; Check whether A is a symbol.
; Effects: Z -> symbol, NZ -> not a symbol
; Mutates: A, F
is_symbol:

    cp $2e; '.' is not a symbol
    jp z, is_symbol__not_symbol
    cp $0; '\0' is not a symbol
    jp z, is_symbol__not_symbol
    cp $a; '\n' is not a symbol
    jp z, is_symbol__not_symbol

    call is_digit ; Digits are not symbol
    jp z, is_symbol__not_symbol

    ; Character is symbol
    cp a ; Z = 1
    ret
    is_symbol__not_symbol:
    ; Z = 0
    ld a, $0
    add 1
    ret

; Checks symbols in range [HL, HL + E + 1]. Total E + 2 characters are checked
; Effects: Z -> has symbol, NZ -> does not have symbol
; Mutates: HL, A, BC, DE
check_symbols:

    ld d, $0 ; Index
    ld a, e
    add $1
    ld e, a
    
    check_symbols__loop:

    ld a, [hl]
    call is_symbol
    ret z

    ld a, e
    cp d
    jp z, check_symbols__not_symbol

    call increment_address
    inc d

    jp check_symbols__loop
    check_symbols__not_symbol:
    ; Z = 0
    ld a, $0
    add $1
    ret


get_sum_of_part_numbers: 
    
    ld de, $0000; Lower result
    ld bc, $0000; Upper result
    ld hl, InputText0; Start address.

    get_sum_of_part_numbers__loop:

    ; Skip non digit, symbol characters
    ld a, [hl]
    cp $2e ; '.'
    jp z, get_sum_of_part_numbers__loop_skip ; Skip '.' character
    cp $A  ; '\n'
    jp z, get_sum_of_part_numbers__loop_skip ; Skip '\n' character
    cp $0  ; '\0'
    jp z, get_sum_of_part_numbers__loop_end
   
    call is_digit

    jp nz, get_sum_of_part_numbers__loop_skip ; Skip symbol 

    push bc
    push de
    call stoi_u16
    ; BC = number
    ; E = number character length

    ; Check left(HL - number character length), right(HL)
    ; Right
    push hl
    call push_rom_bank

    ld a, [hl]
    call is_symbol
    
    jp z, get_sum_of_part_numbers__is_part_number ; Right check

    ; Left
    ; HL = HL - E - 1
    push bc

    ; E + 1
    ld a, e
    add 1
    ld b, a

    ; HL - E - 1
    ld a, l
    sub b
    ld l, a
    ld a, h
    sbc $0
    ld h, a

    pop bc   

    call update_rom_bank
    ld a, [hl]
    call is_symbol

    jp z, get_sum_of_part_numbers__is_part_number ; Left check

    call push_rom_bank

    ; HL = Left

    ; Check top [Left - TABLE_SIZE, Left - TABLE_SIZE + number character length + 1]
    push bc
    ; BC = TABLE_SIZE + 1
    ld bc, TABLE_SIZE + 1

    push hl
    ; HL - TABLE_SIZE - 1
    ld a, l
    sub c
    ld l, a    
    ld a, h
    sbc b
    ld h, a

    push de
    call update_rom_bank
    call check_symbols
    pop de
    pop hl

    pop bc

    call pop_rom_bank

    jp z, get_sum_of_part_numbers__is_part_number ; Top check

    ; Check bottom [Left + TABLE_SIZE, Left + TABLE_SIZE + number character length + 1]
    push bc
    ; BC = TABLE_SIZE + 1
    ld bc, TABLE_SIZE + 1

    push hl
    ; HL + TABLE_SIZE + 1
    add hl, bc  
    push de
    call update_rom_bank
    call check_symbols
    pop de
    pop hl
    
    pop bc

    jp z, get_sum_of_part_numbers__is_part_number ; Bottom check
    
    ; Not a part number. Continue searching.
    call pop_rom_bank
    pop hl
    pop de
    pop bc
    call increment_address
    jp get_sum_of_part_numbers__loop
    
    get_sum_of_part_numbers__is_part_number:

    ; It is a part number. Add it to result
    call pop_rom_bank
    pop hl
    pop de

    ; DE = DE + BC
    ld a, e
    add c
    ld e, a
    ld a, d
    adc b
    ld d, a

    ; Increase upper part of the result if there is a carry.
    pop bc

    jp nc, get_sum_of_part_numbers__result_no_carry
    inc bc
    get_sum_of_part_numbers__result_no_carry:

    get_sum_of_part_numbers__loop_skip:
    call increment_address
    jp get_sum_of_part_numbers__loop
    get_sum_of_part_numbers__loop_end:

    ret

main:

    call get_sum_of_part_numbers

    ld hl, $0c0d
    call print_u32

    ld hl, RomName
    ld bc, $0702
    call print_string

    ret