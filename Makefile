# Main Makefile, to compile subdirectories

# default
INSTALLDIR = `ocamlc -where`/lablGL
CONFIG = Makefile.config
include $(CONFIG)

all: lib togl glut

opt: libopt toglopt glutopt

lib:
	cd src && $(MAKE) lib

libopt:
	cd src && $(MAKE) libopt

togl:
	cd src && $(MAKE) togl

toglopt:
	cd src && $(MAKE) toglopt

glut:
	cd LablGlut/src && $(MAKE)

glutopt:
	cd LablGlut/src && $(MAKE) opt

install:
	cd src && $(MAKE) install INSTALLDIR="$(INSTALLDIR)"
	cd LablGlut/src && $(MAKE) install INSTALLDIR="$(INSTALLDIR)"

clean:
	cd src && $(MAKE) clean
	cd LablGlut/src && $(MAKE) clean
