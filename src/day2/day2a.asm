INCLUDE "./src/common/common.asm"

SECTION "ROM_CONSTANTS", ROM0

RomName:
    db "DAY 2A", 0
InputText: INCBIN "./src/day2/input.txt"
InputTextEnd:

INCLUDE "./src/common/print.asm"
INCLUDE "./src/common/util.asm"

RED_CUBE_COUNT EQU 12
GREEN_CUBE_COUNT EQU 13
BLUE_CUBE_COUNT EQU 14

; Checks if the given set is possible or not.
; Z -> possible, NZ -> not possible, Cy -> game finished
is_set_possible:
    ld de, $0000; D -> red, E -> green
    ld bc, $0000; B -> blue, C -> read last character

    is_set_possible__loop:

    ld a, [hli]
    cp $2c ; ','
    jp z, is_set_possible__loop ; Skip ',' character
    cp $20 ; ' '
    jp z, is_set_possible__loop ; Skip ' ' character
    cp $A  ; '\n'
    jp z, is_set_possible__loop_end
    cp $0  ; '\0'
    jp z, is_set_possible__loop_end
    cp $3b ; ';'
    jp z, is_set_possible__loop_end

    dec hl
    ; Read 1 poll
    push bc
    push de
    call stoi_u16
    pop de
    
    inc hl

    ; Check cube type
    ld a, [hl]
    cp $72; 'r'
    jp z, is_set_possible__red_cube
    cp $67; 'g'
    jp z, is_set_possible__green_cube
    ; Blue cube
    
    ld a, c
    pop bc 
    
    add b
    ld b, a

    ld a, $4
    jp is_set_possible__found_cube
    is_set_possible__red_cube:
    ; Red cube
    
    ld a, d
    add c
    ld d, a
    pop bc

    ld a, $3
    jp is_set_possible__found_cube
    is_set_possible__green_cube:
    ; Green cube
    ld a, e 
    add c
    ld e, a
    pop bc

    ld a, $5
    is_set_possible__found_cube:
    ; A -> length of the string 

    add l
    ld l, a
    ld a, h
    adc $0
    ld h, a

    jp is_set_possible__loop

    is_set_possible__loop_end:
    ld c, a

    ; Check red cube count.
    ld a, d
    cp RED_CUBE_COUNT + 1
    jp nc, is_set_possible__set_impossible

    ; Check green cube count.
    ld a, e
    cp GREEN_CUBE_COUNT + 1
    jp nc, is_set_possible__set_impossible

    ; Check blue cube count.
    ld a, b
    cp BLUE_CUBE_COUNT + 1
    jp nc, is_set_possible__set_impossible

    ; Set is possible. Z = 1
    cp a
    jp is_set_possible__finish_set

    is_set_possible__set_impossible:
    ; Z = 0
    ld a, $1
    add $1

    is_set_possible__finish_set:
    push af
    ld a, c
    cp $3b ; ';'
    jp nz, is_set_possible__game_finished
    pop af
    ret
    is_set_possible__game_finished:
    pop af
    scf ; Game finished. Set carry flag.
    ret

; Checkes if the given game is possible or not.
; A game is consists of a single line and may contain multiple set.
; Z -> Possible, NZ -> Not Possible
is_game_possible:

    ; Advance until ':'
    ld b, $3A; ':'
    call advance_until

    inc hl

    is_game_possible__loop:

    call is_set_possible
    
    ret c ;Game finished and possible
    jp nz, is_game_possible__game_impossible

    jp is_game_possible__loop
    is_game_possible__game_impossible:
    ; Consume the line by advancing until '\n'
    ld b, $A; '\n'
    call advance_until

    ; Z = 0
    ld a, $1
    add $1

    ret

; Puts the sum of the IDs of possible games in DE. 
count_possible_games:

    ld de, $0; Result
    ld b, $0; Current ID
    ld hl, InputText

    count_possible_games__loop:

    inc b

    push de
    push bc
    call is_game_possible
    pop bc
    pop de
    jp nz, count_possible_games__game_impossible
    
    ; DE = DE + B
    ld a, e
    add b
    ld e, a
    ld a, d
    adc $0
    ld d, a    
    count_possible_games__game_impossible:

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

    call count_possible_games

    ld hl, RomName
    ld bc, $0702
    push de
    call print_string
    pop de

    ld bc, $0b0d
    call print_u16

    ret