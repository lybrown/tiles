Tiles
=====

Tiled Side-Scroller Demo using PAL Blending.

Screenshot
----------

[![tiles](https://github.com/lybrown/tiles/raw/master/screenshots/tiles-2012-11-11.png)](https://github.com/lybrown/tiles/blob/master/screenshots/tiles-2012-11-11.png)

Video
-----

* http://youtu.be/09K95RlE14k

Binaries
--------

* [tiles-pal.xex](https://github.com/lybrown/tiles/raw/master/binaries/tiles-pal.xex)
* [tiles-pal.atr](https://github.com/lybrown/tiles/raw/master/binaries/tiles-pal.atr)
* [tiles-ntsc.xex](https://github.com/lybrown/tiles/raw/master/binaries/tiles-ntsc.xex)
* [tiles-ntsc.atr](https://github.com/lybrown/tiles/raw/master/binaries/tiles-ntsc.atr)

Requirements
------------

* Atari 8-bit computer with 128K of memory
* Functions on 64K but displays garbage sprites

Interface
---------

* Joystick left and right for horizontal motion
* Joystick button or up for jump
* Select to toggle music
* Start to reload map
* Option to change tile luminance

Engine
------

* Changes three playfield colors every scan line
  * Pixels mix vertically in PAL for effectively square pixels at 16 colors
  * Less mixing in NTSC but still somewhat colorful
* No computation during raster
* 50fps or 60fps on PAL or NTSC
* Pared down display height on NTSC to make up for less vertical blank time
* Platforms and blockages
* Gravity
* X acceleration

Tiles
-----

* 4x4 Antic Mode 4 or effectively 16x16 pixels
* Effectively 16 colors
* 8 different tiles fit into Atari's 128 entry character set
* 4 [character sets](https://github.com/lybrown/tiles/raw/master/tileset.png) to animate coins
* 1K memory

Map
---

* 512x16 [tiles](https://github.com/lybrown/tiles/blob/master/screenshots/tiles-map.png)
* Created in Tiled Qt
* 3 layers: visual, blockages, under coins
* One byte per tile
  * 3 bits for tile
  * 3 bits for under coin tile
  * 1 bit for horizontal blockage
  * 1 bit for vertical blockage
* 8K memory

Sprites
-------

* 32x44 effective pixels
* All four players for monochrome foreground
* All four missiles for background mask
* Stored in extended memory
* No vertical movement
* 17 poses selected by PMBASE and PORTB
* 8 frames of run animation in left and right directions
* Idle pose
* 34K memory
* No enemies or projectiles

Screen
------

* Effectively 160x120 pixels at 16 colors
* 10x7.5 tiles
* 16 quarter tile slices along vertical edge are updated every frame in direction of x movement
* Takes advantage of Antic LMS wrap for continuous scrolling
* 1 full tile can be replaced per frame (coin -> background)
* Coin collision dectection alternates between lower and upper tile of hero every frame

Sound
-----

* Transcribed Ruff 'n' Tumble World 1 Theme in TMC2
* Trimmed player to use a little less vblank time
* Coin sound effects are TMC2 instruments played through tmc2play.asm API

Development
-----------

* ["The Matrix"](https://github.com/lybrown/tiles/blob/master/screenshots/screenshot-matrix-2012-11-03.png)
  * Bug in edge renderer
* [Psychadelic](https://github.com/lybrown/tiles/blob/master/screenshots/psychadelic-2-2012-11-09.png)
  * This happens if you disable the color register swapping every scan line.

Thanks
------

* Ruff 'n' Tumble
  * http://en.wikipedia.org/wiki/Ruff_'n'_Tumble
  * http://www.youtube.com/watch?v=FfBFxvelfVM#t=145s
* flashjazzcat, popmilo, XL-Paint Max, et. al. for PAL Blending
  * http://www.atariage.com/forums/topic/197450-mode-15-pal-blending/
* Rybags for full-screen VSCROL technique and high HSCROL lighter DMA technique
  * http://www.atariage.com/forums/topic/154718-new-years-disc-2010/page__st__50#entry1911485
  * http://www.atariage.com/forums/topic/197450-mode-15-pal-blending/page__st__100#entry2637036
* phaeron for Altirra and VirtualDub
  * http://www.virtualdub.org/altirra.html
* fox for xasm
  * http://atariarea.krap.pl/x-asm/
* jaskier for TMC2
  * http://jaskier.atari8.info/
* AtariAge Forums
  * http://www.atariage.com/forums/forum/12-atari-8-bit-computers/
* Tiled Qt
  * http://www.mapeditor.org/
* ImageMagick
  * http://www.imagemagick.org/script/index.php
