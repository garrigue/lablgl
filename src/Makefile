# OLabl commands
COMPILER=olablc -c
OPTCOMP=olablopt -inline 5 -c
LIBRARIAN=olablc -a
OPTLIB=olablopt -a
LINKER=olablc
OPTLINK=olablopt

include Makefile.config

# Files
MLOBJS =	raw.cmo 	gl.cmo		glu.cmo		togl.cmo
OPTOBJS =	raw.cmx 	gl.cmx		glu.cmx		togl.cmx
#gltk.cmo	aux.cmo
COBJS =		ml_gl.o		ml_glu.o	ml_togl.o	ml_raw.o \
		$(TOGLDIR)/togl.o
#ml_tk.o	ml_aux.o
# Default rules

.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o .var .h .opt

.ml.cmo:
	$(COMPILER) $(INCLUDES) $<

.ml.cmx:
	$(OPTCOMP) $(INCLUDES) $<

.mli.cmi:
	$(COMPILER) $(INCLUDES) $<

.c.o:
	$(COMPILER) $(CINCLUDES) $<

.var.h:
	var2def < $< > $@

.cmx.opt: lablgl.cmxa liblablgl.a
	$(OPTLINK) -o $@ $(INCLUDES) unix.cmxa tk41.cmxa lablgl.cmxa $< \
		-ccopt -L. -cclib -llablgl -cclib -lunix \
		$(GLLIBS) $(XLIBS) $(TKLIBS)

all: 	var2def	var2switch lablgltop lablgl

opt:	var2def var2switch lablgl.cmxa lablglopt

var2def: var2def.cmo
	$(LINKER) var2def.cmo -o $@

var2switch: var2switch.cmo
	$(LINKER) var2switch.cmo -o $@

lablgl.cma: $(MLOBJS)
	$(LIBRARIAN) -o lablgl.cma $(MLOBJS)

lablgl.cmxa: $(OPTOBJS)
	$(OPTLIB) -o lablgl.cmxa $(OPTOBJS)

liblablgl.a: $(COBJS)
	ar rc liblablgl.a $(COBJS)
#	$(RANLIB) liblablgl.a

lablgltop: lablgl.cma liblablgl.a
	olablmktop $(INCLUDES) -custom -o lablgltop \
		unix.cma tk41.cma lablgl.cma -ccopt -L. \
		-cclib -llablgl -cclib -lunix \
		$(GLLIBS) $(XLIBS) $(TKLIBS)

lablgl: lablgl.in Makefile.config
	sed -e "s|LABLTKDIR|$(LABLTKDIR)|g" -e "s|INSTALLDIR|$(INSTALLDIR)|g" \
		< lablgl.in > $@
	chmod +x $@

lablglopt: lablglopt.in Makefile.config
	sed -e "s|INCLUDES|$(INCLUDES)|g" -e "s|INSTALLDIR|$(INSTALLDIR)|g" \
		-e "s|OTHERLIBS|$(GLLIBS) $(XLIBS) $(TKLIBS)|g" \
		< lablglopt.in > $@
	chmod +x $@

gl_tags.c: gl_tags.var
	./var2switch GL_ < gl_tags.var > $@

tk_tags.c: tk_tags.var
	./var2switch TK_ < tk_tags.var > $@

togl_tags.c: togl_tags.var
	./var2switch TOGL_ < togl_tags.var > $@

glu_tags.c: glu_tags.var
	./var2switch GLU_ < glu_tags.var > $@

install:
	if test -d $(INSTALLDIR); then : ; else mkdir -p $(INSTALLDIR); fi
	cp raw.cmi gl.cmi glu.cmi togl.cmi $(INSTALLDIR)
	cp raw.mli gl.mli togl.mli $(INSTALLDIR)
	cp lablgl.cma liblablgl.a $(INSTALLDIR)
	cp lablgltop $(INSTALLDIR)
	cp lablgl $(BINDIR)
	if test -f lablgl.cmxa; then : ; \
		cp lablgl.cmxa lablgl.cma $(INSTALLDIR); \
		cp lablglopt $(BINDIR); fi


clean:
	rm -f *.cm* *.a *.o *.opt *_tags.c *_tags.h *~ \
		var2def var2switch lablgl lablglopt

ml_gl.o: ml_gl.h gl_tags.h gl_tags.c ml_raw.h
ml_tk.o: ml_gl.h tk_tags.h tk_tags.c
ml_aux.o: ml_gl.h
ml_togl.o : ml_gl.h togl_tags.h togl_tags.c
ml_glu.o : ml_gl.h glu_tags.h glu_tags.c
ml_raw.o: raw_tags.h ml_raw.h
raw.cmo raw.cmx: raw.cmi
gl.cmi: raw.cmi
gl.cmo gl.cmx: gl.cmi
glu.cmo glu.cmx: gl.cmi raw.cmi
glm.cmo glm.cmx: gl.cmi
aux.cmo: gltk.cmi
togl.cmi: gl.cmi
togl.cmo togl.cmx: togl.cmi
