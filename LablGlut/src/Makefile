# Include shared parts
TOPDIR = ../..
include $(TOPDIR)/Makefile.common
include $(CONFIG)

# Composite options
INCLUDES = $(GLINCLUDES) $(XINCLUDES)
LIBS = $(GLUTLIBS) $(GLLIBS) $(XLIBS)
LIBDIRS =

OCAMLINC=

# Files
LIBOBJS = glut.cmo
OPTOBJS = $(LIBOBJS:.cmo=.cmx)
COBJS =	  wrap_gl$(XO)	wrap_glut$(XO)

all: 	lib lablgluttop$(XE) lablglut$(XB)

opt:	libopt

lib:	lablglut.cma

libopt: lablglut.cmxa

ifeq ($(TOOLCHAIN), msvc)
liblablglut$(XA): $(COBJS)
	$(MKLIB)$@ $(COBJS)
dlllablglut.dll: $(COBJS:.obj=.d.obj)
	$(MKDLL)$@ $(COBJS:.obj=.d.obj) $(GLUTLIBS) $(GLLIBS)
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
	ocamlmktop $(CUSTOMTOP) -I . -I ../.. $(OCAMLINC) -o $@ \
	  lablglut.cma ../../src/lablgl.cma

lablglut$(XB): lablglut.in ../../Makefile.config
	sed -e 's|@LABLTKDIR@|$(LABLTKDIR)|g'	\
	    -e 's|@INSTALLDIR@|'"$(INSTALLDIR)"'|g'	\
	    < lablglut.in > $@
	chmod 755 $@

install:
	@if test -f lablglut.cma; then $(MAKE) real-install; fi

real-install: 
	if test -d "$(INSTALLDIR)"; then : ; else mkdir -p "$(INSTALLDIR)"; fi
	cp $(LIBOBJS:.cmo=.cmi) "$(INSTALLDIR)"
	cp $(LIBOBJS:.cmo=.mli) "$(INSTALLDIR)"
	cp liblablglut$(XA) lablglut.cma "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) liblablglut$(XA)
	@if test -f dlllablglut$(XS); then cp dlllablglut$(XS) "$(DLLDIR)"; fi
	@if test -f lablglut.cmxa; then $(MAKE) installopt; fi


installdll:
	cp dlllablglut$(XS) "$(DLLDIR)"

installopt:
	cp lablglut.cmxa lablglut$(XA) $(LIBOBJS:.cmo=.cmx) "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) lablglut$(XA)

installtop:
	cp lablgluttop$(EX) "$(INSTALLDIR)" 
	cp lablglut$(XB) "$(BINDIR)"

clean:
	rm -f *.cm* *.a *.o *.so *.lib *.obj *.exe *.opt *_tags.c *_tags.h *~ \
	     lablgluttop$(EX) lablglut$(XB) 

depend:
	ocamldep  -pp camlp4o *.ml *.mli > .depend

include .depend
