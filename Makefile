
all: 
# Iterate all images under assets folder and convert them to Gameboy tiles.
	$(foreach file, $(basename $(notdir $(wildcard ./assets/*.png))), \
		rgbgfx -c '#ffffff,#8d05de, #dc7905,#000000; #fff,#8d05de, #7e0000 , #000' -o ./assets/$(file).2bpp ./assets/$(file).png;)

	$(foreach file, $(wildcard ./src/*/day*),\
		rgbasm -L -o ./build/$(basename $(notdir $(file))).o $(file);\
		rgblink -o ./build/$(basename $(notdir $(file))).gb ./build/$(basename $(notdir $(file))).o;\
		rgbfix -m 0x1 -n 0x1 -v -p 0xFF -t $(basename $(notdir $(file))) ./build/$(basename $(notdir $(file))).gb;)

	../gameboy/target/release/gameboy ./build/day2b.gb
