# Ocaml commands
CAMLC=ocamlc
CAMLOPT=ocamlopt
COMPILER=$(CAMLC) -c
OPTCOMP=$(CAMLOPT) -c
LIBRARIAN=ocamlmklib
OPTLIB=$(CAMLOPT) -a
LINKER=$(CAMLC)
OPTLINK=$(CAMLOPT)

include Makefile.config

OCAMLINC=-I $(LABLTKDIR)

# Files
LIBOBJS =	raw.cmo \
		gl.cmo		glLight.cmo	glList.cmo	glMap.cmo \
		glMat.cmo	glMisc.cmo	glPix.cmo	glClear.cmo \
		glTex.cmo	glDraw.cmo	glFunc.cmo	gluMisc.cmo \
		gluNurbs.cmo	gluQuadric.cmo	gluTess.cmo	gluMat.cmo
MLOBJS = $(LIBOBJS)	togl.cmo
OPTOBJS = $(MLOBJS:.cmo=.cmx)
COBJS =		ml_gl.o		ml_glu.o	ml_raw.o
TOGLOBJS =	ml_togl.o	$(TOGLDIR)/togl.o

# Default rules
.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o .var .h .opt

.ml.cmo:
	$(COMPILER) $(OCAMLINC) $<

.ml.cmx:
	$(OPTCOMP) $(OCAMLINC) $<

.mli.cmi:
	$(COMPILER) $(OCAMLINC) $<

.c.o:
	$(COMPILER) -ccopt "$(COPTS) -I$(TOGLDIR) $(INCLUDES)" $<

.var.h:
	./var2def < $< > $@

.cmx.opt: lablgl.cmxa liblablgl.a
	$(OPTLINK) -o $@ $(OCAMLINC) -ccopt -L. \
	    unix.cmxa labltk.cmxa lablgl.cmxa togl.cmxa $<

all: 	var2def	var2switch lablgltop lablgl

opt:	lablgl.cmxa togl.cmxa

var2def: var2def.ml
	$(LINKER) -pp camlp4o var2def.ml -o $@

var2switch: var2switch.ml
	$(LINKER) -pp camlp4o var2switch.ml -o $@

lablgl.cma: $(LIBOBJS) $(COBJS) Makefile.config
	$(LIBRARIAN) -o lablgl $(LIBOBJS) $(COBJS) $(GLLIBS) $(XLIBS)

lablgl.cmxa: lablgl.cma $(OPTOBJS) Makefile.config
	$(LIBRARIAN) -o lablgl $(OPTOBJS)

togl.cma: togl.cmo $(TOGLOBJS) Makefile.config
	$(LIBRARIAN) -o togl togl.cmo $(TOGLOBJS) $(GLLIBS) $(TKLIBS) $(XLIBS)

togl.cmxa: togl.cma togl.cmx Makefile.config
	$(LIBRARIAN) -o togl togl.cmx

#liblablgl.a: $(COBJS)
#	ar rc liblablgl.a $(COBJS)
#	$(RANLIB) liblablgl.a

$(TOGLDIR)/togl.o:
	cd $(TOGLDIR) && $(MAKE) togl.o CC="$(CAMLC)" CFLAGS='-c -ccopt "$(COPTS) $(INCLUDES) $(TK_FLAGS)"'

lablgltop: lablgl.cma togl.cma
	ocamlmktop -I . $(OCAMLINC) -o lablgltop \
	    -dllpath $(LABLTKDIR) -dllpath $(INSTALLDIR) \
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
	@$(MAKE) real-install LIBDIR=$(LIBDIR)

real-install:
	if test -d $(INSTALLDIR); then : ; else mkdir -p $(INSTALLDIR); fi
	if test `grep -s -c '^$(INSTALLDIR)$$' $(LIBDIR)/ld.conf || :` = 0; \
	then echo $(INSTALLDIR) >> $(LIBDIR)/ld.conf; fi
	cp $(MLOBJS:.cmo=.cmi) $(INSTALLDIR)
	cp $(MLOBJS:.cmo=.mli) $(INSTALLDIR)
	cp liblablgl.a lablgl.cma togl.cma $(INSTALLDIR)
	cp lablgltop $(INSTALLDIR)
	cp lablgl $(BINDIR)
	@if test -f liblablgl.so; then $(MAKE) installdll; fi
	@if test -f lablgl.cmxa; then $(MAKE) installopt LIBDIR=$(LIBDIR); fi

installdll:
	cp liblablgl.so libtogl.so $(INSTALLDIR)

installopt:
	cp lablgl.cmxa lablgl.a togl.cmxa togl.a $(MLOBJS:.cmo=.cmx) $(INSTALLDIR)

clean:
	rm -f *.cm* *.a *.o *.opt *_tags.c *_tags.h *~ \
		var2def var2switch lablgltop lablgl lablgllink lablglopt
	cd $(TOGLDIR) && $(MAKE) clean

depend:
	ocamldep *.ml *.mli > .depend

#dependencies
ml_gl.o: ml_gl.h gl_tags.h gl_tags.c ml_raw.h
ml_tk.o: ml_gl.h tk_tags.h tk_tags.c
ml_aux.o: ml_gl.h
ml_togl.o : ml_gl.h togl_tags.h togl_tags.c
ml_glu.o : ml_gl.h glu_tags.h glu_tags.c
ml_raw.o: raw_tags.h ml_raw.h
include .depend
