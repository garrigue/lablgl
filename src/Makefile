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

include Makefile.config

# Composite options
INCLUDES = $(TKINCLUDES) $(GLINCLUDES) $(XINCLUDES)
LIBS = $(TKLIBS) $(GLLIBS) $(XLIBS)
LIBDIRS =


OCAMLINC=-I +labltk

# Files
LIBOBJS =	raw.cmo \
		gl.cmo		glLight.cmo	glList.cmo	glMap.cmo \
		glMat.cmo	glMisc.cmo	glPix.cmo	glClear.cmo \
		glTex.cmo	glDraw.cmo	glFunc.cmo	gluMisc.cmo \
		gluNurbs.cmo	gluQuadric.cmo	gluTess.cmo	gluMat.cmo
MLOBJS = $(LIBOBJS)	togl.cmo
OPTOBJS = $(LIBOBJS:.cmo=.cmx)
COBJS =		ml_gl$(XO)	ml_glu$(XO)	ml_raw$(XO)
TOGLOBJS =	ml_togl$(XO)	$(TOGLDIR)/togl$(XO)

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

.var.h:
	ocamlrun ./var2def < $< > $@

.cmx.opt: lablgl.cmxa
	$(OPTLINK) -o $@ $(OCAMLINC) -ccopt -L. \
	    unix.cmxa labltk.cmxa lablgl.cmxa togl.cmxa $<

all: 	var2def$(XE) var2switch$(XE) lablgltop$(XE) lablgl$(XB)

opt:	lablgl.cmxa togl.cmxa

var2def$(XE): var2def.ml
	$(LINKER) -pp camlp4o var2def.ml -o $@

var2switch$(XE): var2switch.ml
	$(LINKER) -pp camlp4o var2switch.ml -o $@

ifeq ($(TOOLCHAIN), msvc)
liblablgl$(XA): $(COBJS)
	$(MKLIB)$@ $(COBJS)
dlllablgl.dll: $(COBJS:.obj=.d.obj)
	$(MKDLL)$@ $(COBJS:.obj=.d.obj) $(GLLIBS)
lablgl.cma: liblablgl$(XA) dlllablgl.dll $(LIBOBJS) Makefile.config
	$(LINKER) -a -o $@ $(LIBOBJS) \
	  -cclib -llablgl -dllib -llablgl \
	  -cclib "$(GLLIBS)"
lablgl.cmxa: liblablgl$(XA) $(OPTOBJS) Makefile.config
	$(OPTLINK) -a -o $@ $(OPTOBJS) -cclib -llablgl \
	  -cclib "$(GLLIBS)"
libtogl$(XA): $(TOGLOBJS) Makefile.config
	$(MKLIB)$@ $(TOGLOBJS)
dlltogl.dll: $(TOGLOBJS:.obj=.d.obj)
	$(MKDLL)$@ $(TOGLOBJS:.obj=.d.obj) $(GLLIBS) $(TKLIBS)
togl.cma: libtogl$(XA) dlltogl.dll togl.cmo Makefile.config
	$(LINKER) -a -o $@ togl.cmo -cclib -ltogl -dllib -ltogl \
	  -cclib "$(GLLIBS) $(TKLIBS)"
togl.cmxa: libtogl$(XA) togl.cmx Makefile.config
	$(OPTLINK) -a -o $@ togl.cmx -cclib -ltogl \
	  -cclib "$(GLLIBS) $(TKLIBS)"
#CUSTOMTOP = -verbose -custom unix.cma
else
liblablgl.a: $(COBJS) Makefile.config
	$(LIBRARIAN) -o lablgl $(COBJS) $(GLLIBS) $(XLIBS)
lablgl.cma: liblablgl.a $(LIBOBJS) Makefile.config
	$(LIBRARIAN) -o lablgl $(LIBOBJS) $(GLLIBS) $(XLIBS)
lablgl.cmxa: liblablgl.a $(OPTOBJS) Makefile.config
	$(LIBRARIAN) -o lablgl $(OPTOBJS) $(GLLIBS) $(XLIBS)
libtogl.a: $(TOGLOBJS) Makefile.config
	$(LIBRARIAN) -o togl $(TOGLOBJS) $(GLLIBS) $(TKLIBS) $(XLIBS)
togl.cma: libtogl.a togl.cmo Makefile.config
	$(LIBRARIAN) -o togl togl.cmo $(GLLIBS) $(TKLIBS) $(XLIBS)
togl.cmxa: libtogl.a togl.cmx Makefile.config
	$(LIBRARIAN) -o togl togl.cmx $(GLLIBS) $(TKLIBS) $(XLIBS)
INSTTOP = lablgltop
endif

$(TOGLDIR)/togl.o:
	cd $(TOGLDIR) && $(MAKE) togl.o CC="$(CAMLC)" CFLAGS='-c -ccopt "$(COPTS) $(INCLUDES) $(TK_FLAGS)"'

$(TOGLDIR)/togl.obj:
	cd $(TOGLDIR) && \
        $(CAMLC) -c -ccopt "-DWIN32 $(COPTS) $(INCLUDES) -I." togl.c

$(TOGLDIR)/togl.d.obj:
	cd $(TOGLDIR) && \
        $(CAMLC) -c -ccopt "/MD /Fotogl.d.obj -DWIN32" \
		-ccopt "$(COPTS) $(INCLUDES) -I." \
		togl.c

lablgltop$(XE): lablgl.cma togl.cma
	ocamlmktop $(CUSTOMTOP) -I . $(OCAMLINC) -o $@ \
	  labltk.cma lablgl.cma togl.cma

lablgl: lablgl.in Makefile.config
	sed -e 's|@LABLTKDIR@|$(LABLTKDIR)|g'	\
	    -e 's|@INSTALLDIR@|'"$(INSTALLDIR)"'|g'	\
	    < lablgl.in > $@
	chmod 755 $@

gl_tags.c: gl_tags.var
	./var2switch -table GL_ < gl_tags.var > $@

tk_tags.c: tk_tags.var
	./var2switch TK_ < tk_tags.var > $@

togl_tags.c: togl_tags.var
	./var2switch TOGL_ < togl_tags.var > $@

glu_tags.c: glu_tags.var
	./var2switch GLU_ < glu_tags.var > $@

install:
	@$(MAKE) real-install LIBDIR="$(LIBDIR)"

real-install:
	if test -d "$(INSTALLDIR)"; then : ; else mkdir -p "$(INSTALLDIR)"; fi
	cp $(MLOBJS:.cmo=.cmi) "$(INSTALLDIR)"
	cp $(MLOBJS:.cmo=.mli) "$(INSTALLDIR)"
	cp liblablgl$(XA) lablgl.cma libtogl$(XA) togl.cma $(INSTTOP) "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) liblablgl$(XA) libtogl$(XA)
	cp lablgl$(XB) "$(BINDIR)"
	@if test -f dlllablgl$(XS); then $(MAKE) installdll; fi
	@if test -f lablgl.cmxa; then $(MAKE) installopt LIBDIR="$(LIBDIR)"; fi

installdll:
	cp dlllablgl$(XS) dlltogl$(XS) "$(DLLDIR)"

installopt:
	cp lablgl.cmxa lablgl$(XA) togl.cmxa togl$(XA) \
	   $(MLOBJS:.cmo=.cmx) "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) lablgl$(XA) togl$(XA)

clean:
	rm -f *.cm* *.a *.o *.lib *.obj *.exe *.opt *_tags.c *_tags.h *~ \
		var2def var2switch lablgltop lablgl lablgllink lablglopt
	rm -f $(TOGLDIR)/togl$(XO)

depend:
	ocamldep *.ml *.mli > .depend

#dependencies
ml_gl$(XO): ml_gl.h gl_tags.h gl_tags.c ml_raw.h
ml_tk$(XO): ml_gl.h tk_tags.h tk_tags.c
ml_aux$(XO): ml_gl.h
ml_togl$(XO) : ml_gl.h togl_tags.h togl_tags.c
ml_glu$(XO) : ml_gl.h glu_tags.h glu_tags.c
ml_raw$(XO): raw_tags.h ml_raw.h
include .depend
