# Ocaml commands
COMPILER=ocamlc -c -modern
OPTCOMP=ocamlopt -c -modern
LIBRARIAN=ocamlc -a
OPTLIB=ocamlopt -a
LINKER=ocamlc
OPTLINK=ocamlopt

include Makefile.config

OCAMLINC=-I $(LABLTKDIR)
OTHERLIBS=-L$(LABLTKDIR) -llabltk41 $(LIBS)

# Files
LIBOBJS =	raw.cmo \
		gl.cmo		glLight.cmo	glList.cmo	glMap.cmo \
		glMat.cmo	glMisc.cmo	glPix.cmo	glClear.cmo \
		glTex.cmo	glDraw.cmo	glFunc.cmo	gluMisc.cmo \
		gluNurbs.cmo	gluQuadric.cmo	gluTess.cmo	gluMat.cmo
MLOBJS = $(LIBOBJS)	togl.cmo
OPTOBJS = $(MLOBJS:.cmo=.cmx)
COBJS =		ml_gl.o		ml_glu.o	ml_togl.o	ml_raw.o \
		$(TOGLDIR)/togl.o

# Default rules
.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o .var .h .opt

.ml.cmo:
	$(COMPILER) $(OCAMLINC) $<

.ml.cmx:
	$(OPTCOMP) $(OCAMLINC) $<

.mli.cmi:
	$(COMPILER) $(OCAMLINC) $<

.c.o:
	$(COMPILER) -ccopt "-I$(TOGLDIR) $(INCLUDES)" $<

.var.h:
	var2def < $< > $@

.cmx.opt: lablgl.cmxa liblablgl.a
	$(OPTLINK) -o $@ $(OCAMLINC) unix.cmxa tk41.cmxa lablgl.cmxa $< \
		-cclib "-L. -llablgl -lunix $(OTHERLIBS)"

all: 	var2def	var2switch lablgltop lablgl lablgllink

opt:	lablgl.cmxa lablglopt

var2def: var2def.cmo
	$(LINKER) var2def.cmo -o $@

var2switch: var2switch.cmo
	$(LINKER) var2switch.cmo -o $@

lablgl.cma: $(LIBOBJS)
	$(LIBRARIAN) -o lablgl.cma $(LIBOBJS)

lablgl.cmxa: $(OPTOBJS)
	$(OPTLIB) -o lablgl.cmxa $(OPTOBJS)

liblablgl.a: $(COBJS)
	ar rc liblablgl.a $(COBJS)
	$(RANLIB) liblablgl.a

$(TOGLDIR)/togl.o:
	cd $(TOGLDIR) && $(MAKE) togl.o

lablgltop: lablgl.cma togl.cmo liblablgl.a
	ocamlmktop $(OCAMLINC) -custom -o lablgltop \
		unix.cma tk41.cma lablgl.cma togl.cmo \
		-cclib "-L. -llablgl -lunix $(OTHERLIBS)"

lablgl: lablgl.in Makefile.config
	sed -e 's|@LABLTKDIR@|$(LABLTKDIR)|g'	\
	    -e 's|@INSTALLDIR@|$(INSTALLDIR)|g'	\
	    < lablgl.in > $@
	chmod 755 $@

lablgllink: lablgllink.in Makefile.config
	sed -e 's|@INCLUDES@|$(OCAMLINC)|g'	\
	    -e 's|@INSTALLDIR@|$(INSTALLDIR)|g' \
	    -e 's|@OTHERLIBS@|$(OTHERLIBS)|g' \
	    < lablgllink.in > $@
	chmod 755 $@

lablglopt: lablglopt.in Makefile.config
	sed -e 's|@INCLUDES@|$(OCAMLINC)|g'	\
	    -e 's|@INSTALLDIR@|$(INSTALLDIR)|g' \
	    -e 's|@OTHERLIBS@|$(OTHERLIBS)|g' \
	    < lablglopt.in > $@
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
	if test -d $(INSTALLDIR); then : ; else mkdir -p $(INSTALLDIR); fi
	cp $(MLOBJS:.cmo=.cmi) $(INSTALLDIR)
	cp $(MLOBJS:.cmo=.mli) $(INSTALLDIR)
	cp lablgl.cma togl.cmo liblablgl.a $(INSTALLDIR)
	cp lablgltop $(INSTALLDIR)
	cp lablgl lablgllink $(BINDIR)
	if test -f lablgl.cmxa; then $(MAKE) installopt; fi

installopt:
	cp lablgl.cmxa lablgl.a $(INSTALLDIR)
	cp lablglopt $(BINDIR)


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
