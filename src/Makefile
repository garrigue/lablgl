#Adjust this directory for installation
LIBDIR=/usr/local/lib/olabl
COMPILER=olablc -c
LIBRARIAN=olablc -a
LINKER=olablc

MLOBJS =	gl.cmo		tk.cmo		aux.cmo		glm.cmo
COBJS =		ml_gl.o		ml_aux.o

# Default rules

.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o .var .h

.ml.cmo:
	$(COMPILER) $(INCLUDES) $<

.mli.cmi:
	$(COMPILER) $(INCLUDES) $<

.c.o:
	$(COMPILER) $(INCLUDES) $<

.var.h:
	var2def < $< > $@

all: 	var2def	var2switch lablgl.cma liblablgl.a

var2def: var2def.cmo
	$(LINKER) var2def.cmo -o $@

var2switch: var2switch.cmo
	$(LINKER) var2switch.cmo -o $@

lablgl.cma: $(MLOBJS)
	$(LIBRARIAN) -o lablgl.cma $(MLOBJS)

liblablgl.a: $(COBJS)
	ar rc liblablgl.a $(COBJS)

lablgl: lablgl.cma liblablgl.a
	olablmktop -custom -o lablgl unix.cma lablgl.cma -ccopt -L. \
		-cclib -llablgl -cclib -lunix -cclib -laux \
		-cclib -lGL -cclib -lGLU -cclib -lX11

gl_tags.c: gl_tags.var
	./var2switch GL_ < gl_tags.var > $@

aux_tags.c: aux_tags.var
	./var2switch AUX_ < aux_tags.var > $@

clean:
	rm -f *.cm? *.o gl_tags.[ch] aux_tags.[ch] *~ #*

ml_gl.o: ml_gl.h gl_tags.h gl_tags.c
ml_aux.o: ml_gl.h aux_tags.h aux_tags.c
glm.cmo: gl.cmi