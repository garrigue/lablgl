# Adjust according to your installation

# Where to put the lablgl and lablglopt scripts
BINDIR=/usr/local/bin/lang
# The Objective Label library directory
LIBDIR=/usr/local/lib/olabl
# Where is LablTk (standard)
LABLTKDIR=$(LIBDIR)/labltk41
# Where to put LablGL (standard)
INSTALLDIR=$(LIBDIR)/lablGL
# Where you compiled Togl
TOGLDIR=/safran/lang/Togl-1.4

# Look in the labltklink script to set the following
INCLUDES=-I $(LABLTKDIR)
CINCLUDES=-ccopt "-I/usr/local/lib/tcl8.0 -I/usr/local/lib/tk8.0" \
	-ccopt "-I$(TOGLDIR) -I/usr/local/include"
GLLIBS=-cclib -lGL -cclib -lGLU
TKLIBS=-ccopt -L$(LABLTKDIR) -cclib -llabltk41 \
	-ccopt -L/usr/local/lib -cclib -ltk8.0 -cclib -ltcl8.0
XLIBS= -ccopt "-L/usr/X11R6/lib" -cclib -lX11 -cclib -lXext -cclib -lXmu
RANLIB= ranlib
