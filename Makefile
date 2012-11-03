# $Id: Makefile 36 2008-06-29 23:46:07Z lybrown $

tiles.run:
tiles.obx: assets.asm tmc2play.asm sprites.asm
assets.asm: tiles.json pal.ppm tileset.png json2am
	./json2am $^ > $@
sprites.asm: sprites.png sprites
	./sprites $< > $@

atari = /c/Documents\ and\ Settings/lybrown/Documents/Altirra.exe

%.png: %-fullcolor.png
	convert +dither -compress none $< -remap pal.ppm $@

%.run: %.xex
	$(atari) $<

%.xex: %.obx
	cp $< $@

%.asm.pl: %.asm.pp
	perl -pe 's/^\s*>>>// or s/(.*)/print <<'\''EOF'\'';\n$$1\nEOF/' $< > $@

%.asm: %.asm.pl
	perl $< > $@
	
%.obx: %.asm
	xasm /l /d:pwm=$(if $(findstring audf,$(audext)),1,0) $<

%.dfl: %.bin gzip2deflate
	#7z a -tgzip -mx=9 -so dummy $< | ./gzip2deflate >$@
	gzip -c -9 $< | ./gzip2deflate >$@

gzip2deflate: gzip2deflate.c
	gcc -o $@ $<

clean:
	rm -f *.{obx,atr,lst} *.{tmc,tm2,pgm,wav}.asm *~

.PRECIOUS: %.xex %.ppm %.asm %.asm.pl
