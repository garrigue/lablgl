# OLabl commands
COMPILER=olablc -c
LIBRARIAN=olablc -a
LINKER=olablc

include Makefile.config

# Files
MLOBJS =	gl.cmo		gltk.cmo	aux.cmo		glm.cmo \
		togl.cmo
COBJS =		ml_gl.o		ml_tk.o		ml_aux.o \
		ml_togl.o	togl.o

# Default rules

.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o .var .h

.ml.cmo:
	$(COMPILER) $(INCLUDES) $<

.mli.cmi:
	$(COMPILER) $(INCLUDES) $<

.c.o:
	$(COMPILER) $(CINCLUDES) $<

.var.h:
	var2def < $< > $@

all: 	var2def	var2switch lablgl

var2def: var2def.cmo
	$(LINKER) var2def.cmo -o $@

var2switch: var2switch.cmo
	$(LINKER) var2switch.cmo -o $@

lablgl.cma: $(MLOBJS)
	$(LIBRARIAN) -o lablgl.cma $(MLOBJS)

liblablgl.a: $(COBJS)
	ar rc liblablgl.a $(COBJS)
#	$(RANLIB) liblablgl.a

lablgl: lablgl.cma liblablgl.a
	olablmktop $(INCLUDES) -custom -o lablgl \
		unix.cma tk41.cma lablgl.cma -ccopt -L. \
		-cclib -llablgl -cclib -lunix \
		$(AUXLIB) $(GLLIBS) $(XLIBS) $(TKLIBS)

labltogl: 

gl_tags.c: gl_tags.var
	./var2switch GL_ < gl_tags.var > $@

tk_tags.c: tk_tags.var
	./var2switch TK_ < tk_tags.var > $@

togl_tags.c: togl_tags.var
	./var2switch TOGL_ < togl_tags.var > $@

clean:
	rm -f *.cm? *.o gl_tags.[ch] tk_tags.[ch] *~ #*

ml_gl.o: ml_gl.h gl_tags.h gl_tags.c
ml_tk.o: ml_gl.h tk_tags.h tk_tags.c
ml_aux.o: ml_gl.h
ml_togl.o : ml_gl.h togl_tags.h togl_tags.c
glm.cmo: gl.cmi
aux.cmo: gltk.cmi
