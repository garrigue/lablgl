#	LablGL and Togl configuration file
#
# Please have a look at the config/Makefile in the Objective Caml distribution,
# or at the labltklink script to get the information needed here
#

##### Adjust these always

# Uncomment if you have the fast ".opt" compilers and are not using findlib
#CAMLC = ocamlc.opt
#CAMLOPT = ocamlopt.opt

# Where to put the lablgl script
BINDIR = /usr/local/bin

# Where to find X headers
XINCLUDES = -I/usr/X11R6/include
# X libs (for broken RTLD_GLOBAL: e.g. FreeBSD 4.0)
#XLIBS = -L/usr/X11R6/lib -lXext -lXmu -lX11 -lXi

# Where to find Tcl/Tk headers
# This must the same version as for LablTk
TKINCLUDES = -I/usr/local/include
# Tcl/Tk libs (for broken RTLD_GLOBAL: e.g. FreeBSD 4.0)
#TKLIBS = -L/usr/local/lib -ltk84 -ltcl84

# Where to find OpenGL/Mesa/Glut headers and libraries
GLINCLUDES =
GLLIBS = -lGL -lGLU
GLUTLIBS = -lglut
# The following libraries may be required (try to add them one at a time)
#GLLIBS = -lGL -lGLU -lXmu -lXext -lXi -lcipher -lpthread

# How to index a library after installing (ranlib required on MacOSX)
RANLIB = :
#RANLIB = ranlib

##### Uncomment these for windows
#TKLIBS = tk83.lib tcl83.lib gdi32.lib user32.lib
#GLLIBS = opengl32.lib glu32.lib 
#TOOLCHAIN = msvc
#XA = .lib
#XB = .bat
#XE = .exe
#XO = .obj
#XS = .dll

##### Adjust these if non standard

# The Objective Caml library directory
#LIBDIR = `ocamlc -where`

# Where to put dlls (if dynamic loading available)
#DLLDIR = `ocamlc -where`/stublibs

# Where to put LablGL (standard)
#INSTALLDIR = $(LIBDIR)/lablGL

# Where is Togl (default)
#TOGLDIR = Togl

# Togl Window System
# Should be one of TOGL_X11, TOGL_WGL (windows), TOGL_AGL (macosx)
# TOGL_AGL isn't supported currently
#TOGL_WS = TOGL_X11

# C Compiler options
#COPTS = -c -O

# Which camlp4o to use: camlp4o or camlp5o
# It is only required when modifying .ml4 files
#CAMLP4O=camlp5o pr_o.cmo
