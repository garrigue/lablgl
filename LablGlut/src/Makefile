# Ocaml commands
CAMLC=ocamlc
CAMLOPT=ocamlopt
COMPILER=$(CAMLC) -c -w s
OPTCOMP=$(CAMLOPT) -c
LIBRARIAN=ocamlmklib
OPTLIB=$(CAMLOPT) -a
LINKER=$(CAMLC)
OPTLINK=$(CAMLOPT)
# Default settings
LIBDIR = `$(CAMLC) -where`
DLLDIR = $(LIBDIR)/stublibs
INSTALLDIR = $(LIBDIR)/lablGL
TOGLDIR = Togl
COPTS = -c -O
# Default toolchain (unix)
TOOLCHAIN = unix
XA = .a
XB =
XE =
XO = .o
XS = .so
# Windows specific
MKLIB=lib /nologo /debugtype:CV /out:
MKDLL=link /nologo /dll "$(LIBDIR)/ocamlrun.lib" /out:

include ../../Makefile.config

# Composite options
INCLUDES = $(GLINCLUDES) $(XINCLUDES)
LIBS = $(GLUTLIBS) $(GLLIBS) $(XLIBS)
LIBDIRS =


OCAMLINC=

# Files
LIBOBJS =	glut.cmo
OPTOBJS = $(LIBOBJS:.cmo=.cmx)
COBJS =		wrap_gl$(XO)	wrap_glut$(XO)

# Default rules
.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .var .h .opt $(XA) $(XO) $(XE) .d.obj

.ml.cmo:
	$(COMPILER) $(OCAMLINC) $<

.ml.cmx:
	$(OPTCOMP) $(OCAMLINC) $<

.mli.cmi:
	$(COMPILER) $(OCAMLINC) $<

.c$(XO):
	$(COMPILER) -ccopt "$(COPTS) $(INCLUDES) -I$(TOGLDIR)" $<

.c.d.obj:
	$(COMPILER) -verbose -ccopt "/MD /Fo$@ $(INCLUDES) -I $(TOGLDIR)" $<


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
#CUSTOMTOP = -verbose -custom unix.cma
else
liblablglut.a: $(COBJS) ../../Makefile.config
	$(LIBRARIAN) -o lablglut $(COBJS) $(GLUTLIBS) $(GLLIBS) $(XLIBS)
lablglut.cma: liblablglut.a $(LIBOBJS) ../../Makefile.config
	$(LIBRARIAN) -o lablglut $(LIBOBJS) $(GLUTLIBS) $(GLLIBS) $(XLIBS)
lablglut.cmxa: liblablglut.a $(OPTOBJS) ../../Makefile.config
	$(LIBRARIAN) -o lablglut $(OPTOBJS) $(GLUTLIBS) $(GLLIBS) $(XLIBS)
INSTTOP = lablgltop
endif

lablgluttop$(XE): lablglut.cma 
	ocamlmktop $(CUSTOMTOP) -I . -I ../.. $(OCAMLINC) -o $@ \
	  lablglut.cma ../../src/lablgl.cma

lablglut$(XB): lablglut.in ../../Makefile.config
	sed -e 's|@LABLTKDIR@|$(LABLTKDIR)|g'	\
	    -e 's|@INSTALLDIR@|'"$(INSTALLDIR)"'|g'	\
	    < lablglut.in > $@
	chmod 755 $@

install libinstall: real-install installtop

real-install: 
	if test -d "$(INSTALLDIR)"; then : ; else mkdir -p "$(INSTALLDIR)"; fi
	cp $(LIBOBJS:.cmo=.cmi) "$(INSTALLDIR)"
	cp $(LIBOBJS:.cmo=.mli) "$(INSTALLDIR)"
	cp liblablglut$(XA) lablglut.cma "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) liblablglut$(XA)
	@if test -f dlllablglut$(XS); then cp dlllablglut$(XS) "$(DLLDIR)"; fi
	@if test -f lablglut.cmxa; then $(MAKE) libinstallopt LIBDIR="$(LIBDIR)"; fi


installdll:
	cp dlllablglut$(XS) "$(DLLDIR)"

libinstallopt:
	cp lablglut.cmxa lablglut$(XA) $(LIBOBJS:.cmo=.cmx) "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) lablglut$(XA)

installopt:
	cp lablglut.cmxa lablglut$(XA) \
	   $(MLOBJS:.cmo=.cmx) "$(INSTALLDIR)"
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
