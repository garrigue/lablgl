#	LablGL and Togl configuration file
#
# Please have a look at the config/Makefile in the Objective Caml distribution,
# or at the labltklink script to get the information needed here
#

##### Adjust these always

# Uncomment if you have the fast ".opt" compilers
#CAMLC = ocamlc.opt
#CAMLOPT = ocamlopt.opt

# Where to put the lablgl script
BINDIR = /usr/local/bin

# Where to find X headers
XINCLUDES = -I/usr/X11R6/include
# X libs (for broken RTLD_GLOBAL: e.g. FreeBSD 4.0)
#XLIBS = -L/usr/X11R6/lib -lXext -lXmu -lX11

# Where to find Tcl/Tk headers
# This must the same version as for LablTk
TKINCLUDES = -I/usr/local/include
# Tcl/Tk libs (for broken RTLD_GLOBAL: e.g. FreeBSD 4.0)
#TKLIBS = -L/usr/local/lib -ltk83 -ltcl83

# Where to find OpenGL/Mesa headers and libraries
GLINCLUDES =
GLLIBS = -lGL -lGLU
# The following libraries may be required (try to add them one at a time)
#GLLIBS = -lGL -lGLU -lXmu -lXext -lpthread

# How to index a library after installing (ranlib required on MacOSX)
RANLIB = :
#RANLIB = ranlib

##### Uncomment these for windows
#XINCLUDES = -Ic:\Progra~1\Micros~1.NET\Vc7\PlatformSDK\Include # Where wtypes.h is
#TKINCLUDES = -Ic:\Progra~1\tcl\include 
#TKLIBS = /LIBPATH:"c:\Progra~1\tcl\lib" tk83.lib tcl83.lib gdi32.lib user32.lib # Where tcl is installed
#GLLIBS = /LIBPATH:"c:\Progra~1\Micros~1.NET\Vc7\PlatformSDK\lib" opengl32.lib glu32.lib # Where the libs are
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

# C Compiler options
#COPTS = -c -O
