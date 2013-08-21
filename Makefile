SRC=*/*.ls
LSC=lsc
BUNDLE=browserify -x prelude-ls

all:
	$(LSC) -c $(SRC)
	$(BUNDLE) sp/mines.js -o sp/sp.js

watch:
	pywatch "make" */*.ls
