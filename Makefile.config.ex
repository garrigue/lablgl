#	LablGL and Togl configuration file
#
# Please have a look at the config/Makefile in the Objective Caml distribution,
# or at the labltklink script to get the information needed here
#

##### Adjust these always

# Where to put the lablgl, lablgllink and lablglopt scripts
BINDIR = /usr/local/bin

# Where to find X headers
XINCLUDES=-I/usr/X11R6/include

# Where to find Tcl/Tk headers
# This must the same version as for LablTk
TKINCLUDES=-I/usr/local/include

# Where to find OpenGL/Mesa headers and libraries
GLINCLUDES=
GLLIBS=-lGL -lGLU -Xmu

# How to index a library
RANLIB= ranlib
#RANLIB = :

##### Adjust these if non standard

# Where is LablTk (standard)
LABLTKDIR = +labltk

# The Objective Caml library directory
LIBDIR = `ocamlc -where`

# Where to put LablGL (standard)
INSTALLDIR = $(LIBDIR)/lablGL

# Where is Togl (default)
TOGLDIR = Togl

# The C compiler (Togl only)
CC = cc

# Compiler options:
COPTS = -c -O

###### No need to change these

# Where to find tcl.h, tk.h, OpenGL/Mesa headers, etc:
INCLUDES = $(TKINCLUDES) $(GLINCLUDES) $(XINCLUDES)

# Libraries to link with (-ldl for Linux only?):
LIBS = $(GLLIBS)

# Leave this empty
LIBDIRS =
