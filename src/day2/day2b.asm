INCLUDE "./src/common/common.asm"

SECTION "ROM_CONSTANTS", ROM0

RomName:
    db "DAY 2B", 0
InputText: INCBIN "./src/day2/input.txt"
InputTextEnd:

INCLUDE "./src/common/print.asm"
INCLUDE "./src/common/util.asm"


; Puts the maximum of A and C to A
; Effects: A -> max(A, C)
get_max_u8:
    
    cp c
    jp nc, get_max_u8__a_is_bigger
    ; Swap A and C
    push de
    ld d, a
    ld a, c
    ld c, d
    pop de
    get_max_u8__a_is_bigger:
    ret

; Puts the next set's power in BC
get_set_power:

    ; Advance until ':'
    ld b, $3A; ':'
    call advance_until

    ; Maximum occured cube counts.
    ld de, $0000; D -> red, E -> green
    ld bc, $0000; C -> blue

    get_set_power__loop:

    ld a, [hli]
    cp $2c ; ','
    jp z, get_set_power__loop ; Skip ',' character
    cp $20 ; ' '
    jp z, get_set_power__loop ; Skip ' ' character
    cp $3b ; ';'
    jp z, get_set_power__loop ; Skip ';' character
    cp $A  ; '\n'
    jp z, get_set_power__loop_end
    cp $0  ; '\0'
    jp z, get_set_power__loop_end

    ; Convert string to integer
    dec hl
    push bc
    push de
    call stoi_u16
    pop de

    inc hl

    ; Check cube type
    ld a, [hl]
    cp $72; 'r'
    jp z, get_set_power__red_cube
    cp $67; 'g'
    jp z, get_set_power__green_cube
    ; Blue cube
    
    ld a, c
    pop bc 
    
    call get_max_u8
    ld c, a

    ld a, $4
    jp get_set_power__found_cube
    get_set_power__red_cube:
    ; Red cube

    ld a, d
    call get_max_u8
    ld d, a
    pop bc 
    
    ld a, $3
    jp get_set_power__found_cube
    get_set_power__green_cube:
    ; Green cube
    
    ld a, e
    call get_max_u8
    ld e, a
    pop bc

    ld a, $5
    get_set_power__found_cube:
    ; A -> length of the string 
    ; HL += A
    add l
    ld l, a
    ld a, h
    adc $0
    ld h, a

    jp get_set_power__loop
    get_set_power__loop_end:

    ; Calculate the set power from the maximum occurrences
    ; BC = max red * max green * max blue

    push hl

    push de
    ld d, 0
    ; HL = C * E
    call mutliply_u16
    ld b, h
    ld c, l
    pop de

    ld e, d
    ld d, 0

    ; HL = BC * D
    call mutliply_u16

    ld b, h
    ld c, l
    pop hl

    ret


; Puts the sum of the powers of the sets in DE and BC. 
calculate_power_of_sets:

    ld de, $0000; Lower result
    ld bc, $0000; Upper result

    ld hl, InputText

    count_possible_games__loop:

    push bc
    push de
    call get_set_power
    pop de

    ; Add current power set to result.
    ; BCDE = DE + BC

    push hl
    ld h, d
    ld l, e
    add hl, bc
    ld d, h
    ld e, l
    pop hl

    pop bc

    jp nc, calculate_power_of_sets__lower_not_carry
    inc bc
    calculate_power_of_sets__lower_not_carry:

    push bc
    push hl
    ; Finish execution when pointer reaches the end.
    ld bc, InputTextEnd
    ld a, b
    cp h
    ld a, c
    pop hl
    pop bc
    ret c
    jp nz, count_possible_games__loop
    cp l
    ret c

    jp count_possible_games__loop

main:

    call calculate_power_of_sets

    ld hl, $0c0d
    call print_u32

    ld hl, RomName
    ld bc, $0702
    push de
    call print_string
    pop de

    ret