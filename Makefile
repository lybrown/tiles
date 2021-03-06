# $Id: Makefile 36 2008-06-29 23:46:07Z lybrown $

tiles.run:
diskloader.boot:
tiles.obx: assets.asm tmc2play.asm sprites.asm
diskloader.obx: tiles.xex
assets.asm: tiles.json pal.ppm tileset.png json2am
	./json2am $^ > $@
sprites.asm: sprites.png sprites
	./sprites $< > $@

ntsc := 0
atari = /c/Documents\ and\ Settings/lybrown/Documents/Altirra.exe

%.png: %-fullcolor.png
	convert +dither -compress none $< -remap pal.ppm $@

%.run: %.xex
	$(atari) $<

%.boot: %.atr
	$(atari) $<

%.xex: %.obx
	cp $< $@

%.asm.pl: %.asm.pp
	perl -pe 's/^\s*>>>// or s/(.*)/print <<'\''EOF'\'';\n$$1\nEOF/' $< > $@

%.asm: %.asm.pl
	perl $< > $@
	
%.obx: %.asm
	xasm /l /d:ntsc=$(ntsc) $<

%.dfl: %.bin gzip2deflate
	#7z a -tgzip -mx=9 -so dummy $< | ./gzip2deflate >$@
	gzip -c -9 $< | ./gzip2deflate >$@

%.atr: %.obx obx2atr
	./obx2atr $< > $@

gzip2deflate: gzip2deflate.c
	gcc -o $@ $<

bin:
	make ntsc=0 diskloader.atr -W tiles.asm.pp
	mv tiles.xex binaries/tiles-pal.xex
	mv diskloader.atr binaries/tiles-pal.atr
	rm tiles.obx
	make ntsc=1 diskloader.atr -W tiles.asm.pp
	mv tiles.xex binaries/tiles-ntsc.xex
	mv diskloader.atr binaries/tiles-ntsc.atr

clean:
	rm -f *.{obx,atr,lst} *.{tmc,tm2,pgm,wav}.asm *~

.PRECIOUS: %.xex %.ppm %.asm %.asm.pl %.atr
