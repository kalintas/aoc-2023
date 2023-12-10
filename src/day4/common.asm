
; Iterates all winning numbers and calls the given callback.
iterate_winning_numbers:

    ld hl, InputText0

    iterate_winning_numbers__loop:

    ; Stop execution when input finishes.
    ld a, [hl]
    cp $0
    ret z

    ; Advance until ':'
    ld b, $3A ; ':' 
    call advance_until

    call clear_stack

    ; Push winning numbers to stack.
    iterate_winning_numbers__winning_numbers_loop:

    ld a, [hl]
    cp $7c; '|'
    jp z, iterate_winning_numbers__winning_numbers_loop_end ; Stop on '|'

    call stoi_u16
    jp z, iterate_winning_numbers__winning_numbers_loop_is_number

    call increment_address
    jp iterate_winning_numbers__winning_numbers_loop
    iterate_winning_numbers__winning_numbers_loop_is_number:
    
    call push_u16
    jp iterate_winning_numbers__winning_numbers_loop
    iterate_winning_numbers__winning_numbers_loop_end:

    call increment_address ; Skip '|'

    ; Count winning numbers.
    ld d, $00; Winning number count.
    iterate_winning_numbers__numbers_loop:
    
    ld a, [hl]
    cp $a; '\n'
    jp z, iterate_winning_numbers__numbers_loop_end ; Stop on '\n'

    push de
    call stoi_u16
    pop de
    jp z, iterate_winning_numbers__numbers_loop_is_number
    call increment_address
    jp iterate_winning_numbers__numbers_loop
    iterate_winning_numbers__numbers_loop_is_number:

    call stack_contains
    jp nz, iterate_winning_numbers__numbers_loop
    inc d

    jp iterate_winning_numbers__numbers_loop
    iterate_winning_numbers__numbers_loop_end:

    ; D = ocurred winning number count.
    call winning_number_callback ; Call given callback.

    call increment_address
    jp iterate_winning_numbers__loop
    
    ret