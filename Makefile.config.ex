#	LablGL and Togl configuration file
#
# Please have a look at the Makefile.config of the labltk41 directory
# in the distribution, or at the labltklink script to get the
# information needed here
#

##### Adjust these always

# Where to put the lablgl and lablglopt scripts
BINDIR = /usr/local/bin/lang

# The Objective Label library directory (obtain it by olablc -v)
LIBDIR = /usr/local/lib/olabl

# Where to find Tcl/Tk headers and libraries
TKINCLUDES=-I/usr/local/include
TKLIBS=-L/usr/local/lib -ltk4.2 -ltcl7.6

# Where to find OpenGL/Mesa headers and libraries
GLINCLUDES=
GLLIBS=-lGL -lGLU

# Where to find X headers and libraries
XINCLUDES=-I/usr/X11R6/lib
XLIBS=-L/usr/X11R6/lib -lX11 -lXext -lXmu

# How to index a library
RANLIB= ranlib

##### Adjust these if non standard

# Where is LablTk (standard)
LABLTKDIR = $(LIBDIR)/labltk41

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
LIBS = $(TKLIBS) $(GLLIBS) $(XLIBS)

# Leave this empty
LIBDIRS =
