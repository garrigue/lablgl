# Main Makefile, to compile subdirectories

# default
INSTALLDIR = `ocamlc -where`/lablGL
DLLDIR = `ocamlc -where`/stublibs
CONFIG = Makefile.config
include $(CONFIG)

all: lib togl glut

opt: libopt toglopt glutopt

lib:
	cd src && $(MAKE) all

libopt:
	cd src && $(MAKE) opt

togl:
	cd Togl/src && $(MAKE) all

toglopt:
	cd Togl/src && $(MAKE) opt

glut:
	cd LablGlut/src && $(MAKE)

glutopt:
	cd LablGlut/src && $(MAKE) opt

install:
	@$(MAKE) real-install INSTALLDIR="$(INSTALLDIR)" DLLDIR="$(DLLDIR)

real-install:
	cd src && $(MAKE) install
	cd Togl/src && $(MAKE) install
	cd LablGlut/src && $(MAKE) install

clean:
	cd src && $(MAKE) clean
	cd Togl/src && $(MAKE) clean
	cd LablGlut/src && $(MAKE) clean
