.PHONY : all
all : lablgluttop

.PHONY : opt
opt : all

.PHONY : install
install : lablgluttop 
	install lablgluttop $(INSTALLDIR) ;  \
    install lablglut $(BIN_DIR)

.PHONY : lablgluttop
lablgluttop: 
	ocamlmktop $(OCAMLINC) -o lablgluttop  $(DLL_PATH) -o lablgluttop $(LIBS)

OCAMLC=ocamlc

OCAMLROOT=$(shell $(OCAMLC) 2>/dev/null -where || echo /usr/local/lib/ocaml)

LABLGLUT_DIR=../src_lablglut
LABLGL_DIR=../lablGL-0.98

OCAMLINC=\
    -I $(LABLGL_DIR) \
    -I $(LABLGLUT_DIR) 

#LIBS=$(shell if [[ -e $(LABLGL_DIR)/lablgl.cmxa && -e $(LABLGLUT_DIR)/lablglut.cmxa ]]; then echo lablgl.cmxa lablglut.cmxa; else echo lablgl.cma lablgl.cma; fi)
LIBS=lablglut.cma lablgl.cma

TOPLEVEL=lablgluttop

BIN_DIR=/usr/local/bin

INSTALLDIR=$(OCAMLROOT)/lablglut

DLL_PATH = \
    -dllpath $(OCAMLROOT)/lablGL \
    -dllpath $(OCAMLROOT)/lablglut \
    -dllpath $(INSTALLDIR) 

.PHONE: clean
clean: 
	rm -f $(TOPLEVEL)

