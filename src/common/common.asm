INCLUDE "./src/common/hardware.inc"

SECTION "Rom Variables", WRAM0
Tilemap: ds $240
TilemapEnd:
CurrentRomBank: ds $1
RomBankSP: ds $1
RomBankStack: ds $100

SECTION "Header", ROM0[$100]

	jp entry_point
	ds $150 - @, 0 ; Make room for the header

entry_point:
	; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

	ld [RomBankSP], a
	ld [CurrentRomBank], a

	call main

	; Do not turn the LCD off outside of VBlank
wait_vblank:
	ld a, [rLY]
	cp 144
	jp c, wait_vblank

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	; Copy the tile data
	ld de, Tiles
	ld hl, $9000
	ld bc, TilesEnd - Tiles
copy_tiles:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, copy_tiles

	; Copy the tilemap
	ld de, Tilemap
	ld hl, $9800
	ld bc, TilemapEnd - Tilemap
copy_tilemap:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, copy_tilemap

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON
	ld [rLCDC], a

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a

done:
	jp done 

SECTION "Tile data", ROM0

Tiles: INCBIN "./assets/text-font.2bpp"
TilesEnd:
