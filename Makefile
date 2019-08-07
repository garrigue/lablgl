# Main Makefile, to compile subdirectories

# default
TOPDIR = .
include Makefile.common

all: lib togl glut

opt: libopt toglopt glutopt

lib:
	cd src && $(MAKE) all LIBDIR="$(LIBDIR)"

libopt:
	cd src && $(MAKE) opt

togl: lib
	cd Togl/src && $(MAKE) LABLTKDIR="$(LABLTKDIR)" all

toglopt: libopt
	cd Togl/src && $(MAKE) LABLTKDIR="$(LABLTKDIR)" opt

glut: lib
	cd LablGlut/src && $(MAKE)

glutopt: libopt
	cd LablGlut/src && $(MAKE) opt

preinstall:
	cd src && $(MAKE) preinstall INSTALLDIR="$(INSTALLDIR)" DLLDIR="$(DLLDIR)"
	cd Togl/src && $(MAKE) preinstall INSTALLDIR="$(INSTALLDIR)" DLLDIR="$(DLLDIR)"
	cd LablGlut/src && $(MAKE) preinstall INSTALLDIR="$(INSTALLDIR)" DLLDIR="$(DLLDIR)"

install:
	@$(MAKE) real-install INSTALLDIR="$(INSTALLDIR)" DLLDIR="$(DLLDIR)"

real-install:
	cd src && $(MAKE) install
	cd Togl/src && $(MAKE) install
	cd LablGlut/src && $(MAKE) install

clean:
	cd src && $(MAKE) clean
	cd Togl/src && $(MAKE) clean
	cd LablGlut/src && $(MAKE) clean
