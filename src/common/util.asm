
INCLUDE "./src/common/arithmetic.asm"

; Checks if given 8 bit value is a ascii digit or not.
; Must be in range of [$30, $39]
; Parameter: A -> character to be checked
; Effects: Z -> digit, NZ -> not digit
; Mutates: A, F
is_digit:
    cp $30  
    jp c, is_digit__not_digit
    cp $3A
    jp nc, is_digit__not_digit
    jp z, is_digit__not_digit

    ;It is a digit
    cp a ;Z = 1
    ret 
    is_digit__not_digit:

    ld a, $1
    cp $2 ;Z = 0
    ret

push_rom_bank:

    push hl 
    push af 
    
    ld a, [RomBankSP]

    add $1
    ld hl, RomBankSP
    ld [hl], a
    sub $1

    ld hl, RomBankStack

    ; HL += a
    add l
    ld l, a
    ld a, h
    adc $0
    ld h, a

    ld a, [CurrentRomBank]
    ld [hl], a

    pop af
    pop hl

    ret

pop_rom_bank:

    push hl
    push af 

    ld a, [RomBankSP]

    sub $1
    ld hl, RomBankSP
    ld [hl], a

    ld hl, RomBankStack

    ; HL += a
    add l
    ld l, a
    ld a, h
    adc $0
    ld h, a

    push bc

    ld a, [CurrentRomBank]
    ld b, a; Current value

    ld a, [hl]; New value
    ld hl, CurrentRomBank 
    
    ld [hl], a

    cp b
    jp z, pop_rom_bank__no_bank_change

    ld hl, $2000
    ld [hl], a; Change rom bank

    pop_rom_bank__no_bank_change:

    pop bc

    pop af
    pop hl

    ret

; Does a memory compare in given address.
; Parameter: HL (In rom) -> lhs address, DE(Not in rom) -> rhs address, C -> length in bytes
; Effects: Z -> equal, NZ -> not equal
; Mutates HL, DE, AF, BC
memcmp: 

    call push_rom_bank

    memcmp__loop:

    ; Check C
    ld a, c
    cp $0
    jp z, memcmp__end; C = 0, Z = 1
    dec c ; Decrement c

    ld a, [hl]
    
    call increment_address

    push hl
    ld h, d
    ld l, e

    push af
    ld a, [hl]

    inc hl
    
    ld b, a
    pop af

    ; Revert hl
    ld d, h
    ld e, l

    pop hl

    cp b ;compare bytes
    jp z, memcmp__loop
    ; Mem not equal
    ld a, 0
    cp $1
    ;Z = 0
    memcmp__end:
    call pop_rom_bank
    ret
    
; Advances HL until parameter B encountered.
; Effects: HL (In rom) -> address right after finding B.
; Mutates: AF
advance_until:

    advance_until__loop:
    ld a, [hl]
    call increment_address
    cp b
    jp nz, advance_until__loop
    ret

; Converts the string in the address HL to a integer.
; Effects: 
;    HL (In rom) -> address right after the integer, 
;    BC -> integer representation of the given string.
;    E -> character count of the string.
; Mutates: BC, DE, AF
stoi_u16:

    ld bc, $0000 ;Result
    ld e, $00; Character count

    stoi_u16__loop:

    ld a, [hl]
    call is_digit
    ret nz

    inc e

    call increment_address
    
    ; Convert to integer.
    sub $30

    push de
    ; BC = BC * 10
    push af
    ld de, $a
    push hl
    call mutliply_u16
    ld b, h
    ld c, l

    pop hl
    pop af
    pop de

    ; BC = BC + A
    add c
    ld c, a
    ld a, b
    adc $0
    ld b, a  

    jp stoi_u16__loop

