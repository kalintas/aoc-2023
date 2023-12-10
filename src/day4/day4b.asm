SECTION "INPUT_TEXT0", ROMX

InputText0: INCBIN "./src/day4/input0.txt"
InputText0End:

SECTION "INPUT_TEXT1", ROMX

InputText1: INCBIN "./src/day4/input1.txt"
InputText1End:

INCLUDE "./src/common/common.asm"

SECTION "ROM_CONSTANTS", ROM0

RomName:
    db "DAY 4B", 0

INCLUDE "./src/common/print.asm"
INCLUDE "./src/common/util.asm"

; Writes winning numbers and initializes copy counts.
; Format:
; Total scratchcard count(8 bit), [copy count(24 bit(LE)), winning number(8 bit)]...
winning_number_callback:
    
    push hl

    ld a, [WorkRam] ; Index

    add $1
    ld [WorkRam], a
    sub $1

    ; BC = A
    ld c, a
    ld b, $0
    ; BC <<= 2
    sla c
    rl b

    sla c
    rl b

    ld hl, WorkRam + 1
    ; HL += BC
    add hl, bc

    ; Save copy count. (24 bit)
    ld a, $1
    ld [hli], a
    ld a, $0
    ld [hli], a
    ld [hli], a

    ; Save winning number
    ld a, d
    ld [hli], a

    pop hl

    ret

INCLUDE "./src/day4/common.asm"

; Iterates all cards and writes final card counts.
calculate_copy_card_counts:

    ld a, [WorkRam]
    ld hl, WorkRam + 1

    calculate_copy_card_counts__loop:
    sub $1
    ret c
    
    ; Process this cards winning numbers and change other cards copy count.
    push af

    ; Get copy count
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld d, a
    ; DBC = copy count

    ; Get winning number
    ld a, [hli]

    push hl
    calculate_copy_card_counts__copy_cards_loop:
    sub $1
    jp c, calculate_copy_card_counts__copy_cards_loop_end 

    push af
    push de
    push bc
    push hl

    ; Get copy count of other card
    push de
    ld a, [hli] 
    ld e, a
    ld a, [hli] 
    ld d, a

    ; BC += DE
    ld a, c
    add e
    ld c, a
    ld a, b
    adc d
    ld b, a
    pop de

    ld a, [hli]
    adc d
    ld d, a

    pop hl
    ; DBC = sum result
    ; Save result of the sum.

    ld a, c
    ld [hli], a
    ld a, b
    ld [hli], a
    ld a, d
    ld [hli], a

    pop bc
    pop de
    pop af

    inc hl ; Skip winning number

    jp calculate_copy_card_counts__copy_cards_loop
    calculate_copy_card_counts__copy_cards_loop_end:

    pop hl
    pop af

    jp calculate_copy_card_counts__loop

    ret

; Sums all card counts in BCDE.
get_total_card_count:
    ld de, $0000; Lower part of the result.
    ld bc, $0000; Upper part of the result.

    ld a, [WorkRam]
    ld hl, WorkRam + 1

    get_total_card_count__loop:
    sub $1
    jp c, get_total_card_count__loop_end

    push af

    push bc 
    ; Get the copy card count.
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a

    ; BCDE += BC
    ld a, e
    add c
    ld e, a
    ld a, d
    adc b
    ld d, a
    pop bc

    ld a, [hli]
    adc c
    ld c, a
    ld a, b
    adc $0
    ld b, a

    pop af

    inc hl

    jp get_total_card_count__loop 
    get_total_card_count__loop_end:

    ret

main:

    ; Initialize index.
    ld a, $0
    ld [WorkRam], a 

    ; Save all winning numbers to WorkRam
    call iterate_winning_numbers

    call calculate_copy_card_counts

    call get_total_card_count

    ld hl, $0c0d
    call print_u32

    ld hl, RomName
    ld bc, $0702
    call print_string

    ret