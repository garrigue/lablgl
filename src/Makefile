#Adjust this directory for installation
LIBDIR=/usr/local/lib/olabl
COMPILER=olablc -c
LIBRARIAN=olablc -a
LINKER=olablc

MLOBJS =	gl.cmo		aux.cmo		glm.cmo
COBJS =		ml_gl.o		ml_aux.o

# Default rules

.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o

.ml.cmo:
	$(COMPILER) $(INCLUDES) $<

.mli.cmi:
	$(COMPILER) $(INCLUDES) $<

.c.o:
	$(COMPILER) $(INCLUDES) $<

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

variants.h: variants
	./var2def < variants > $@

variants.c: variants
	./var2switch GL_ < variants > $@
clean:
	rm -f *.cm? *.o variants.[ch] *~ #*

ml_gl.o ml_aux.o: ml_gl.h variants.h
ml_gl.o: variants.c
variants:;
glm.cmo: gl.cmi