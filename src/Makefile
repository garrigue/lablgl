# OLabl commands
COMPILER=olablc -c
OPTCOMP=olablopt -inline 5 -c
LIBRARIAN=olablc -a
OPTLIB=olablopt -a
LINKER=olablc
OPTLINK=olablopt

include Makefile.config

# Files
MLOBJS =	raw.cmo 	gl.cmo		glu.cmo		glm.cmo \
		togl.cmo
OPTOBJS =	raw.cmx 	gl.cmx		glu.cmx		glm.cmx \
		togl.cmx
#gltk.cmo	aux.cmo
COBJS =		ml_gl.o		ml_glu.o	ml_togl.o	ml_raw.o \
		$(TOGL)
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

all: 	var2def	var2switch lablgl

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
	$(RANLIB) liblablgl.a

lablgl: lablgl.cma liblablgl.a
	olablmktop $(INCLUDES) -custom -o lablgl \
		unix.cma tk41.cma lablgl.cma -ccopt -L. \
		-cclib -llablgl -cclib -lunix \
		$(GLLIBS) $(XLIBS) $(TKLIBS)

gl_tags.c: gl_tags.var
	./var2switch GL_ < gl_tags.var > $@

tk_tags.c: tk_tags.var
	./var2switch TK_ < tk_tags.var > $@

togl_tags.c: togl_tags.var
	./var2switch TOGL_ < togl_tags.var > $@

glu_tags.c: glu_tags.var
	./var2switch GLU_ < glu_tags.var > $@

clean:
	rm -f *.cm? ml_*.o gl_tags.[ch] tk_tags.[ch] *~ #*

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
