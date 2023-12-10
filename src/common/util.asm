
INCLUDE "./src/common/arithmetic.asm"
INCLUDE "./src/common/memory.asm"

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

; Pushes BC to wram stack.
push_u16:

    push hl 
    push af 
    
    ld a, [WorkStackSP]

    add a, $2
    ld hl, WorkStackSP
    ld [hl], a
    sub $2

    ld hl, WorkStack

    ; HL += a
    add l
    ld l, a
    ld a, h
    adc $0
    ld h, a

    ld a, c
    ld [hli], a
    ld a, b
    ld [hl], a

    pop af
    pop hl

    ret

; Poppes BC from the wram stack.
; Mutates: BC
pop_u16:

    push hl
    push af 

    ld a, [WorkStackSP]

    sub $2
    ld hl, WorkStackSP
    ld [hl], a

    ld hl, WorkStack

    ; HL += a
    add l
    ld l, a
    ld a, h
    adc $0
    ld h, a

    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a

    pop af
    pop hl

    ret

; Returns whether the work stack is empty.
; Z -> empty, NZ -> not empty
; Mutates: AF
is_stack_empty:

    ld a, [WorkStackSP]
    cp $0
    ret

; Clears the stack.
clear_stack:
    push af
    ld a, $0
    ld [WorkStackSP], a
    pop af
    ret

; A -> stack length
get_stack_length:
    ld a, [WorkStackSP]
    sra a
    ret

; Searches the stack for given value.
; Parameter: BC -> Value to be searched in stack.
; Effects: Z -> Element exists in stack, NZ -> No such element in stack.
; Mutates: AF
stack_contains:

    push hl
    push de
    
    ld hl, WorkStack
    ld d, $0

    stack_contains__loop:

    ld a, [WorkStackSP]
    cp d
    jp nz, stack_contains__loop_not_finished
    ; Z = 0
    ld a, $0
    add $1
    jp stack_contains__loop_end
    stack_contains__loop_not_finished:

    inc d
    inc d

    ld a, [hli]
    cp c
    jp z, stack_contains__loop_continue
    inc hl
    jp stack_contains__loop
    stack_contains__loop_continue:

    ld a, [hli]
    cp b
    jp nz, stack_contains__loop

    stack_contains__loop_end:

    pop de
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
;    Z -> a valid integer, NZ -> not a integer
; Mutates: BC, DE, AF
stoi_u16:

    ld bc, $0000 ;Result
    ld e, $00; Character count

    stoi_u16__loop:

    ld a, [hl]
    call is_digit
    jp nz, stoi_u16__loop_end

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
    stoi_u16__loop_end:

    ld a, e
    cp $0;
    jp z, stoi_u16__not_a_number
    ; Z = 1
    cp a
    ret
    stoi_u16__not_a_number:
    ; Z = 0
    ld a, $1
    add $0
    ret

