# Include shared parts
TOPDIR = ../..
include $(TOPDIR)/Makefile.common

# Composite options
INCLUDES = -I$(SRCDIR) -I$(TOGLDIR) \
	$(TKINCLUDES) $(GLINCLUDES) $(XINCLUDES)
LIBS = $(TKLIBS) $(GLLIBS) $(XLIBS)
LIBDIRS =

OCAMLINC=-I +labltk -I $(SRCDIR)

# Files
TOGLOBJS =	ml_togl$(XO)	$(TOGLDIR)/togl$(XO)

# Extra rules
.cmx.opt: $(TOPDIR)/src/lablgl.cmxa togl.cmxa
	$(OPTLINK) -o $@ $(OCAMLINC) -ccopt -L. \
	    unix.cmxa labltk.cmxa ../../lablgl.cmxa togl.cmxa $<

all: lablgltop$(XE) lablgl$(XB)

opt: togl.cmxa

ifeq ($(TOOLCHAIN), msvc)
libtogl$(XA): $(TOGLOBJS) $(CONFIG)
	$(MKLIB)$@ $(TOGLOBJS)
dlltogl.dll: $(TOGLOBJS:$(XO)=.d$(XO))
	$(MKDLL)$@ $(TOGLOBJS:$(XO)=.d$(XO)) $(GLLIBS) $(TKLIBS) $(OCAMLDLL)
togl.cma: libtogl$(XA) dlltogl.dll togl.cmo $(CONFIG)
	$(LINKER) -a -o $@ togl.cmo -cclib -ltogl -dllib -ltogl \
	  -cclib "$(GLLIBS) $(TKLIBS)"
togl.cmxa: libtogl$(XA) togl.cmx $(CONFIG)
	$(OPTLINK) -a -o $@ togl.cmx -cclib -ltogl \
	  -cclib "$(GLLIBS) $(TKLIBS)"
#CUSTOMTOP = -verbose -custom unix.cma
else
libtogl.a: $(TOGLOBJS) $(CONFIG)
	$(LIBRARIAN) -o togl $(TOGLOBJS) $(GLLIBS) $(TKLIBS) $(XLIBS)
togl.cma: libtogl.a togl.cmo $(CONFIG)
	$(LIBRARIAN) -o togl togl.cmo $(GLLIBS) $(TKLIBS) $(XLIBS)
togl.cmxa: libtogl.a togl.cmx $(CONFIG)
	$(LIBRARIAN) -o togl togl.cmx $(GLLIBS) $(TKLIBS) $(XLIBS)
INSTTOP = lablgltop
endif

$(TOGLDIR)/togl.o:
	cd $(TOGLDIR) && $(MAKE) togl.o CC="$(CAMLC)" CFLAGS='-c -ccopt "$(COPTS) $(INCLUDES) $(TK_FLAGS)"'

$(TOGLDIR)/togl.obj:
	cd $(TOGLDIR) && \
        $(CAMLC) -c -ccopt "-DWIN32 $(COPTS) $(INCLUDES) -I." togl.c

$(TOGLDIR)/togl.d.obj:
	cd $(TOGLDIR) && \
        $(CAMLC) -c -ccopt "/MD /Fotogl.d.obj -DWIN32" \
		-ccopt "$(COPTS) $(INCLUDES) -I." \
		togl.c

lablgltop$(XE): ../../src/lablgl.cma togl.cma
	ocamlmktop $(CUSTOMTOP) -I . $(OCAMLINC) -o $@ \
	  labltk.cma lablgl.cma togl.cma

lablgl$(XB): lablgl.in $(CONFIG)
	sed -e 's|@LABLTKDIR@|$(LABLTKDIR)|g'	\
	    -e 's|@INSTALLDIR@|'"$(INSTALLDIR)"'|g'	\
	    < lablgl.in > $@
	chmod 755 $@

togl_tags.c: togl_tags.var
	$(VAR2SWITCH) TOGL_ < togl_tags.var > $@

install:
	@if test -f lablgltop$(XE); then $(MAKE) toglinstall; fi

toglinstall:
	cp togl.cmi togl.mli libtogl$(XA) togl.cma $(INSTTOP) "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) libtogl$(XA)
	if test -f dlltogl$(XS); then cp dlltogl$(XS) "$(DLLDIR)"; fi
	cp lablgl$(XB) "$(BINDIR)"
	@if test -f togl.cmxa; then $(MAKE) toglinstallopt; fi

toglinstallopt:
	cp togl.cmxa togl$(XA) togl.cmx "$(INSTALLDIR)"
	cd "$(INSTALLDIR)" && $(RANLIB) togl$(XA)

clean:
	rm -f *.cm* *.o *.obj *.so *.lib *.a *.dll *.exe *.opt *_tags.c \
	    *_tags.h *~ lablgltop$(EX) lablgl$(XB)
	rm -f $(TOGLDIR)/togl$(XO)

depend:
	ocamldep  -pp camlp4o *.ml *.mli > .depend

#dependencies
ml_tk$(XO): $(TOPDIR)/src/ml_gl.h tk_tags.h tk_tags.c
ml_togl$(XO) : $(TOPDIR)/src/ml_gl.h togl_tags.h togl_tags.c
include .depend
