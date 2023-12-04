
; Print the character to the screen.
; A -> character, B -> X location, C -> Y Location
; Mutates: A, DE 
print_character:
    push hl

    cp a, $41 ; is upper table
    jp nc, print_character__lower_table

    cp a, $20 ; is space
    jp nz, print_character__upper_table
    ld a, $0
    jp print_character__converted_character

    print_character__upper_table:
    sub a, $26
    jp print_character__converted_character
    print_character__lower_table:
    sub a, $27
    print_character__converted_character:

    ld hl, Tilemap
    
    ld d, 0
    ld e, b

    add hl, de

    push af
    ld a, c

    print_character__y_location_loop:

    or a
    jp z, print_character__finish_printing

    ld e, $20
    add hl, de

    dec a
    jp print_character__y_location_loop

    print_character__finish_printing:

    pop af

    ; Finish
    ld [hl], a

    pop hl

    ret

; Prints the string where HL points to. Expects a null terminated string.
; B -> X location, C -> Y Location
; Mutates: DE
print_string:

    ld a, [hli]
    or a
    ret z

    call print_character
    inc B

    jp print_string

; Prints the 16 unsigned bit integer. 
; DE -> integer to be printed. B -> X location(right adjusted: x + length), C -> Y location
print_u16:

    push bc
    call divide_u16_by_10
    ld d, b
    ld e, c
    pop bc
    
    add $30 ; convert to char

    push de
    call print_character
    pop de
    dec b

    ; check de == 0
    ld a, e
    cp $0
    jp nz, print_u16

    ld a, d
    cp $0
    jp nz, print_u16

    ret

    





    

