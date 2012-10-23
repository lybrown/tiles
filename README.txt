10700  convert.exe +dither ~/Downloads/ruff-tiles.png -remap pal.ppm foo.png
10701  convert.exe ~/Downloads/ruff-tiles.png -remap pal.ppm foo.png
10702  \cp  ~/Downloads/ruff-tiles.png foo.png
10704  grep data foo.json | perl -ne '$x{$_}++for/(\d+)/g; END{use Data::Dumper; print Dumper \%x}'
