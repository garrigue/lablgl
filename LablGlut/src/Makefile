# Include shared parts
#TOPDIR = ../..
#include $(TOPDIR)/Makefile.common

all: byte-code-library native-code-library top
RESULT=lablglut
CAMLIDL=../camlidl/compiler/camlidl
IDLFLAGS=-no-include -prepro "cpp -traditional-cpp"

# Composite options
#INCLUDES = $(GLINCLUDES) $(XINCLUDES) -I$(SRCDIR)
#LIBS = $(GLUTLIBS) $(GLLIBS) $(XLIBS)
#LIBDIRS =

#OCAMLINC=

all: debug-code-library native-code-library top
BIN_DIR=/usr/local/bin
SOURCES=\
    ba_utils.ml \
    glcaml.idl\
    glucaml.idl\
    glutcaml.mli glutcaml.ml\
    wrap_glut.c\
    lablglut.ml
LIBS=bigarray
LIBDIRS=$(OCAML)
CLIBS=camlidl glut GLU GL

include OCamlMakefile

glcaml.idl: gl_constants.idl

gl_constants.idl: ./config.sh
	./config.sh

install: dcl ncl
	install -d $(OCAML)/lablglut
	install *.{mli,cmi} *.cma *.a *.so $(OCAML)/lablglut
	install lablglut{,.top} $(BIN_DIR)

#ifeq ($(TOOLCHAIN), msvc)
#liblablglut$(XA): $(COBJS)
#	$(MKLIB)$@ $(COBJS)
#dlllablglut.dll: $(COBJS:$(XO)=.d$(XO))
#	$(MKDLL)$@ $(COBJS:$(XO)=.d$(XO)) $(GLUTLIBS) $(GLLIBS) $(OCAMLDLL)
#lablglut.cma: liblablglut$(XA) dlllablglut.dll $(LIBOBJS) ../../Makefile.config
#	$(LINKER) -a -o $@ $(LIBOBJS) \
#	  -cclib -llablglut -dllib -llablglut \
#	  -cclib "$(GLLIBS)" -cclib "$(GLUTLIBS)"
#lablglut.cmxa: liblablglut$(XA) $(OPTOBJS) ../../Makefile.config
#	$(OPTLINK) -a -o $@ $(OPTOBJS) -cclib -llablglut \
#	  -cclib "$(GLLIBS)" -cclib "$(GLUTLIBS)"
#else
#liblablglut.a: $(COBJS) ../../Makefile.config
#	$(LIBRARIAN) -o lablglut $(COBJS) $(GLUTLIBS) $(GLLIBS) $(XLIBS)
#lablglut.cma: liblablglut.a $(LIBOBJS) ../../Makefile.config
#	$(LIBRARIAN) -o lablglut $(LIBOBJS) $(GLUTLIBS) $(GLLIBS) $(XLIBS)
#lablglut.cmxa: liblablglut.a $(OPTOBJS) ../../Makefile.config
#	$(LIBRARIAN) -o lablglut $(OPTOBJS) $(GLUTLIBS) $(GLLIBS) $(XLIBS)
#endif
#
#lablgluttop$(XE): lablglut.cma 
#	ocamlmktop $(CUSTOMTOP) -I . -I $(SRCDIR) $(OCAMLINC) -o $@ \
#	  lablglut.cma lablgl.cma
#
#lablglut: $(CONFIG) Makefile liblablglut$(XA)
#	$(MAKE) INSTALLDIR="$(INSTALLDIR)" real-$@
#
#real-lablglut:
#	@echo generate lablglut
#	echo "#!/bin/sh" > lablglut
#	echo "# toplevel with lablGL and LablGlut" >> lablglut
#	if test -f dlllablglut$(XS); then \
#	    echo 'exec ocaml -I "$(INSTALLDIR)" lablgl.cma lablglut.cma $$*' >> lablglut; \
#	 else echo 'exec "$(INSTALLDIR)/lablgluttop" -I "$(INSTALLDIR)" $$*' >> lablglut; fi
#	chmod 755 lablglut
#
#install:
#	@if test -f lablglut.cma; then $(MAKE) real-install; fi
#
#real-install: 
#	if test -d "$(INSTALLDIR)"; then : ; else mkdir -p "$(INSTALLDIR)"; fi
#	cp $(LIBOBJS:.cmo=.cmi) "$(INSTALLDIR)"
#	cp $(LIBOBJS:.cmo=.mli) "$(INSTALLDIR)"
#	cp liblablglut$(XA) lablglut.cma "$(INSTALLDIR)"
#	cd "$(INSTALLDIR)" && $(RANLIB) liblablglut$(XA)
#	@if test -f dlllablglut$(XS); then $(MAKE) installdll; \
#	 else $(MAKE) installtop; fi
#	cp lablglut$(XB) "$(BINDIR)"
#	@if test -f lablglut.cmxa; then $(MAKE) installopt; fi
#
#installdll:
#	cp dlllablglut$(XS) "$(DLLDIR)"
#
#installtop:
#	cp lablgluttop$(XE) "$(INSTALLDIR)"
#
#installopt:
#	cp lablglut.cmxa lablglut$(XA) $(LIBOBJS:.cmo=.cmx) "$(INSTALLDIR)"
#	cd "$(INSTALLDIR)" && $(RANLIB) lablglut$(XA)


