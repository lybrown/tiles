# $Id: Makefile 36 2008-06-29 23:46:07Z lybrown $

tiles.run:
tiles.obx: assets.asm
assets.asm: foo.json pal.ppm foo.png json2am
	./json2am $^ > $@

atari = /c/Documents\ and\ Settings/lybrown/Documents/Altirra.exe

%.ppm: orig/%.png
	convert +dither -compress none $< -remap pal.ppm $@

%.run: %.xex
	$(atari) $<

%.xex: %.obx
	cp $< $@

%.asm.pl: %.asm.pp
	perl -pe 's/^\s*>>>// or s/(.*)/print <<\\EOF;\n$$1\nEOF/' $< > $@

%.asm: %.asm.pl
	perl $< > $@
	
%.obx: %.asm
	xasm /l /d:pwm=$(if $(findstring audf,$(audext)),1,0) $<

clean:
	rm -f *.{obx,atr,lst} *.{tmc,tm2,pgm,wav}.asm *~

.PRECIOUS: %.obx %.xex %.ppm %.asm