#Adjust this directory for installation
LIBDIR=/usr/local/lib/olabl
COMPILER=olablc -c
LIBRARIAN=olablc -a
LINKER=olablc
INCLUDES=-I /usr/local/lib/olabl/labltk41
CINCLUDES=-ccopt "-I/usr/local/lib/tcl8.0 -I/usr/local/lib/tk8.0" \
	-ccopt "-I/usr/local/include"
#GLLIBS=	-ccopt "-L/usr/local/lib" -cclib -lMesaaux -cclib -lMesatk \
#	-cclib -lMesaGL -cclib -lMesaGLU
AUXLIB=-ccopt -L. -cclib -lglaux
GLLIBS=-cclib -lGL -cclib -lGLU
TKLIBS=-ccopt -L/usr/local/lib/olabl/labltk41 -cclib -llabltk41 \
	-ccopt -L/usr/local/lib -cclib -ltk8.0 -cclib -ltcl8.0

XLIBS= -ccopt "-L/usr/X11R6/lib" -cclib -lX11 -cclib -lXext -cclib -lXmu
RANLIB= ranlib

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
