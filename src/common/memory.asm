
IF DEF(InputText1)
; There is two rom banks.

increment_address:
    inc hl
    
    push af
    push bc
    ; BC = InputText0End
    push hl
    ld hl, InputText0End
    ld b, h
    ld c, l
    pop hl

    ; Change rom bank if HL >= BC
    ld a, h
    cp b
    jp c, increment_address__end

    ld a, l
    cp c
    jp c, increment_address__end

    ; Change rom bank
    ld hl,$2000
    ld [hl],$2
    ld hl, CurrentRomBank
    ld [hl], $2
    ld hl, InputText1

    increment_address__end:
    pop bc
    pop af
    ret

update_rom_bank:
    
    push af
    push bc    

    ld a, [CurrentRomBank]    
    cp $2
    jp z, update_rom_bank__on_second_bank

    ld bc, InputText0End

    ; Change rom bank if HL >= InputText0End
    ld a, h
    cp b
    jp c, update_rom_bank__end

    ld a, l
    cp c
    jp c, update_rom_bank__end


    ld bc, InputText0
    ; BC = HL - InputText0
    ld a, l
    sub c
    ld c, a
    ld a, h
    sbc b
    ld b, a

    ; Change rom bank
    ld hl,$2000
    ld [hl],$2
    ld hl, CurrentRomBank
    ld [hl], $2

    ; HL = BC
    ld h, b
    ld l, c

    jp update_rom_bank__end
    update_rom_bank__on_second_bank:

    ld bc, InputText1

    ; Change rom bank if HL < InputText1
    ld a, b
    cp h
    jp c, update_rom_bank__end
    jp z, update_rom_bank__on_second_bank_equal 
    jp nc, update_rom_bank__change_bank
    
    update_rom_bank__on_second_bank_equal:
    ; Equal
    ld a, c
    cp l
    jp c, update_rom_bank__end
    jp z, update_rom_bank__end

    update_rom_bank__change_bank:

    ld bc, InputText0

    ; BC = HL + BC
    add hl, bc
    
    ld b, h
    ld c, l

    ; Change rom bank
    ld hl,$2000
    ld [hl],$1
    ld hl, CurrentRomBank
    ld [hl], $1

    ld h, b
    ld l, c

    update_rom_bank__end:
    pop bc
    pop af
    
    ret

ELSE

increment_address:
    inc hl
    ret

ENDC