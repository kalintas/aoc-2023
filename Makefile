
include .env

TARGET=day1a

.PHONY: generate_assets build run all
.PHONY: build run

generate_assets:
# Iterate all images under assets folder and convert them to Gameboy tiles.
	$(foreach file, $(basename $(notdir $(wildcard ./assets/*.png))), \
		rgbgfx -c '#ffffff,#8d05de, #dc7905,#000000; #fff,#8d05de, #7e0000 , #000' -o ./assets/$(file).2bpp ./assets/$(file).png;)

# Iterate all days and fetch required inputs.
# A rom bank is at most 16KB so split the inputs.

	$(foreach file, $(wildcard ./src/day*),\
	day_count=$$(basename ${file} | sed 's/day//');\
	curl -A "github.com/kalintas/aoc-2023 by keremkalinntas@gmail.com" -o ./assets/inputs/$${day_count}.txt "https://adventofcode.com/2023/day/$${day_count}/input" --cookie "session=${SESSION}";\
	split -a 1 -x -b 16K ./assets/inputs/$${day_count}.txt ./src/day$${day_count}/input --additional-suffix=.txt;)

clean:
# Clean generated assets and objects.
	rm -rf ./assets/*.2bpp
	rm -rf ./src/day*/input*
	rm -rf ./build/*

build:
	$(foreach file, $(wildcard ./src/*/day*),\
	rgbasm -L -o ./build/$(basename $(notdir $(file))).o $(file);\
	rgblink -o ./build/$(basename $(notdir $(file))).gb ./build/$(basename $(notdir $(file))).o;\
	rgbfix -m 0x1 -n 0x1 -v -p 0xFF -t $(basename $(notdir $(file))) ./build/$(basename $(notdir $(file))).gb;)

run: build
	../gameboy/target/release/gameboy ./build/${TARGET}.gb

all: generate_assets build run

.DEFAULT_GOAL := build