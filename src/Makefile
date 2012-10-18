# Include shared parts
TOPDIR = ..
include ../Makefile.common

# Composite options
INCLUDES = $(GLINCLUDES) $(XINCLUDES)
LIBS = $(GLLIBS) $(XLIBS)
LIBDIRS =


OCAMLINC=-I +labltk

# Files
LIBOBJS =	raw.cmo \
		gl.cmo		glLight.cmo	glList.cmo	glMap.cmo \
		glMat.cmo	glMisc.cmo	glPix.cmo	glClear.cmo \
		glTex.cmo	glDraw.cmo	glFunc.cmo	gluMisc.cmo \
		gluNurbs.cmo	gluQuadric.cmo	gluTess.cmo	gluMat.cmo \
		glArray.cmo	glShader.cmo
MLOBJS = $(LIBOBJS)	togl.cmo
OPTOBJS = $(LIBOBJS:.cmo=.cmx)
COBJS =		ml_gl$(XO)	ml_glu$(XO)	ml_raw$(XO) ml_glarray$(XO) \
		ml_glutess$(XO)	ml_shader$(XO)
TOGLOBJS =	ml_togl$(XO)	$(TOGLDIR)/togl$(XO)

all: tools
	$(MAKE) lablgl.cma

opt: lablgl.cmxa

tools: var2def$(XE) var2switch$(XE)

var2def$(XE): var2def.ml
	$(LINKER) -pp camlp4o var2def.ml -o $@

var2switch$(XE): var2switch.ml
	$(LINKER) -pp camlp4o var2switch.ml -o $@

ifeq ($(TOOLCHAIN), msvc)
liblablgl$(XA): $(COBJS)
	$(MKLIB)$@ $(COBJS)
dlllablgl.dll: $(COBJS:$(XO)=.d$(XO))
	$(MKDLL)$@ $(COBJS:$(XO)=.d$(XO)) $(GLLIBS) $(OCAMLDLL)
lablgl.cma: liblablgl$(XA) dlllablgl.dll $(LIBOBJS) $(CONFIG)
	$(LINKER) -a -o $@ $(LIBOBJS) \
	  -cclib -llablgl -dllib -llablgl \
	  -cclib "$(GLLIBS)"
lablgl.cmxa: liblablgl$(XA) $(OPTOBJS) $(CONFIG)
	$(OPTLINK) -a -o $@ $(OPTOBJS) -cclib -llablgl \
	  -cclib "$(GLLIBS)"
else
liblablgl$(XA): lablgl.cma
lablgl.cma: $(COBJS) $(LIBOBJS) $(CONFIG)
	$(LIBRARIAN) -o lablgl $(COBJS) $(LIBOBJS) $(GLLIBS) $(XLIBS)
lablgl.cmxa: $(COBJS) $(OPTOBJS) $(CONFIG)
	$(LIBRARIAN) -o lablgl $(COBJS) $(OPTOBJS) $(GLLIBS) $(XLIBS)
endif

gl_tags.c: gl_tags.var
	$(VAR2SWITCH) -table GL_ < gl_tags.var > $@

glu_tags.c: glu_tags.var
	$(VAR2SWITCH) GLU_ < glu_tags.var > $@

build.ml: build.ml.in ../Makefile.config
	sed -e "s|@LABLGL_MLS@|$(LIBOBJS:.cmo=)|" \
	    -e "s|@TOGL_MLS@|togl|" \
	    -e "s|@GLUT_MLS@|glut|" \
	    -e "s|@GLLIBS@|$(GLLIBS0)|" \
	    -e "s|@TKLIBS@|$(TKLIBS0)|" \
	    -e "s|@GLUTLIBS@|$(GLUTLIBS0)|" < build.ml.in > $@

preinstall: build.ml
	if test -d "$(INSTALLDIR)"; then : ; else mkdir -p "$(INSTALLDIR)"; fi
	cp build.ml $(LIBOBJS:.cmo=.ml) $(LIBOBJS:.cmo=.mli) "$(INSTALLDIR)"
	cp liblablgl$(XA) "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) liblablgl$(XA)
	if test -f dlllablgl$(XS); then cp dlllablgl$(XS) "$(DLLDIR)"; fi

install: preinstall
	cp $(LIBOBJS:.cmo=.cmi) lablgl.cma "$(INSTALLDIR)"
	@if test -f lablgl.cmxa; then $(MAKE) installopt; fi

installopt:
	cp lablgl.cmxa lablgl$(XA) $(LIBOBJS:.cmo=.cmx) "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) lablgl$(XA)

clean:
	rm -f *.cm* *.a *.o *.so *.lib *.obj *.exe *.opt *_tags.c *_tags.h *~ \
		*.dll var2def$(XE) var2switch$(XE) lablgltop$(XE) lablgl$(XB)

depend:
	ocamldep  -pp camlp4o *.ml *.mli > .depend

#dependencies
ml_gl$(XO): ml_gl.h gl_tags.h gl_tags.c ml_raw.h
ml_glu$(XO) ml_glutess$(XO) : ml_gl.h ml_glu.h glu_tags.h glu_tags.c
ml_raw$(XO): raw_tags.h ml_raw.h
include .depend
