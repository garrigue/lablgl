# Include shared parts
TOPDIR = ../..
include $(TOPDIR)/Makefile.common

# Composite options
INCLUDES = $(GLINCLUDES) $(XINCLUDES) -I$(SRCDIR)
LIBS = $(GLUTLIBS) $(GLLIBS) $(XLIBS)
LIBDIRS =

OCAMLINC=

# Files
LIBOBJS = glut.cmo glut2.cmo
OPTOBJS = $(LIBOBJS:.cmo=.cmx)
COBJS =	  wrap_gl$(XO)	wrap_glut$(XO)

all: 	lib lablgluttop$(XE) lablglut$(XB)

opt:	libopt

lib:	lablglut.cma

libopt: lablglut.cmxa

ifeq ($(TOOLCHAIN), msvc)
liblablglut$(XA): $(COBJS)
	$(MKLIB)$@ $(COBJS)
dlllablglut.dll: $(COBJS:$(XO)=.d$(XO))
	$(MKDLL)$@ $(COBJS:$(XO)=.d$(XO)) $(GLUTLIBS) $(GLLIBS) $(OCAMLDLL)
lablglut.cma: liblablglut$(XA) dlllablglut.dll $(LIBOBJS) ../../Makefile.config
	$(LINKER) -a -o $@ $(LIBOBJS) \
	  -cclib -llablglut -dllib -llablglut \
	  -cclib "$(GLLIBS)" -cclib "$(GLUTLIBS)"
lablglut.cmxa: liblablglut$(XA) $(OPTOBJS) ../../Makefile.config
	$(OPTLINK) -a -o $@ $(OPTOBJS) -cclib -llablglut \
	  -cclib "$(GLLIBS)" -cclib "$(GLUTLIBS)"
else
liblablglut.a: $(COBJS) ../../Makefile.config
	$(LIBRARIAN) -o lablglut $(COBJS) $(GLUTLIBS) $(GLLIBS) $(XLIBS)
lablglut.cma: liblablglut.a $(LIBOBJS) ../../Makefile.config
	$(LIBRARIAN) -o lablglut $(LIBOBJS) $(GLUTLIBS) $(GLLIBS) $(XLIBS)
lablglut.cmxa: liblablglut.a $(OPTOBJS) ../../Makefile.config
	$(LIBRARIAN) -o lablglut $(OPTOBJS) $(GLUTLIBS) $(GLLIBS) $(XLIBS)
endif

lablgluttop$(XE): lablglut.cma 
	ocamlmktop $(CUSTOMTOP) -I . -I $(SRCDIR) $(OCAMLINC) -o $@ \
	  lablglut.cma lablgl.cma

lablglut: $(CONFIG) Makefile liblablglut$(XA)
	$(MAKE) INSTALLDIR="$(INSTALLDIR)" real-$@

real-lablglut:
	@echo generate lablglut
	echo "#!/bin/sh" > lablglut
	echo "# toplevel with lablGL and LablGlut" >> lablglut
	if test -f dlllablglut$(XS); then \
	    echo 'exec ocaml -I "$(INSTALLDIR)" lablgl.cma lablglut.cma $$*' >> lablglut; \
	 else echo 'exec "$(INSTALLDIR)/lablgluttop" -I "$(INSTALLDIR)" $$*' >> lablglut; fi
	chmod 755 lablglut

install:
	@if test -f lablglut.cma; then $(MAKE) real-install; fi

real-install: 
	if test -d "$(INSTALLDIR)"; then : ; else mkdir -p "$(INSTALLDIR)"; fi
	cp $(LIBOBJS:.cmo=.cmi) "$(INSTALLDIR)"
	cp $(LIBOBJS:.cmo=.mli) "$(INSTALLDIR)"
	cp liblablglut$(XA) lablglut.cma "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) liblablglut$(XA)
	@if test -f dlllablglut$(XS); then $(MAKE) installdll; \
	 else $(MAKE) installtop; fi
	cp lablglut$(XB) "$(BINDIR)"
	@if test -f lablglut.cmxa; then $(MAKE) installopt; fi

installdll:
	cp dlllablglut$(XS) "$(DLLDIR)"

installtop:
	cp lablgluttop$(XE) "$(INSTALLDIR)"

installopt:
	cp lablglut.cmxa lablglut$(XA) $(LIBOBJS:.cmo=.cmx) "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) lablglut$(XA)

clean:
	rm -f *.cm* *.o *.obj *.a *.lib *.so *.dll *.exe *.opt \
	     *_tags.c *_tags.h *~ lablgluttop$(EX) lablglut

depend:
	ocamldep  -pp camlp4o *.ml *.mli > .depend

include .depend
