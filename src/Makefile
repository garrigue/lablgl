#Adjust this directory for installation
LIBDIR=/usr/local/lib/olabl
COMPILER=olablc -c
LIBRARIAN=olablc -a
LINKER=olablc
CINCLUDES=-ccopt "-I/usr/local/include"
GLLIBS=	-ccopt "-L/usr/local/lib" -cclib -lMesaaux -cclib -lMesatk \
	-cclib -lMesaGL -cclib -lMesaGLU
XLIBS= -ccopt "-L/usr/X11R6/lib" -cclib -lX11 -cclib -lXext

MLOBJS =	gl.cmo		tk.cmo		aux.cmo		glm.cmo
COBJS =		ml_gl.o		ml_tk.o		ml_aux.o

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

lablgl: lablgl.cma liblablgl.a
	olablmktop -custom -o lablgl unix.cma lablgl.cma -ccopt -L. \
		-cclib -llablgl -cclib -lunix $(GLLIBS) $(XLIBS)

gl_tags.c: gl_tags.var
	./var2switch GL_ < gl_tags.var > $@

tk_tags.c: tk_tags.var
	./var2switch TK_ < tk_tags.var > $@

clean:
	rm -f *.cm? *.o gl_tags.[ch] tk_tags.[ch] *~ #*

ml_gl.o: ml_gl.h gl_tags.h gl_tags.c
ml_tk.o: ml_gl.h tk_tags.h tk_tags.c
ml_aux.o: ml_gl.h
glm.cmo: gl.cmi
aux.cmo: tk.cmi
