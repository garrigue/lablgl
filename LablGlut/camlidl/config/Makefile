#***********************************************************************
#*                                                                     *
#*                              CamlIDL                                *
#*                                                                     *
#*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *
#*                                                                     *
#*  Copyright 1999 Institut National de Recherche en Informatique et   *
#*  en Automatique.  All rights reserved.  This file is distributed    *
#*  under the terms of the GNU Library General Public License.         *
#*                                                                     *
#***********************************************************************

#* $Id: Makefile,v 1.1 2003-10-28 18:52:35 ijtrotts Exp $

## Configuration section

# Type of system -- do not change
OSTYPE=unix

# How to invoke the C preprocessor
# Works on most Unix systems:
CPP=/lib/cpp
# Alternatives:
# CPP=cpp
# CPP=/usr/ccs/lib/cpp
# CPP=gcc -x c -E

# How to invoke ranlib (only relevant for Unix)
RANLIB=ranlib
# If ranlib is not needed:
#RANLIB=:

# Location of the Objective Caml library in your installation
OCAMLLIB=/usr/lib/ocaml/3.06

# Where to install the binaries
BINDIR=/usr/local/bin

# The Objective Caml compilers (the defaults below should be OK)
OCAMLC=ocamlc -g
OCAMLOPT=ocamlopt
OCAMLYACC=ocamlyacc -v
OCAMLLEX=ocamllex
OCAMLDEP=ocamldep

# Extra flags to pass to the C compiler
CFLAGS=-Wall -g

# Suffixes for executables and libraries (do not change)
EXE=
LIBEXT=a
OBJEXT=o
