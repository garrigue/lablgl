all: debug-code
BIN_DIR=/usr/local/bin
RESULT = c2ml
OCAMLMAKEFILE = OCamlMakefile
SOURCES = cabs.ml clexer.mll cparser.mly frontc.ml cprint.ml \
    cabs.mli cprint.mli frontc.mli c2ml.ml
clexer.ml: cparser.cmi
cparser.cmi: cabs.cmi

-include $(OCAMLMAKEFILE)

install:
	for i in c2ml c2ml.sh ; do install $$i $(BIN_DIR) ; done

