/* $Id: togl.c,v 1.73 2005/10/26 07:40:22 gregcouch Exp $ */

/* vi:set sw=4: */

/* 
 * Togl - a Tk OpenGL widget
 *
 * Copyright (C) 1996-2002  Brian Paul and Ben Bederson
 * See the LICENSE file for copyright details.
 */

/* 
 * Currently we support X11, Win32 and Macintosh only
 */

#include "togl.h"

/* Use TCL_STUPID to cast (const char *) to (char *) where the Tcl function
 * prototype argument should really be const */
#define TCL_STUPID (char *)

/* Use WIDGREC to cast widgRec arguments */
#define WIDGREC	(char *)

/*** Windows headers ***/
#if defined(TOGL_WGL)
#  define WIN32_LEAN_AND_MEAN
#  include <windows.h>
#  undef WIN32_LEAN_AND_MEAN
#  include <winnt.h>

/*** X Window System headers ***/
#elif defined(TOGL_X11)
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#  include <X11/Xatom.h>        /* for XA_RGB_DEFAULT_MAP atom */
#  if defined(__vms)
#    include <X11/StdCmap.h>    /* for XmuLookupStandardColormap */
#  else
#    include <X11/Xmu/StdCmap.h>        /* for XmuLookupStandardColormap */
#  endif
#  include <GL/glx.h>

/*** Mac headers ***/
#elif defined(TOGL_AGL_CLASSIC)
#  include <Gestalt.h>
#  include <Traps.h>
#  include <agl.h>
#  include <tclMacCommonPch.h>

#elif defined(TOGL_AGL)
#  define Cursor QDCursor
#  include <AGL/agl.h>
#  undef Cursor
#  include "tkMacOSX.h"
#  include <tkMacOSXInt.h>      /* usa MacDrawable */
#  include <ApplicationServices/ApplicationServices.h>

#else /* make sure only one platform defined */
#  error Unsupported platform, or confused platform defines...
#endif

/*** Standard C headers ***/
#include <assert.h>
#include <stdlib.h>
#include <string.h>

#ifdef TOGL_WGL
#  include <tkPlatDecls.h>
#endif

#if TK_MAJOR_VERSION < 8
#  error Sorry Togl requires Tcl/Tk ver 8.0 or higher.
#endif

#if defined(TOGL_AGL_CLASSIC)
#  if TK_MAJOR_VERSION < 8 || (TK_MAJOR_VERSION == 8 && TK_MINOR_VERSION < 3)
#    error Sorry Mac classic version requires Tcl/Tk ver 8.3.0 or higher.
#  endif
#endif /* TOGL_AGL_CLASSIC */

#if defined(TOGL_AGL)
#  if TK_MAJOR_VERSION < 8 || (TK_MAJOR_VERSION == 8 && TK_MINOR_VERSION < 4)
#    error Sorry Mac Aqua version requires Tcl/Tk ver 8.4.0 or higher.
#  endif
#endif /* TOGL_AGL */

/* workaround for bug #123153 in tcl ver8.4a2 (tcl.h) */
#if defined(Tcl_InitHashTable) && defined(USE_TCL_STUBS)
#  undef Tcl_InitHashTable
#  define Tcl_InitHashTable (tclStubsPtr->tcl_InitHashTable)
#endif
#if TK_MAJOR_VERSION > 8 || (TK_MAJOR_VERSION == 8 && TK_MINOR_VERSION >= 4)
#  define HAVE_TK_SETCLASSPROCS
/* pointer to Tk_SetClassProcs function in the stub table */

static void (*SetClassProcsPtr)
        _ANSI_ARGS_((Tk_Window, Tk_ClassProcs *, ClientData));
#endif

/* 
 * Copy of TkClassProcs declarations form tkInt.h
 * (this is needed for Tcl ver =< 8.4a3)
 */

typedef Window (TkClassCreateProc) _ANSI_ARGS_((Tk_Window tkwin,
                Window parent, ClientData instanceData));
typedef void (TkClassGeometryProc) _ANSI_ARGS_((ClientData instanceData));
typedef void (TkClassModalProc) _ANSI_ARGS_((Tk_Window tkwin,
                XEvent *eventPtr));
typedef struct TkClassProcs
{
    TkClassCreateProc *createProc;
    TkClassGeometryProc *geometryProc;
    TkClassModalProc *modalProc;
} TkClassProcs;


/* Defaults */
#define DEFAULT_WIDTH		"400"
#define DEFAULT_HEIGHT		"400"
#define DEFAULT_IDENT		""
#define DEFAULT_FONTNAME	"fixed"
#define DEFAULT_TIME		"1"


#ifdef TOGL_WGL
/* Maximum size of a logical palette corresponding to a colormap in color index
 * mode. */
#  define MAX_CI_COLORMAP_SIZE 4096

#  if TOGL_USE_FONTS != 1
/* 
 * copy of TkWinColormap from tkWinInt.h
 */

typedef struct
{
    HPALETTE palette;           /* Palette handle used when drawing. */
    UINT    size;               /* Number of entries in the palette. */
    int     stale;              /* 1 if palette needs to be realized, otherwise
                                 * 0.  If the palette is stale, then an idle
                                 * handler is scheduled to realize the palette. */
    Tcl_HashTable refCounts;    /* Hash table of palette entry reference counts
                                 * indexed by pixel value. */
} TkWinColormap;
#  else
#    include "tkWinInt.h"
#  endif

static  LRESULT(CALLBACK *tkWinChildProc) (HWND hwnd, UINT message,
        WPARAM wParam, LPARAM lParam) = NULL;

#  define TK_WIN_CHILD_CLASS_NAME "TkChild"

#endif /* TOGL_WGL */


#define MAX(a,b)	(((a)>(b))?(a):(b))

#define TCL_ERR(interp, string)			\
   do {						\
      Tcl_ResetResult(interp);			\
      Tcl_AppendResult(interp, string, NULL);	\
      return TCL_ERROR;				\
   } while (0)

/* The constant DUMMY_WINDOW is used to signal window creation failure from the
 * Togl_CreateWindow() */
#define DUMMY_WINDOW ((Window) -1)

#define ALL_EVENTS_MASK 	\
   (KeyPressMask |		\
    KeyReleaseMask |		\
    ButtonPressMask |		\
    ButtonReleaseMask |		\
    EnterWindowMask |		\
    LeaveWindowMask |		\
    PointerMotionMask |		\
    ExposureMask |		\
    VisibilityChangeMask |	\
    FocusChangeMask |		\
    PropertyChangeMask |	\
    ColormapChangeMask)

struct Togl
{
    Togl   *Next;               /* next in linked list */

#if defined(TOGL_WGL)
    HDC     tglGLHdc;           /* Device context of device that OpenGL calls
                                 * will be drawn on */
    HGLRC   tglGLHglrc;         /* OpenGL rendering context to be made current */
    int     CiColormapSize;     /* (Maximum) size of colormap in color index
                                 * mode */
#elif defined(TOGL_X11)
    GLXContext GlCtx;           /* Normal planes GLX context */
#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    AGLContext aglCtx;
#endif                          /* TOGL_WGL */

    Display *display;           /* X's token for the window's display. */
    Tk_Window TkWin;            /* Tk window structure */
    Tcl_Interp *Interp;         /* Tcl interpreter */
    Tcl_Command widgetCmd;      /* Token for togl's widget command */
#ifndef NO_TK_CURSOR
    Tk_Cursor Cursor;           /* The widget's cursor */
#endif
    int     Width, Height;      /* Dimensions of window */
    int     SetGrid;            /* positive is grid size for window manager */
    int     TimerInterval;      /* Time interval for timer in milliseconds */
#if (TCL_MAJOR_VERSION * 100 + TCL_MINOR_VERSION) >= 705
    Tcl_TimerToken timerHandler;        /* Token for togl's timer handler */
#else
    Tk_TimerToken timerHandler; /* Token for togl's timer handler */
#endif
    Bool    RgbaFlag;           /* configuration flags (ala GLX parameters) */
    int     RgbaRed;
    int     RgbaGreen;
    int     RgbaBlue;
    Bool    DoubleFlag;
    Bool    DepthFlag;
    int     DepthSize;
    Bool    AccumFlag;
    int     AccumRed;
    int     AccumGreen;
    int     AccumBlue;
    int     AccumAlpha;
    Bool    AlphaFlag;
    int     AlphaSize;
    Bool    StencilFlag;
    int     StencilSize;
    Bool    PrivateCmapFlag;
    Bool    OverlayFlag;
    Bool    StereoFlag;
#ifdef __sgi
    Bool    OldStereoFlag;
#endif
    int     AuxNumber;
    Bool    Indirect;
    int     PixelFormat;
    const char *ShareList;      /* name (ident) of Togl to share dlists with */
    const char *ShareContext;   /* name (ident) to share OpenGL context with */

    const char *Ident;          /* User's identification string */
    ClientData Client_Data;     /* Pointer to user data */

    Bool    UpdatePending;      /* Should normal planes be redrawn? */

    Togl_Callback *CreateProc;  /* Callback when widget is created */
    Togl_Callback *DisplayProc; /* Callback when widget is rendered */
    Togl_Callback *ReshapeProc; /* Callback when window size changes */
    Togl_Callback *DestroyProc; /* Callback when widget is destroyed */
    Togl_Callback *TimerProc;   /* Callback when widget is idle */

    /* Overlay stuff */
#if defined(TOGL_X11)
    GLXContext OverlayCtx;      /* Overlay planes OpenGL context */
#elif defined(TOGL_WGL)
    HGLRC   tglGLOverlayHglrc;
#endif                          /* TOGL_X11 */

    Window  OverlayWindow;      /* The overlay window, or 0 */
    Togl_Callback *OverlayDisplayProc;  /* Overlay redraw proc */
    Bool    OverlayUpdatePending;       /* Should overlay be redrawn? */
    Colormap OverlayCmap;       /* colormap for overlay is created */
    int     OverlayTransparentPixel;    /* transparent pixel */
    Bool    OverlayIsMapped;

    /* for DumpToEpsFile: Added by Miguel A. de Riera Pasenau 10.01.1997 */
    XVisualInfo *VisInfo;       /* Visual info of the current */
    /* context needed for DumpToEpsFile */
    GLfloat *EpsRedMap;         /* Index2RGB Maps for Color index modes */
    GLfloat *EpsGreenMap;
    GLfloat *EpsBlueMap;
    GLint   EpsMapSize;         /* = Number of indices in our Togl */
};


/* NTNTNT need to change to handle Windows Data Types */
/* 
 * Prototypes for functions local to this file
 */
static int Togl_Cmd(ClientData clientData, Tcl_Interp *interp,
        int argc, CONST84 char **argv);
static void Togl_EventProc(ClientData clientData, XEvent *eventPtr);
static Window Togl_CreateWindow(Tk_Window, Window, ClientData);
static void Togl_WorldChanged(ClientData);

#ifdef MESA_COLOR_HACK
static int get_free_color_cells(Display *display, int screen,
        Colormap colormap);
static void free_default_color_cells(Display *display, Colormap colormap);
#endif
static void ToglCmdDeletedProc(ClientData);



#if defined(__sgi)
/* SGI-only stereo */
static void oldStereoMakeCurrent(Display *dpy, Window win, GLXContext ctx);
static void oldStereoInit(Togl *togl, int stereoEnabled);
#endif

#if defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
static void SetMacBufRect(Togl *togl);
#endif


/* 
 * Setup Togl widget configuration options:
 */

static Tk_ConfigSpec configSpecs[] = {
    {TK_CONFIG_PIXELS, TCL_STUPID "-height", "height", "Height",
            DEFAULT_HEIGHT, Tk_Offset(Togl, Height), 0, NULL},

    {TK_CONFIG_PIXELS, TCL_STUPID "-width", "width", "Width",
            DEFAULT_WIDTH, Tk_Offset(Togl, Width), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-setgrid", "setGrid", "SetGrid",
            "0", Tk_Offset(Togl, SetGrid), 0},

    {TK_CONFIG_BOOLEAN, TCL_STUPID "-rgba", "rgba", "Rgba",
            "true", Tk_Offset(Togl, RgbaFlag), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-redsize", "redsize", "RedSize",
            "1", Tk_Offset(Togl, RgbaRed), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-greensize", "greensize", "GreenSize",
            "1", Tk_Offset(Togl, RgbaGreen), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-bluesize", "bluesize", "BlueSize",
            "1", Tk_Offset(Togl, RgbaBlue), 0, NULL},

    {TK_CONFIG_BOOLEAN, TCL_STUPID "-double", "double", "Double",
            "false", Tk_Offset(Togl, DoubleFlag), 0, NULL},

    {TK_CONFIG_BOOLEAN, TCL_STUPID "-depth", "depth", "Depth",
            "false", Tk_Offset(Togl, DepthFlag), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-depthsize", "depthsize", "DepthSize",
            "1", Tk_Offset(Togl, DepthSize), 0, NULL},

    {TK_CONFIG_BOOLEAN, TCL_STUPID "-accum", "accum", "Accum",
            "false", Tk_Offset(Togl, AccumFlag), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-accumredsize", "accumredsize", "AccumRedSize",
            "1", Tk_Offset(Togl, AccumRed), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-accumgreensize", "accumgreensize",
                "AccumGreenSize",
            "1", Tk_Offset(Togl, AccumGreen), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-accumbluesize", "accumbluesize",
                "AccumBlueSize",
            "1", Tk_Offset(Togl, AccumBlue), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-accumalphasize", "accumalphasize",
                "AccumAlphaSize",
            "1", Tk_Offset(Togl, AccumAlpha), 0, NULL},

    {TK_CONFIG_BOOLEAN, TCL_STUPID "-alpha", "alpha", "Alpha",
            "false", Tk_Offset(Togl, AlphaFlag), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-alphasize", "alphasize", "AlphaSize",
            "1", Tk_Offset(Togl, AlphaSize), 0, NULL},

    {TK_CONFIG_BOOLEAN, TCL_STUPID "-stencil", "stencil", "Stencil",
            "false", Tk_Offset(Togl, StencilFlag), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-stencilsize", "stencilsize", "StencilSize",
            "1", Tk_Offset(Togl, StencilSize), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-auxbuffers", "auxbuffers", "AuxBuffers",
            "0", Tk_Offset(Togl, AuxNumber), 0, NULL},

    {TK_CONFIG_BOOLEAN, TCL_STUPID "-privatecmap", "privateCmap", "PrivateCmap",
            "false", Tk_Offset(Togl, PrivateCmapFlag), 0, NULL},

    {TK_CONFIG_BOOLEAN, TCL_STUPID "-overlay", "overlay", "Overlay",
            "false", Tk_Offset(Togl, OverlayFlag), 0, NULL},

    {TK_CONFIG_BOOLEAN, TCL_STUPID "-stereo", "stereo", "Stereo",
            "false", Tk_Offset(Togl, StereoFlag), 0, NULL},

#ifdef __sgi
    {TK_CONFIG_BOOLEAN, TCL_STUPID "-oldstereo", "oldstereo", "OldStereo",
            "false", Tk_Offset(Togl, OldStereoFlag), 0, NULL},
#endif

#ifndef NO_TK_CURSOR
    {TK_CONFIG_ACTIVE_CURSOR, TCL_STUPID "-cursor", "cursor", "Cursor",
            "", Tk_Offset(Togl, Cursor), TK_CONFIG_NULL_OK},
#endif

    {TK_CONFIG_INT, TCL_STUPID "-time", "time", "Time",
            DEFAULT_TIME, Tk_Offset(Togl, TimerInterval), 0, NULL},

    {TK_CONFIG_STRING, TCL_STUPID "-sharelist", "sharelist", "ShareList",
            NULL, Tk_Offset(Togl, ShareList), 0, NULL},

    {TK_CONFIG_STRING, TCL_STUPID "-sharecontext", "sharecontext",
            "ShareContext", NULL, Tk_Offset(Togl, ShareContext), 0, NULL},

    {TK_CONFIG_STRING, TCL_STUPID "-ident", "ident", "Ident",
            DEFAULT_IDENT, Tk_Offset(Togl, Ident), 0, NULL},

    {TK_CONFIG_BOOLEAN, TCL_STUPID "-indirect", "indirect", "Indirect",
            "false", Tk_Offset(Togl, Indirect), 0, NULL},

    {TK_CONFIG_INT, TCL_STUPID "-pixelformat", "pixelFormat", "PixelFormat",
            "0", Tk_Offset(Togl, PixelFormat), 0, NULL},

    {TK_CONFIG_END, NULL, NULL, NULL, NULL, 0, 0, NULL}
};


/* 
 * Default callback pointers.  When a new Togl widget is created it
 * will be assigned these initial callbacks.
 */
static Togl_Callback *DefaultCreateProc = NULL;
static Togl_Callback *DefaultDisplayProc = NULL;
static Togl_Callback *DefaultReshapeProc = NULL;
static Togl_Callback *DefaultDestroyProc = NULL;
static Togl_Callback *DefaultOverlayDisplayProc = NULL;
static Togl_Callback *DefaultTimerProc = NULL;
static ClientData DefaultClientData = NULL;
static Tcl_HashTable CommandTable;

/* 
 * Head of linked list of all Togl widgets
 */
static Togl *ToglHead = NULL;

/* 
 * Add given togl widget to linked list.
 */
static void
AddToList(Togl *t)
{
    t->Next = ToglHead;
    ToglHead = t;
}

/* 
 * Remove given togl widget from linked list.
 */
static void
RemoveFromList(Togl *t)
{
    Togl   *prev = NULL;
    Togl   *pos = ToglHead;

    while (pos) {
        if (pos == t) {
            if (prev) {
                prev->Next = pos->Next;
            } else {
                ToglHead = pos->Next;
            }
            return;
        }
        prev = pos;
        pos = pos->Next;
    }
}

/* 
 * Return pointer to togl widget given a user identifier string.
 */
static Togl *
FindTogl(const char *ident)
{
    Togl   *t = ToglHead;

    while (t) {
        if (strcmp(t->Ident, ident) == 0)
            return t;
        t = t->Next;
    }
    return NULL;
}


#if defined(TOGL_X11)
/* 
 * Return pointer to another togl widget with same OpenGL context.
 */
static Togl *
FindToglWithSameContext(Togl *togl)
{
    Togl   *t;

    for (t = ToglHead; t != NULL; t = t->Next) {
        if (t == togl)
            continue;
#  if defined(TOGL_WGL)
        if (t->tglGLHglrc == togl->tglGLHglrc)
#  elif defined(TOGL_X11)
        if (t->GlCtx == togl->GlCtx)
#  elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
        if (t->aglCtx == togl->aglCtx)
#  endif
            return t;
    }
    return NULL;
}
#endif

#ifdef USE_OVERLAY
/* 
 * Return pointer to another togl widget with same OpenGL overlay context.
 */
static Togl *
FindToglWithSameOverlayContext(Togl *togl)
{
    Togl   *t;

    for (t = ToglHead; t != NULL; t = t->Next) {
        if (t == togl)
            continue;
#  if defined(TOGL_X11)
        if (t->OverlayCtx == togl->OverlayCtx)
#  elif defined(TOGL_WGL)
        if (t->tglGLOverlayHglrc == togl->tglGLOverlayHglrc)
#  endif
            return t;
    }
    return NULL;
}
#endif

#if defined(TOGL_X11)
/* 
 * Return an X colormap to use for OpenGL RGB-mode rendering.
 * Input:  dpy - the X display
 *         scrnum - the X screen number
 *         visinfo - the XVisualInfo as returned by glXChooseVisual()
 * Return:  an X Colormap or 0 if there's a _serious_ error.
 */
static Colormap
get_rgb_colormap(Display *dpy,
        int scrnum, const XVisualInfo *visinfo, Tk_Window tkwin)
{
    Atom    hp_cr_maps;
    Status  status;
    int     numCmaps;
    int     i;
    XStandardColormap *standardCmaps;
    Window  root = XRootWindow(dpy, scrnum);
    Bool    using_mesa;

    /* 
     * First check if visinfo's visual matches the default/root visual.
     */
    if (visinfo->visual == Tk_Visual(tkwin)) {
        /* use the default/root colormap */
        Colormap cmap;

        cmap = Tk_Colormap(tkwin);
#  ifdef MESA_COLOR_HACK
        (void) get_free_color_cells(dpy, scrnum, cmap);
#  endif
        return cmap;
    }

    /* 
     * Check if we're using Mesa.
     */
    if (strstr(glXQueryServerString(dpy, scrnum, GLX_VERSION), "Mesa")) {
        using_mesa = True;
    } else {
        using_mesa = False;
    }

    /* 
     * Next, if we're using Mesa and displaying on an HP with the "Color
     * Recovery" feature and the visual is 8-bit TrueColor, search for a
     * special colormap initialized for dithering.  Mesa will know how to
     * dither using this colormap.
     */
    if (using_mesa) {
        hp_cr_maps = XInternAtom(dpy, "_HP_RGB_SMOOTH_MAP_LIST", True);
        if (hp_cr_maps
#  ifdef __cplusplus
                && visinfo->visual->c_class == TrueColor
#  else
                && visinfo->visual->class == TrueColor
#  endif
                && visinfo->depth == 8) {
            status = XGetRGBColormaps(dpy, root, &standardCmaps,
                    &numCmaps, hp_cr_maps);
            if (status) {
                for (i = 0; i < numCmaps; i++) {
                    if (standardCmaps[i].visualid == visinfo->visual->visualid) {
                        Colormap cmap = standardCmaps[i].colormap;

                        (void) XFree(standardCmaps);
                        return cmap;
                    }
                }
                (void) XFree(standardCmaps);
            }
        }
    }

    /* 
     * Next, try to find a standard X colormap.
     */
#  if !HP && !SUN
#    ifndef SOLARIS_BUG
    status = XmuLookupStandardColormap(dpy, visinfo->screen,
            visinfo->visualid, visinfo->depth, XA_RGB_DEFAULT_MAP,
            /* replace */ False, /* retain */ True);
    if (status == 1) {
        status = XGetRGBColormaps(dpy, root, &standardCmaps,
                &numCmaps, XA_RGB_DEFAULT_MAP);
        if (status == 1) {
            for (i = 0; i < numCmaps; i++) {
                if (standardCmaps[i].visualid == visinfo->visualid) {
                    Colormap cmap = standardCmaps[i].colormap;

                    (void) XFree(standardCmaps);
                    return cmap;
                }
            }
            (void) XFree(standardCmaps);
        }
    }
#    endif
#  endif

    /* 
     * If we get here, give up and just allocate a new colormap.
     */
    return XCreateColormap(dpy, root, visinfo->visual, AllocNone);
}
#elif defined(TOGL_WGL)

/* Code to create RGB palette is taken from the GENGL sample program of Win32
 * SDK */

static unsigned char threeto8[8] = {
    0, 0111 >> 1, 0222 >> 1, 0333 >> 1, 0444 >> 1, 0555 >> 1, 0666 >> 1, 0377
};

static unsigned char twoto8[4] = {
    0, 0x55, 0xaa, 0xff
};

static unsigned char oneto8[2] = {
    0, 255
};

static int defaultOverride[13] = {
    0, 3, 24, 27, 64, 67, 88, 173, 181, 236, 247, 164, 91
};

static PALETTEENTRY defaultPalEntry[20] = {
    {0, 0, 0, 0},
    {0x80, 0, 0, 0},
    {0, 0x80, 0, 0},
    {0x80, 0x80, 0, 0},
    {0, 0, 0x80, 0},
    {0x80, 0, 0x80, 0},
    {0, 0x80, 0x80, 0},
    {0xC0, 0xC0, 0xC0, 0},

    {192, 220, 192, 0},
    {166, 202, 240, 0},
    {255, 251, 240, 0},
    {160, 160, 164, 0},

    {0x80, 0x80, 0x80, 0},
    {0xFF, 0, 0, 0},
    {0, 0xFF, 0, 0},
    {0xFF, 0xFF, 0, 0},
    {0, 0, 0xFF, 0},
    {0xFF, 0, 0xFF, 0},
    {0, 0xFF, 0xFF, 0},
    {0xFF, 0xFF, 0xFF, 0}
};

static unsigned char
ComponentFromIndex(int i, UINT nbits, UINT shift)
{
    unsigned char val;

    val = (unsigned char) (i >> shift);
    switch (nbits) {

      case 1:
          val &= 0x1;
          return oneto8[val];

      case 2:
          val &= 0x3;
          return twoto8[val];

      case 3:
          val &= 0x7;
          return threeto8[val];

      default:
          return 0;
    }
}

static Colormap
Win32CreateRgbColormap(PIXELFORMATDESCRIPTOR pfd)
{
    TkWinColormap *cmap = (TkWinColormap *) ckalloc(sizeof (TkWinColormap));
    LOGPALETTE *pPal;
    int     n, i;

    n = 1 << pfd.cColorBits;
    pPal = (PLOGPALETTE) LocalAlloc(LMEM_FIXED, sizeof (LOGPALETTE)
            + n * sizeof (PALETTEENTRY));
    pPal->palVersion = 0x300;
    pPal->palNumEntries = n;
    for (i = 0; i < n; i++) {
        pPal->palPalEntry[i].peRed =
                ComponentFromIndex(i, pfd.cRedBits, pfd.cRedShift);
        pPal->palPalEntry[i].peGreen =
                ComponentFromIndex(i, pfd.cGreenBits, pfd.cGreenShift);
        pPal->palPalEntry[i].peBlue =
                ComponentFromIndex(i, pfd.cBlueBits, pfd.cBlueShift);
        pPal->palPalEntry[i].peFlags = 0;
    }

    /* fix up the palette to include the default GDI palette */
    if ((pfd.cColorBits == 8)
            && (pfd.cRedBits == 3) && (pfd.cRedShift == 0)
            && (pfd.cGreenBits == 3) && (pfd.cGreenShift == 3)
            && (pfd.cBlueBits == 2) && (pfd.cBlueShift == 6)) {
        for (i = 1; i <= 12; i++)
            pPal->palPalEntry[defaultOverride[i]] = defaultPalEntry[i];
    }

    cmap->palette = CreatePalette(pPal);
    LocalFree(pPal);
    cmap->size = n;
    cmap->stale = 0;

    /* Since this is a private colormap of a fix size, we do not need a valid
     * hash table, but a dummy one */

    Tcl_InitHashTable(&cmap->refCounts, TCL_ONE_WORD_KEYS);
    return (Colormap) cmap;
}

static Colormap
Win32CreateCiColormap(Togl *togl)
{
    /* Create a colormap with size of togl->CiColormapSize and set all entries
     * to black */

    LOGPALETTE logPalette;
    TkWinColormap *cmap = (TkWinColormap *) ckalloc(sizeof (TkWinColormap));

    logPalette.palVersion = 0x300;
    logPalette.palNumEntries = 1;
    logPalette.palPalEntry[0].peRed = 0;
    logPalette.palPalEntry[0].peGreen = 0;
    logPalette.palPalEntry[0].peBlue = 0;
    logPalette.palPalEntry[0].peFlags = 0;

    cmap->palette = CreatePalette(&logPalette);
    cmap->size = togl->CiColormapSize;
    ResizePalette(cmap->palette, cmap->size);   /* sets new entries to black */
    cmap->stale = 0;

    /* Since this is a private colormap of a fix size, we do not need a valid
     * hash table, but a dummy one */

    Tcl_InitHashTable(&cmap->refCounts, TCL_ONE_WORD_KEYS);
    return (Colormap) cmap;
}
#endif /* TOGL_X11 */



/* 
 * Togl_Init
 *
 *   Called upon system startup to create Togl command.
 */
int
Togl_Init(Tcl_Interp *interp)
{
    int     major, minor, patchLevel, releaseType;

#ifdef USE_TCL_STUBS
    if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
        return TCL_ERROR;
    }
#endif
#ifdef USE_TK_STUBS
    if (Tk_InitStubs(interp, TCL_STUPID "8.1", 0) == NULL) {
        return TCL_ERROR;
    }
#endif

    /* Skip all this on Tcl/Tk 8.0 or older.  Seems to work */
#if TCL_MAJOR_VERSION * 100 + TCL_MINOR_VERSION > 800
    Tcl_GetVersion(&major, &minor, &patchLevel, &releaseType);

#  ifdef HAVE_TK_SETCLASSPROCS
    if (major > 8
            || (major == 8
                    && (minor > 4
                            || (minor == 4 && (releaseType > 0
                                            || patchLevel >= 2))))) {
#    ifdef USE_TK_STUBS
        SetClassProcsPtr = tkStubsPtr->tk_SetClassProcs;
#    else
        SetClassProcsPtr = Tk_SetClassProcs;
#    endif
    } else {
        SetClassProcsPtr = NULL;
    }
#  else
    if (major > 8
            || (major == 8
                    && (minor > 4
                            || (minor == 4 && (releaseType > 0
                                            || patchLevel >= 2))))) {
        TCL_ERR(interp,
                "Sorry, this instance of Togl was not compiled to work with Tcl/Tk 8.4a2 or higher.");
    }
#  endif

#endif

    if (Tcl_PkgProvide(interp, "Togl", TOGL_VERSION) != TCL_OK) {
        return TCL_ERROR;
    }

    if (Tcl_CreateCommand(interp, "togl", Togl_Cmd,
                    (ClientData) Tk_MainWindow(interp), NULL) == NULL)
        return TCL_ERROR;

    Tcl_InitHashTable(&CommandTable, TCL_STRING_KEYS);

    return TCL_OK;
}


/* 
 * Register a C function to be called when an Togl widget is realized.
 */
void
Togl_CreateFunc(Togl_Callback *proc)
{
    DefaultCreateProc = proc;
}


/* 
 * Register a C function to be called when an Togl widget must be redrawn.
 */
void
Togl_DisplayFunc(Togl_Callback *proc)
{
    DefaultDisplayProc = proc;
}


/* 
 * Register a C function to be called when an Togl widget is resized.
 */
void
Togl_ReshapeFunc(Togl_Callback *proc)
{
    DefaultReshapeProc = proc;
}


/* 
 * Register a C function to be called when an Togl widget is destroyed.
 */
void
Togl_DestroyFunc(Togl_Callback *proc)
{
    DefaultDestroyProc = proc;
}


/* 
 * Register a C function to be called from TimerEventHandler.
 */
void
Togl_TimerFunc(Togl_Callback *proc)
{
    DefaultTimerProc = proc;
}


/* 
 * Reset default callback pointers to NULL.
 */
void
Togl_ResetDefaultCallbacks(void)
{
    DefaultCreateProc = NULL;
    DefaultDisplayProc = NULL;
    DefaultReshapeProc = NULL;
    DefaultDestroyProc = NULL;
    DefaultOverlayDisplayProc = NULL;
    DefaultTimerProc = NULL;
    DefaultClientData = NULL;
}


/* 
 * Chnage the create callback for a specific Togl widget.
 */
void
Togl_SetCreateFunc(Togl *togl, Togl_Callback *proc)
{
    togl->CreateProc = proc;
}


/* 
 * Change the display/redraw callback for a specific Togl widget.
 */
void
Togl_SetDisplayFunc(Togl *togl, Togl_Callback *proc)
{
    togl->DisplayProc = proc;
}


/* 
 * Change the reshape callback for a specific Togl widget.
 */
void
Togl_SetReshapeFunc(Togl *togl, Togl_Callback *proc)
{
    togl->ReshapeProc = proc;
}


/* 
 * Change the destroy callback for a specific Togl widget.
 */
void
Togl_SetDestroyFunc(Togl *togl, Togl_Callback *proc)
{
    togl->DestroyProc = proc;
}


/* 
 * Togl_Timer
 *
 * Gets called from Tk_CreateTimerHandler.
 */
static void
Togl_Timer(ClientData clientData)
{
    Togl   *togl = (Togl *) clientData;

    if (togl->TimerProc) {
        togl->TimerProc(togl);

        /* Re-register this callback since Tcl/Tk timers are "one-shot". That
         * is, after the timer callback is called it not normally called again.
         * * * * * * * * * That's not the behavior we want for Togl. */
#if (TK_MAJOR_VERSION * 100 + TK_MINOR_VERSION) >= 401
        togl->timerHandler =
                Tcl_CreateTimerHandler(togl->TimerInterval, Togl_Timer,
                (ClientData) togl);
#else
        togl->timerHandler =
                Tk_CreateTimerHandler(togl->TimeInterval, Togl_Timer,
                (ClientData) togl);
#endif
    }
}


/* 
 * Change the timer callback for a specific Togl widget.
 * Pass NULL to disable the callback.
 */
void
Togl_SetTimerFunc(Togl *togl, Togl_Callback *proc)
{
    togl->TimerProc = proc;
    if (proc) {
#if (TK_MAJOR_VERSION * 100 + TK_MINOR_VERSION) >= 401
        togl->timerHandler =
                Tcl_CreateTimerHandler(togl->TimerInterval, Togl_Timer,
                (ClientData) togl);
#else
        togl->timerHandler =
                Tk_CreateTimerHandler(togl->TimeInterval, Togl_Timer,
                (ClientData) togl);
#endif
    }
}



/* 
 * Togl_CreateCommand
 *
 *   Declares a new C sub-command of Togl callable from Tcl.
 *   Every time the sub-command is called from Tcl, the
 *   C routine will be called with all the arguments from Tcl.
 */
void
Togl_CreateCommand(char *cmd_name, Togl_CmdProc *cmd_proc)
{
    int     new_item;
    Tcl_HashEntry *entry;

    entry = Tcl_CreateHashEntry(&CommandTable, cmd_name, &new_item);
    Tcl_SetHashValue(entry, cmd_proc);
}


/* 
 * Togl_MakeCurrent
 *
 *   Bind the OpenGL rendering context to the specified
 *   Togl widget.
 */
void
Togl_MakeCurrent(const Togl *togl)
{
#if defined(TOGL_WGL)
    int     res = wglMakeCurrent(togl->tglGLHdc, togl->tglGLHglrc);

    assert(res == TRUE);

#elif defined(TOGL_X11)
    if (!togl->GlCtx)
        return;
    (void) glXMakeCurrent(togl->display,
            togl->TkWin ? Tk_WindowId(togl->TkWin) : None, togl->GlCtx);
#  if defined(__sgi)
    if (togl->OldStereoFlag)
        oldStereoMakeCurrent(togl->display,
                togl->TkWin ? Tk_WindowId(togl->TkWin) : None, togl->GlCtx);

#  endif /*__sgi STEREO */

#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    if (!togl->aglCtx)
        return;
    aglSetCurrentContext(togl->aglCtx);
#endif
}


#ifdef TOGL_AGL_CLASSIC
/* tell OpenGL which part of the Mac window to render to */
static void
SetMacBufRect(Togl *togl)
{
    GLint   wrect[4];

    /* set wrect[0,1] to lower left corner of widget */
    wrect[2] = ((TkWindow *) (togl->TkWin))->changes.width;
    wrect[3] = ((TkWindow *) (togl->TkWin))->changes.height;
    wrect[0] = ((TkWindow *) (togl->TkWin))->privatePtr->xOff;
    wrect[1] =
            ((TkWindow *) (togl->TkWin))->privatePtr->toplevel->portPtr->
            portRect.bottom - wrect[3] -
            ((TkWindow *) (togl->TkWin))->privatePtr->yOff;
    aglSetInteger(togl->aglCtx, AGL_BUFFER_RECT, wrect);
    aglEnable(togl->aglCtx, AGL_BUFFER_RECT);
    aglUpdateContext(togl->aglCtx);
}
#elif defined(TOGL_AGL)
/* tell OpenGL which part of the Mac window to render to */
static void
SetMacBufRect(Togl *togl)
{
    GLint   wrect[4];

    /* set wrect[0,1] to lower left corner of widget */
    wrect[2] = Tk_Width(togl->TkWin);
    wrect[3] = Tk_Height(togl->TkWin);
    wrect[0] = ((TkWindow *) (togl->TkWin))->privatePtr->xOff;

    Rect    r;

    GetPortBounds(((TkWindow *) (togl->TkWin))->privatePtr->toplevel->grafPtr,
            &r);

    wrect[1] = r.bottom -
            wrect[3] - ((TkWindow *) (togl->TkWin))->privatePtr->yOff;

    aglSetInteger(togl->aglCtx, AGL_BUFFER_RECT, wrect);
    aglEnable(togl->aglCtx, AGL_BUFFER_RECT);
    aglUpdateContext(togl->aglCtx);
}
#endif

/* 
 * Called when the widget's contents must be redrawn.  Basically, we
 * just call the user's render callback function.
 *
 * Note that the parameter type is ClientData so this function can be
 * passed to Tk_DoWhenIdle().
 */
static void
Togl_Render(ClientData clientData)
{
    Togl   *togl = (Togl *) clientData;

    if (togl->DisplayProc) {

#ifdef TOGL_AGL_CLASSIC
        /* Mac is complicated here because OpenGL needs to know what part of
         * the parent window to render into, and it seems that region need to
         * be invalidated before drawing, so that QuickDraw will allow OpenGL
         * to transfer pixels into that part of the window. I'm not even
         * totally sure how or why this works as it does, since this aspect of
         * Mac OpenGL seems to be totally undocumented. This was put together
         * by trial and error! (thiessen) */
        MacRegion r;
        RgnPtr  rp = &r;
        GrafPtr curPort, parentWin;

        parentWin = (GrafPtr)
                (((MacDrawable *) (Tk_WindowId(togl->TkWin)))->toplevel->
                portPtr);
        if (!parentWin)
            return;
#endif

        Togl_MakeCurrent(togl);

#ifdef TOGL_AGL_CLASSIC
        /* Set QuickDraw port and clipping region */
        GetPort(&curPort);
        SetPort(parentWin);
        r.rgnBBox.left = ((TkWindow *) (togl->TkWin))->privatePtr->xOff;
        r.rgnBBox.right =
                r.rgnBBox.left + ((TkWindow *) (togl->TkWin))->changes.width -
                1;
        r.rgnBBox.top = ((TkWindow *) (togl->TkWin))->privatePtr->yOff;
        r.rgnBBox.bottom =
                r.rgnBBox.top + ((TkWindow *) (togl->TkWin))->changes.height -
                1;
        r.rgnSize = sizeof (Region);
        InvalRgn(&rp);
        SetClip(&rp);
        /* this may seem an odd place to put this, with possibly redundant
         * calls to aglSetInteger(AGL_BUFFER_RECT...), but for some reason
         * performance is actually a lot better if this is called before every
         * render... */
        SetMacBufRect(togl);
#endif

#ifdef TOGL_AGL
        SetMacBufRect(togl);
#endif

        togl->DisplayProc(togl);

#ifdef TOGL_AGL_CLASSIC
        SetPort(curPort);       /* restore previous port */
#endif

    }
#if defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    else {
        /* Always need to update on resize */
        SetMacBufRect(togl);
    }
#endif
    togl->UpdatePending = False;
}


static void
RenderOverlay(ClientData clientData)
{
    Togl   *togl = (Togl *) clientData;

    if (togl->OverlayFlag && togl->OverlayDisplayProc) {

#if defined(TOGL_WGL)
        int     res = wglMakeCurrent(togl->tglGLHdc, togl->tglGLHglrc);

        assert(res == TRUE);

#elif defined(TOGL_X11)
        (void) glXMakeCurrent(Tk_Display(togl->TkWin),
                togl->OverlayWindow, togl->OverlayCtx);
#  if defined(__sgi)
        if (togl->OldStereoFlag)
            oldStereoMakeCurrent(Tk_Display(togl->TkWin),
                    togl->OverlayWindow, togl->OverlayCtx);

#  endif /*__sgi STEREO */

#endif /* TOGL_WGL */

        togl->OverlayDisplayProc(togl);
    }
    togl->OverlayUpdatePending = False;
}


/* 
 * It's possible to change with this function or in a script some
 * options like RGBA - ColorIndex ; Z-buffer and so on
 */
int
Togl_Configure(Tcl_Interp *interp, Togl *togl,
        int argc, const char *argv[], int flags)
{
    Bool    oldRgbaFlag = togl->RgbaFlag;
    int     oldRgbaRed = togl->RgbaRed;
    int     oldRgbaGreen = togl->RgbaGreen;
    int     oldRgbaBlue = togl->RgbaBlue;
    Bool    oldDoubleFlag = togl->DoubleFlag;
    Bool    oldDepthFlag = togl->DepthFlag;
    int     oldDepthSize = togl->DepthSize;
    Bool    oldAccumFlag = togl->AccumFlag;
    int     oldAccumRed = togl->AccumRed;
    int     oldAccumGreen = togl->AccumGreen;
    int     oldAccumBlue = togl->AccumBlue;
    int     oldAccumAlpha = togl->AccumAlpha;
    Bool    oldAlphaFlag = togl->AlphaFlag;
    int     oldAlphaSize = togl->AlphaSize;
    Bool    oldStencilFlag = togl->StencilFlag;
    int     oldStencilSize = togl->StencilSize;
    int     oldAuxNumber = togl->AuxNumber;
    int     oldWidth = togl->Width;
    int     oldHeight = togl->Height;
    int     oldSetGrid = togl->SetGrid;

    if (Tk_ConfigureWidget(interp, togl->TkWin, configSpecs,
                    argc, argv, WIDGREC togl, flags) == TCL_ERROR) {
        return (TCL_ERROR);
    }
#ifndef USE_OVERLAY
    if (togl->OverlayFlag) {
        TCL_ERR(interp, "Sorry, overlay was disabled");
    }
#endif


    if (togl->Width != oldWidth || togl->Height != oldHeight
            || togl->SetGrid != oldSetGrid) {
        Togl_WorldChanged((ClientData) togl);
        /* this added per Lou Arata <arata@enya.picker.com> */
        Tk_ResizeWindow(togl->TkWin, togl->Width, togl->Height);

        if (togl->ReshapeProc &&
#if defined(TOGL_WGL)
                togl->tglGLHglrc
#elif defined(TOGL_X11)
                togl->GlCtx
#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
                togl->aglCtx
#endif
                ) {
            Togl_MakeCurrent(togl);
            togl->ReshapeProc(togl);
        }
    }

    if (togl->RgbaFlag != oldRgbaFlag
            || togl->RgbaRed != oldRgbaRed
            || togl->RgbaGreen != oldRgbaGreen
            || togl->RgbaBlue != oldRgbaBlue
            || togl->DoubleFlag != oldDoubleFlag
            || togl->DepthFlag != oldDepthFlag
            || togl->DepthSize != oldDepthSize
            || togl->AccumFlag != oldAccumFlag
            || togl->AccumRed != oldAccumRed
            || togl->AccumGreen != oldAccumGreen
            || togl->AccumBlue != oldAccumBlue
            || togl->AccumAlpha != oldAccumAlpha
            || togl->AlphaFlag != oldAlphaFlag
            || togl->AlphaSize != oldAlphaSize
            || togl->StencilFlag != oldStencilFlag
            || togl->StencilSize != oldStencilSize
            || togl->AuxNumber != oldAuxNumber) {
#ifdef MESA_COLOR_HACK
        free_default_color_cells(Tk_Display(togl->TkWin),
                Tk_Colormap(togl->TkWin));
#endif
    }
#if defined(__sgi)
    oldStereoInit(togl, togl->OldStereoFlag);
#endif

    return TCL_OK;
}


static int
Togl_Widget(ClientData clientData, Tcl_Interp *interp, int argc,
        CONST84 char *argv[])
{
    Togl   *togl = (Togl *) clientData;
    int     result = TCL_OK;
    Tcl_HashEntry *entry;
    Tcl_HashSearch search;
    Togl_CmdProc *cmd_proc;

    if (argc < 2) {
        Tcl_AppendResult(interp, "wrong # args: should be \"",
                argv[0], " ?options?\"", NULL);
        return TCL_ERROR;
    }

    Tk_Preserve((ClientData) togl);

    if (!strncmp(argv[1], "configure", MAX(1, strlen(argv[1])))) {
        if (argc == 2) {
            /* Return list of all configuration parameters */
            result = Tk_ConfigureInfo(interp, togl->TkWin, configSpecs,
                    WIDGREC togl, (char *) NULL, 0);
        } else if (argc == 3) {
            if (strcmp(argv[2], "-extensions") == 0) {
                /* Return a list of OpenGL extensions available */
                const char *extensions;

                extensions = (const char *) glGetString(GL_EXTENSIONS);
                Tcl_SetResult(interp, TCL_STUPID extensions, TCL_STATIC);
                result = TCL_OK;
            } else {
                /* Return a specific configuration parameter */
                result = Tk_ConfigureInfo(interp, togl->TkWin, configSpecs,
                        WIDGREC togl, argv[2], 0);
            }
        } else {
            /* Execute a configuration change */
            result = Togl_Configure(interp, togl, argc - 2, argv + 2,
                    TK_CONFIG_ARGV_ONLY);
        }
    } else if (!strncmp(argv[1], "render", MAX(1, strlen(argv[1])))) {
        /* force the widget to be redrawn */
        Togl_Render((ClientData) togl);
    } else if (!strncmp(argv[1], "swapbuffers", MAX(1, strlen(argv[1])))) {
        /* force the widget to be redrawn */
        Togl_SwapBuffers(togl);
    } else if (!strncmp(argv[1], "makecurrent", MAX(1, strlen(argv[1])))) {
        /* force the widget to be redrawn */
        Togl_MakeCurrent(togl);
    }
#if TOGL_USE_FONTS == 1
    else if (!strncmp(argv[1], "loadbitmapfont", MAX(1, strlen(argv[1])))) {
        if (argc == 3) {
            GLuint  fontbase;
            Tcl_Obj *fontbaseAsTclObject;

            fontbase = Togl_LoadBitmapFont(togl, argv[2]);
            if (fontbase) {
                fontbaseAsTclObject = Tcl_NewIntObj(fontbase);
                Tcl_SetObjResult(interp, fontbaseAsTclObject);
                result = TCL_OK;
            } else {
                Tcl_AppendResult(interp, "Could not allocate font", NULL);
                result = TCL_ERROR;
            }
        } else {
            Tcl_AppendResult(interp, "wrong # args", NULL);
            result = TCL_ERROR;
        }
    } else if (!strncmp(argv[1], "unloadbitmapfont", MAX(1, strlen(argv[1])))) {
        if (argc == 3) {
            Togl_UnloadBitmapFont(togl, atoi(argv[2]));
            result = TCL_OK;
        } else {
            Tcl_AppendResult(interp, "wrong # args", NULL);
            result = TCL_ERROR;
        }
    }
#endif /* TOGL_USE_FONTS */
    else {
        /* Probably a user-defined function */
        entry = Tcl_FindHashEntry(&CommandTable, argv[1]);
        if (entry != NULL) {
            cmd_proc = (Togl_CmdProc *) Tcl_GetHashValue(entry);
            result = cmd_proc(togl, argc, argv);
        } else {
            Tcl_AppendResult(interp, "Togl: Unknown option: ", argv[1], "\n",
                    "Try: configure or render\n",
                    "or one of the user-defined commands:\n", NULL);
            entry = Tcl_FirstHashEntry(&CommandTable, &search);
            while (entry) {
                Tcl_AppendResult(interp, "  ",
                        Tcl_GetHashKey(&CommandTable, entry), "\n", NULL);
                entry = Tcl_NextHashEntry(&search);
            }
            result = TCL_ERROR;
        }
    }

    Tk_Release((ClientData) togl);
    return result;
}



/* 
 * Togl_Cmd
 *
 *   Called when Togl is executed - creation of a Togl widget.
 *     * Creates a new window
 *     * Creates an 'Togl' data structure
 *     * Creates an event handler for this window
 *     * Creates a command that handles this object
 *     * Configures this Togl for the given arguments
 */
static int
Togl_Cmd(ClientData clientData, Tcl_Interp *interp, int argc,
        CONST84 char **argv)
{
    const char *name;
    Tk_Window mainwin = (Tk_Window) clientData;
    Tk_Window tkwin;
    Togl   *togl;

    if (argc <= 1) {
        TCL_ERR(interp, "wrong # args: should be \"pathName read filename\"");
    }

    /* Create the window. */
    name = argv[1];
    tkwin = Tk_CreateWindowFromPath(interp, mainwin, name, (char *) NULL);
    if (tkwin == NULL) {
        return TCL_ERROR;
    }

    Tk_SetClass(tkwin, "Togl");

    /* Create Togl data structure */
    togl = (Togl *) malloc(sizeof (Togl));
    if (!togl) {
        return TCL_ERROR;
    }

    togl->Next = NULL;
#if defined(TOGL_WGL)
    togl->tglGLHdc = NULL;
    togl->tglGLHglrc = NULL;
#elif defined(TOGL_X11)
    togl->GlCtx = NULL;
    togl->OverlayCtx = NULL;
#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    togl->aglCtx = NULL;
#endif /* TOGL_WGL */
    togl->display = Tk_Display(tkwin);
    togl->TkWin = tkwin;
    togl->Interp = interp;
#ifndef NO_TK_CURSOR
    togl->Cursor = None;
#endif
    togl->Width = 0;
    togl->Height = 0;
    togl->SetGrid = 0;
    togl->TimerInterval = 0;
    togl->RgbaFlag = True;
    togl->RgbaRed = 1;
    togl->RgbaGreen = 1;
    togl->RgbaBlue = 1;
    togl->DoubleFlag = False;
    togl->DepthFlag = False;
    togl->DepthSize = 1;
    togl->AccumFlag = False;
    togl->AccumRed = 1;
    togl->AccumGreen = 1;
    togl->AccumBlue = 1;
    togl->AccumAlpha = 1;
    togl->AlphaFlag = False;
    togl->AlphaSize = 1;
    togl->StencilFlag = False;
    togl->StencilSize = 1;
    togl->OverlayFlag = False;
    togl->StereoFlag = False;
#ifdef __sgi
    togl->OldStereoFlag = False;
#endif
    togl->AuxNumber = 0;
    togl->Indirect = False;
    togl->PixelFormat = 0;
    togl->UpdatePending = False;
    togl->OverlayUpdatePending = False;
    togl->CreateProc = DefaultCreateProc;
    togl->DisplayProc = DefaultDisplayProc;
    togl->ReshapeProc = DefaultReshapeProc;
    togl->DestroyProc = DefaultDestroyProc;
    togl->TimerProc = DefaultTimerProc;
    togl->OverlayDisplayProc = DefaultOverlayDisplayProc;
    togl->ShareList = NULL;
    togl->ShareContext = NULL;
    togl->Ident = NULL;
    togl->Client_Data = DefaultClientData;

    /* for EPS Output */
    togl->EpsRedMap = togl->EpsGreenMap = togl->EpsBlueMap = NULL;
    togl->EpsMapSize = 0;

    /* Create command event handler */
    togl->widgetCmd = Tcl_CreateCommand(interp, Tk_PathName(tkwin),
            Togl_Widget, (ClientData) togl,
            (Tcl_CmdDeleteProc *) ToglCmdDeletedProc);
    /* 
     * Setup the Tk_ClassProcs callbacks to point at our own window creation
     * function
     *
     * We need to check at runtime if we should use the new Tk_SetClassProcs()
     * API or if we need to modify the window structure directly */


#ifdef HAVE_TK_SETCLASSPROCS

    if (SetClassProcsPtr != NULL) {     /* use public API (Tk 8.4+) */
        Tk_ClassProcs *procsPtr;

        procsPtr = (Tk_ClassProcs *) Tcl_Alloc(sizeof (Tk_ClassProcs));
        procsPtr->size = sizeof (Tk_ClassProcs);
        procsPtr->createProc = Togl_CreateWindow;
        procsPtr->worldChangedProc = Togl_WorldChanged;
        procsPtr->modalProc = NULL;
        /* Tk_SetClassProcs(togl->TkWin,procsPtr,(ClientData)togl); */
        (SetClassProcsPtr) (togl->TkWin, procsPtr, (ClientData) togl);
    } else
#endif
    {                           /* use private API */
        /* 
         * We need to set these fields in the Tk_FakeWin structure: dummy17 =
         * classProcsPtr dummy18 = instanceData */
        TkClassProcs *procsPtr;
        Tk_FakeWin *winPtr = (Tk_FakeWin *) (togl->TkWin);

        procsPtr = (TkClassProcs *) Tcl_Alloc(sizeof (TkClassProcs));
        procsPtr->createProc = Togl_CreateWindow;
        procsPtr->geometryProc = Togl_WorldChanged;
        procsPtr->modalProc = NULL;
        winPtr->dummy17 = (char *) procsPtr;
        winPtr->dummy18 = (ClientData) togl;
    }

    Tk_CreateEventHandler(tkwin,
            ExposureMask | StructureNotifyMask, Togl_EventProc,
            (ClientData) togl);

    /* Configure Togl widget */
    if (Togl_Configure(interp, togl, argc - 2, argv + 2, 0) == TCL_ERROR) {
        Tk_DestroyWindow(tkwin);
        Tcl_AppendResult(interp, "Couldn't configure togl widget\n", NULL);
        goto error;
    }

    /* 
     * If OpenGL window wasn't already created by Togl_Configure() we
     * create it now.  We can tell by checking if the GLX context has
     * been initialized.
     */
    if (!
#if defined(TOGL_WGL)
            togl->tglGLHdc
#elif defined(TOGL_X11)
            togl->GlCtx
#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
            togl->aglCtx
#endif
            ) {
        Tk_MakeWindowExist(togl->TkWin);
        if (Tk_WindowId(togl->TkWin) == DUMMY_WINDOW) {
            return TCL_ERROR;
        }
        Togl_MakeCurrent(togl);
    }

    /* If defined, call create callback */
    if (togl->CreateProc) {
        togl->CreateProc(togl);
    }

    /* If defined, call reshape proc */
    if (togl->ReshapeProc) {
        togl->ReshapeProc(togl);
    }

    /* If defined, setup timer */
    if (togl->TimerProc) {
        (void) Tk_CreateTimerHandler(togl->TimerInterval, Togl_Timer,
                (ClientData) togl);
    }

    Tcl_AppendResult(interp, Tk_PathName(tkwin), NULL);

    /* Add to linked list */
    AddToList(togl);

    return TCL_OK;

  error:
    (void) Tcl_DeleteCommand(interp, "togl");
    /* free(togl); Don't free it, if we do a crash occurs later... */
    return TCL_ERROR;
}


#ifdef USE_OVERLAY

/* 
 * Do all the setup for overlay planes
 * Return:   TCL_OK or TCL_ERROR
 */
static int
SetupOverlay(Togl *togl)
{
#  if defined(TOGL_X11)

#    ifdef GLX_TRANSPARENT_TYPE_EXT
    static int ovAttributeList[] = {
        GLX_BUFFER_SIZE, 2,
        GLX_LEVEL, 1,
        GLX_TRANSPARENT_TYPE_EXT, GLX_TRANSPARENT_INDEX_EXT,
        None
    };
#    else
    static int ovAttributeList[] = {
        GLX_BUFFER_SIZE, 2,
        GLX_LEVEL, 1,
        None
    };
#    endif

    Display *dpy;
    XVisualInfo *visinfo;
    TkWindow *winPtr = (TkWindow *) togl->TkWin;

    XSetWindowAttributes swa;
    Tcl_HashEntry *hPtr;
    int     new_flag;

    dpy = Tk_Display(togl->TkWin);

    visinfo = glXChooseVisual(dpy, Tk_ScreenNumber(winPtr), ovAttributeList);
    if (!visinfo) {
        Tcl_AppendResult(togl->Interp, Tk_PathName(winPtr),
                ": No suitable overlay index visual available", (char *) NULL);
        togl->OverlayCtx = 0;
        togl->OverlayWindow = 0;
        togl->OverlayCmap = 0;
        return TCL_ERROR;
    }
#    ifdef GLX_TRANSPARENT_INDEX_EXT
    {
        int     fail =
                glXGetConfig(dpy, visinfo, GLX_TRANSPARENT_INDEX_VALUE_EXT,
                &togl->OverlayTransparentPixel);

        if (fail)
            togl->OverlayTransparentPixel = 0;  /* maybe, maybe ... */
    }
#    else
    togl->OverlayTransparentPixel = 0;  /* maybe, maybe ... */
#    endif

    /* share display lists with normal layer context */
    togl->OverlayCtx =
            glXCreateContext(dpy, visinfo, togl->GlCtx, !togl->Indirect);

    swa.colormap = XCreateColormap(dpy, XRootWindow(dpy, visinfo->screen),
            visinfo->visual, AllocNone);
    togl->OverlayCmap = swa.colormap;

    swa.border_pixel = 0;
    swa.event_mask = ALL_EVENTS_MASK;
    togl->OverlayWindow = XCreateWindow(dpy, Tk_WindowId(togl->TkWin), 0, 0,
            togl->Width, togl->Height, 0,
            visinfo->depth, InputOutput,
            visinfo->visual, CWBorderPixel | CWColormap | CWEventMask, &swa);

    hPtr = Tcl_CreateHashEntry(&winPtr->dispPtr->winTable,
            (char *) togl->OverlayWindow, &new_flag);
    Tcl_SetHashValue(hPtr, winPtr);

    /* XMapWindow( dpy, togl->OverlayWindow ); */
    togl->OverlayIsMapped = False;

    /* Make sure window manager installs our colormap */
    XSetWMColormapWindows(dpy, togl->OverlayWindow, &togl->OverlayWindow, 1);

    return TCL_OK;

#  elif defined(TOGL_WGL) || defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    /* not yet implemented on these */
    return TCL_ERROR;
#  endif
}

#endif /* USE_OVERLAY */



#ifdef TOGL_WGL
#  define TOGL_CLASS_NAME "Togl Class"
static Bool ToglClassInitialized = False;

static LRESULT CALLBACK
Win32WinProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    LONG    result;
    Togl   *togl = (Togl *) GetWindowLong(hwnd, 0);
    WNDCLASS childClass;

    switch (message) {
      case WM_WINDOWPOSCHANGED:
          /* Should be processed by DefWindowProc, otherwise a double buffered
           * context is not properly resized when the corresponding window is
           * resized. */
          break;
      case WM_DESTROY:
          if (togl->tglGLHglrc) {
              wglDeleteContext(togl->tglGLHglrc);
          }
          if (togl->tglGLHdc) {
              ReleaseDC(hwnd, togl->tglGLHdc);
          }
          free(togl);
          break;
      default:
#  if USE_STATIC_LIB
          return TkWinChildProc(hwnd, message, wParam, lParam);
#  else
          /* 
           * OK, since TkWinChildProc is not explicitly exported in the
           * dynamic libraries, we have to retrieve it from the class info
           * registered with windows.
           *
           */
          if (tkWinChildProc == NULL) {
              GetClassInfo(Tk_GetHINSTANCE(), TK_WIN_CHILD_CLASS_NAME,
                      &childClass);
              tkWinChildProc = childClass.lpfnWndProc;
          }
          return tkWinChildProc(hwnd, message, wParam, lParam);
#  endif
    }
    result = DefWindowProc(hwnd, message, wParam, lParam);
    Tcl_ServiceAll();
    return result;
}
#endif /* TOGL_WGL */



/* 
 * Togl_CreateWindow
 *
 *   Window creation function, invoked as a callback from Tk_MakeWindowExist.
 *   Creates an OpenGL window for the Togl widget.
 */
static Window
Togl_CreateWindow(Tk_Window tkwin, Window parent, ClientData instanceData)
{

    Togl   *togl = (Togl *) instanceData;
    XVisualInfo *visinfo = NULL;
    Display *dpy;
    Colormap cmap;
    int     scrnum;
    Window  window;

#if defined(TOGL_X11)
    Bool    directCtx = True;
    int     attrib_list[1000];
    int     attrib_count;
    int     dummy;
    XSetWindowAttributes swa;

#  define MAX_ATTEMPTS 12
    static int ci_depths[MAX_ATTEMPTS] = {
        8, 4, 2, 1, 12, 16, 8, 4, 2, 1, 12, 16
    };
    static int dbl_flags[MAX_ATTEMPTS] = {
        0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1
    };
#elif defined(TOGL_WGL)
    HWND    hwnd, parentWin;
    int     pixelformat;
    HANDLE  hInstance;
    WNDCLASS ToglClass;
    PIXELFORMATDESCRIPTOR pfd;
    XVisualInfo VisInf;
#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    GLint   attribs[20];
    int     na;
    AGLPixelFormat fmt;
    XVisualInfo VisInf;
#endif /* TOGL_X11 */


    dpy = Tk_Display(togl->TkWin);

#if defined(TOGL_X11)
    /* Make sure OpenGL's GLX extension supported */
    if (!glXQueryExtension(dpy, &dummy, &dummy)) {
        Tcl_SetResult(togl->Interp,
                TCL_STUPID "Togl: X server has no OpenGL GLX extension",
                TCL_STATIC);
        return DUMMY_WINDOW;
    }

    if (togl->ShareContext && FindTogl(togl->ShareContext)) {
        /* share OpenGL context with existing Togl widget */
        Togl   *shareWith = FindTogl(togl->ShareContext);

        assert(shareWith != NULL);
        assert(shareWith->GlCtx != NULL);
        togl->GlCtx = shareWith->GlCtx;
        togl->VisInfo = shareWith->VisInfo;
        visinfo = togl->VisInfo;
    } else {
        if (togl->PixelFormat) {
            XVisualInfo template;
            int     count = 1;

            template.visualid = togl->PixelFormat;
            visinfo = XGetVisualInfo(dpy, VisualIDMask, &template, &count);
            if (visinfo == NULL) {
                Tcl_SetResult(togl->Interp,
                        TCL_STUPID "Togl: couldn't choose pixel format",
                        TCL_STATIC);

                return DUMMY_WINDOW;
            }
            /* fill in flags normally passed in that affect behavior */
            (void) glXGetConfig(dpy, visinfo, GLX_RGBA, &togl->RgbaFlag);
            (void) glXGetConfig(dpy, visinfo, GLX_DOUBLEBUFFER,
                    &togl->DoubleFlag);
            (void) glXGetConfig(dpy, visinfo, GLX_STEREO, &togl->StereoFlag);
        } else {
            int     attempt;

            /* It may take a few tries to get a visual */
            for (attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
                attrib_count = 0;
                attrib_list[attrib_count++] = GLX_USE_GL;
                if (togl->RgbaFlag) {
                    /* RGB[A] mode */
                    attrib_list[attrib_count++] = GLX_RGBA;
                    attrib_list[attrib_count++] = GLX_RED_SIZE;
                    attrib_list[attrib_count++] = togl->RgbaRed;
                    attrib_list[attrib_count++] = GLX_GREEN_SIZE;
                    attrib_list[attrib_count++] = togl->RgbaGreen;
                    attrib_list[attrib_count++] = GLX_BLUE_SIZE;
                    attrib_list[attrib_count++] = togl->RgbaBlue;
                    if (togl->AlphaFlag) {
                        attrib_list[attrib_count++] = GLX_ALPHA_SIZE;
                        attrib_list[attrib_count++] = togl->AlphaSize;
                    }

                    /* for EPS Output */
                    if (togl->EpsRedMap)
                        free(togl->EpsRedMap);
                    if (togl->EpsGreenMap)
                        free(togl->EpsGreenMap);
                    if (togl->EpsBlueMap)
                        free(togl->EpsBlueMap);
                    togl->EpsRedMap = togl->EpsGreenMap = togl->EpsBlueMap =
                            NULL;
                    togl->EpsMapSize = 0;
                } else {
                    /* Color index mode */
                    int     depth;

                    attrib_list[attrib_count++] = GLX_BUFFER_SIZE;
                    depth = ci_depths[attempt];
                    attrib_list[attrib_count++] = depth;
                }
                if (togl->DepthFlag) {
                    attrib_list[attrib_count++] = GLX_DEPTH_SIZE;
                    attrib_list[attrib_count++] = togl->DepthSize;
                }
                if (togl->DoubleFlag || dbl_flags[attempt]) {
                    attrib_list[attrib_count++] = GLX_DOUBLEBUFFER;
                }
                if (togl->StencilFlag) {
                    attrib_list[attrib_count++] = GLX_STENCIL_SIZE;
                    attrib_list[attrib_count++] = togl->StencilSize;
                }
                if (togl->AccumFlag) {
                    attrib_list[attrib_count++] = GLX_ACCUM_RED_SIZE;
                    attrib_list[attrib_count++] = togl->AccumRed;
                    attrib_list[attrib_count++] = GLX_ACCUM_GREEN_SIZE;
                    attrib_list[attrib_count++] = togl->AccumGreen;
                    attrib_list[attrib_count++] = GLX_ACCUM_BLUE_SIZE;
                    attrib_list[attrib_count++] = togl->AccumBlue;
                    if (togl->AlphaFlag) {
                        attrib_list[attrib_count++] = GLX_ACCUM_ALPHA_SIZE;
                        attrib_list[attrib_count++] = togl->AccumAlpha;
                    }
                }
                if (togl->AuxNumber != 0) {
                    attrib_list[attrib_count++] = GLX_AUX_BUFFERS;
                    attrib_list[attrib_count++] = togl->AuxNumber;
                }
                if (togl->Indirect) {
                    directCtx = False;
                }

                if (togl->StereoFlag) {
                    attrib_list[attrib_count++] = GLX_STEREO;
                }
                attrib_list[attrib_count++] = None;

                visinfo = glXChooseVisual(dpy, Tk_ScreenNumber(togl->TkWin),
                        attrib_list);
                if (visinfo) {
                    /* found a GLX visual! */
                    break;
                }
            }

            togl->VisInfo = visinfo;

            if (visinfo == NULL) {
                Tcl_SetResult(togl->Interp,
                        TCL_STUPID "Togl: couldn't get visual", TCL_STATIC);
                return DUMMY_WINDOW;
            }

            /* 
             * Create a new OpenGL rendering context.
             */
            if (togl->ShareList) {
                /* share display lists with existing togl widget */
                Togl   *shareWith = FindTogl(togl->ShareList);
                GLXContext shareCtx;

                if (shareWith)
                    shareCtx = shareWith->GlCtx;
                else
                    shareCtx = None;
                togl->GlCtx =
                        glXCreateContext(dpy, visinfo, shareCtx, directCtx);
            } else {
                /* don't share display lists */
                togl->GlCtx = glXCreateContext(dpy, visinfo, None, directCtx);
            }

            if (togl->GlCtx == NULL) {
                Tcl_SetResult(togl->Interp,
                        TCL_STUPID "could not create rendering context",
                        TCL_STATIC);
                return DUMMY_WINDOW;
            }

        }
    }


#endif /* TOGL_X11 */

#ifdef TOGL_WGL
    parentWin = Tk_GetHWND(parent);
    hInstance = Tk_GetHINSTANCE();
    if (!ToglClassInitialized) {
        ToglClassInitialized = True;
        ToglClass.style = CS_HREDRAW | CS_VREDRAW;
        ToglClass.cbClsExtra = 0;
        ToglClass.cbWndExtra = 4;       /* to save struct Togl* */
        ToglClass.hInstance = hInstance;
        ToglClass.hbrBackground = NULL;
        ToglClass.lpszMenuName = NULL;
        ToglClass.lpszClassName = TOGL_CLASS_NAME;
        ToglClass.lpfnWndProc = Win32WinProc;
        ToglClass.hIcon = NULL;
        ToglClass.hCursor = NULL;
        if (!RegisterClass(&ToglClass)) {
            Tcl_SetResult(togl->Interp,
                    TCL_STUPID "unable register Togl window class", TCL_STATIC);
            return DUMMY_WINDOW;
        }
    }

    hwnd = CreateWindow(TOGL_CLASS_NAME, NULL,
            WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS, 0, 0,
            togl->Width, togl->Height, parentWin, NULL, hInstance, NULL);
    SetWindowLong(hwnd, 0, (LONG) togl);
    SetWindowPos(hwnd, HWND_TOP, 0, 0, 0, 0,
            SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE);

    togl->tglGLHdc = GetDC(hwnd);

    pfd.nSize = sizeof (PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL;
    if (togl->DoubleFlag) {
        pfd.dwFlags |= PFD_DOUBLEBUFFER;
    }
    /* The stereo flag is not supported in the current generic OpenGL
     * implementation, but may be supported by specific hardware devices. */
    if (togl->StereoFlag) {
        pfd.dwFlags |= PFD_STEREO;
    }

    if (togl->PixelFormat) {
        pixelformat = togl->PixelFormat;
    } else {
        pfd.cColorBits = togl->RgbaRed + togl->RgbaGreen + togl->RgbaBlue;
        pfd.iPixelType = togl->RgbaFlag ? PFD_TYPE_RGBA : PFD_TYPE_COLORINDEX;
        /* Alpha bitplanes are not supported in the current generic OpenGL
         * implementation, but may be supported by specific hardware devices. */
        pfd.cAlphaBits = togl->AlphaFlag ? togl->AlphaSize : 0;
        pfd.cAccumBits = togl->AccumFlag ? (togl->AccumRed + togl->AccumGreen +
                togl->AccumBlue + togl->AccumAlpha) : 0;
        pfd.cDepthBits = togl->DepthFlag ? togl->DepthSize : 0;
        pfd.cStencilBits = togl->StencilFlag ? togl->StencilSize : 0;
        /* Auxiliary buffers are not supported in the current generic OpenGL
         * implementation, but may be supported by specific hardware devices. */
        pfd.cAuxBuffers = togl->AuxNumber;
        pfd.iLayerType = PFD_MAIN_PLANE;

        if ((pixelformat = ChoosePixelFormat(togl->tglGLHdc, &pfd)) == 0) {
            Tcl_SetResult(togl->Interp,
                    TCL_STUPID "Togl: couldn't choose pixel format",
                    TCL_STATIC);
            return DUMMY_WINDOW;
        }
    }
    if (SetPixelFormat(togl->tglGLHdc, pixelformat, &pfd) == FALSE) {
        Tcl_SetResult(togl->Interp,
                TCL_STUPID "Togl: couldn't choose pixel format", TCL_STATIC);
        return DUMMY_WINDOW;
    }

    /* Get the actual pixel format */
    DescribePixelFormat(togl->tglGLHdc, pixelformat, sizeof (pfd), &pfd);
    if (togl->PixelFormat) {
        /* fill in flags normally passed in that affect behavior */
        togl->RgbaFlag = pfd.iPixelType == PFD_TYPE_RGBA;
        togl->DoubleFlag = pfd.cDepthBits > 0;
        togl->StereoFlag = (pfd.dwFlags & PFD_STEREO) != 0;
        // TODO: set depth flag, and more
    } else if (togl->StereoFlag && (pfd.dwFlags & PFD_STEREO) == 0) {
        Tcl_SetResult(togl->Interp,
                TCL_STUPID "Togl: couldn't choose stereo pixel format",
                TCL_STATIC);
        return DUMMY_WINDOW;
    }

    if (togl->ShareContext && FindTogl(togl->ShareContext)) {
        /* share OpenGL context with existing Togl widget */
        Togl   *shareWith = FindTogl(togl->ShareContext);

        assert(shareWith);
        assert(shareWith->tglGLHglrc);
        togl->tglGLHglrc = shareWith->tglGLHglrc;
        togl->VisInfo = shareWith->VisInfo;
        visinfo = togl->VisInfo;
    } else {
        /* 
         * Create a new OpenGL rendering context. And check to share lists.
         */
        togl->tglGLHglrc = wglCreateContext(togl->tglGLHdc);

        if (togl->ShareList) {
            /* share display lists with existing togl widget */
            Togl   *shareWith = FindTogl(togl->ShareList);

            if (shareWith)
                wglShareLists(shareWith->tglGLHglrc, togl->tglGLHglrc);
        }

        if (!togl->tglGLHglrc) {
            Tcl_SetResult(togl->Interp,
                    TCL_STUPID "could not create rendering context",
                    TCL_STATIC);
            return DUMMY_WINDOW;
        }

        /* Just for portability, define the simplest visinfo */
        visinfo = &VisInf;
        visinfo->visual = DefaultVisual(dpy, DefaultScreen(dpy));
        visinfo->depth = visinfo->visual->bits_per_rgb;
        togl->VisInfo = visinfo;
    }

#endif /* TOGL_WGL */


    /* 
     * find a colormap
     */
    scrnum = Tk_ScreenNumber(togl->TkWin);
    if (togl->RgbaFlag) {
        /* Colormap for RGB mode */
#if defined(TOGL_X11)
        cmap = get_rgb_colormap(dpy, scrnum, visinfo, togl->TkWin);

#elif defined(TOGL_WGL)
        if (pfd.dwFlags & PFD_NEED_PALETTE) {
            cmap = Win32CreateRgbColormap(pfd);
        } else {
            cmap = DefaultColormap(dpy, scrnum);
        }
        /* for EPS Output */
        if (togl->EpsRedMap)
            free(togl->EpsRedMap);
        if (togl->EpsGreenMap)
            free(togl->EpsGreenMap);
        if (togl->EpsBlueMap)
            free(togl->EpsBlueMap);
        togl->EpsRedMap = togl->EpsGreenMap = togl->EpsBlueMap = NULL;
        togl->EpsMapSize = 0;

#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
        cmap = DefaultColormap(dpy, scrnum);
        /* for EPS Output */
        if (togl->EpsRedMap)
            free(togl->EpsRedMap);
        if (togl->EpsGreenMap)
            free(togl->EpsGreenMap);
        if (togl->EpsBlueMap)
            free(togl->EpsBlueMap);
        togl->EpsRedMap = togl->EpsGreenMap = togl->EpsBlueMap = NULL;
        togl->EpsMapSize = 0;
#endif /* TOGL_X11 */
    } else {
        /* Colormap for CI mode */
#ifdef TOGL_WGL
        togl->CiColormapSize = 1 << pfd.cColorBits;
        togl->CiColormapSize = togl->CiColormapSize < MAX_CI_COLORMAP_SIZE ?
                togl->CiColormapSize : MAX_CI_COLORMAP_SIZE;

#endif /* TOGL_WGL */
        if (togl->PrivateCmapFlag) {
            /* need read/write colormap so user can store own color entries */
#if defined(TOGL_X11)
            cmap = XCreateColormap(dpy, XRootWindow(dpy, visinfo->screen),
                    visinfo->visual, AllocAll);
#elif defined(TOGL_WGL)
            cmap = Win32CreateCiColormap(togl);
#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
            /* need to figure out how to do this correctly on Mac... */
            cmap = DefaultColormap(dpy, scrnum);
#endif /* TOGL_X11 */
        } else {
            if (visinfo->visual == DefaultVisual(dpy, scrnum)) {
                /* share default/root colormap */
                cmap = Tk_Colormap(togl->TkWin);
            } else {
                /* make a new read-only colormap */
                cmap = XCreateColormap(dpy, XRootWindow(dpy, visinfo->screen),
                        visinfo->visual, AllocNone);
            }
        }
    }

#if !defined(TOGL_AGL)
    /* Make sure Tk knows to switch to the new colormap when the cursor is over
     * this window when running in color index mode. */
    (void) Tk_SetWindowVisual(togl->TkWin, visinfo->visual, visinfo->depth,
            cmap);
#endif

#ifdef TOGL_WGL
    /* Install the colormap */
    SelectPalette(togl->tglGLHdc, ((TkWinColormap *) cmap)->palette, TRUE);
    RealizePalette(togl->tglGLHdc);
#endif /* TOGL_WGL */

#if defined(TOGL_X11)
    swa.colormap = cmap;
    swa.border_pixel = 0;
    swa.event_mask = ALL_EVENTS_MASK;
    window = XCreateWindow(dpy, parent,
            0, 0, togl->Width, togl->Height,
            0, visinfo->depth,
            InputOutput, visinfo->visual,
            CWBorderPixel | CWColormap | CWEventMask, &swa);
    /* Make sure window manager installs our colormap */
    (void) XSetWMColormapWindows(dpy, window, &window, 1);

#elif defined(TOGL_WGL)
    window = Tk_AttachHWND(togl->TkWin, hwnd);

#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    {
        TkWindow *winPtr = (TkWindow *) togl->TkWin;

        window = TkpMakeWindow(winPtr, parent);
    }
#endif /* TOGL_X11 */

#ifdef USE_OVERLAY
    if (togl->OverlayFlag) {
        if (SetupOverlay(togl) == TCL_ERROR) {
            fprintf(stderr, "Warning: couldn't setup overlay.\n");
            togl->OverlayFlag = False;
        }
    }
#endif /* USE_OVERLAY */

    /* Request the X window to be displayed */
    (void) XMapWindow(dpy, window);

#if defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    if (togl->ShareContext && FindTogl(togl->ShareContext)) {
        /* share OpenGL context with existing Togl widget */
        Togl   *shareWith = FindTogl(togl->ShareContext);

        assert(shareWith);
        assert(shareWith->aglCtx);
        togl->aglCtx = shareWith->aglCtx;
        togl->VisInfo = shareWith->VisInfo;
        visinfo = togl->VisInfo;

    } else {
        AGLContext shareCtx = NULL;

        if (togl->PixelFormat) {
            /* fill in RgbaFlag, DoubleFlag, and StereoFlag */
            fmt = (AGLPixelFormat) togl->PixelFormat;
            GLint   has_rgba, has_doublebuf, has_stereo;

            if (aglDescribePixelFormat(fmt, AGL_RGBA, &has_rgba) &&
                    aglDescribePixelFormat(fmt, AGL_DOUBLEBUFFER,
                            &has_doublebuf)
                    && aglDescribePixelFormat(fmt, AGL_STEREO, &has_stereo)) {
                togl->RgbaFlag = (has_rgba ? True : False);
                togl->DoubleFlag = (has_doublebuf ? True : False);
                togl->StereoFlag = (has_stereo ? True : False);
            } else {
                Tcl_SetResult(togl->Interp,
                        TCL_STUPID
                        "Togl: failed querying pixel format attributes",
                        TCL_STATIC);
                return DUMMY_WINDOW;
            }
        } else {

            /* Need to do this after mapping window, so MacDrawable structure
             * is more completely filled in */
            na = 0;
            attribs[na++] = AGL_MINIMUM_POLICY;
            attribs[na++] = AGL_ROBUST;
            if (togl->RgbaFlag) {
                /* RGB[A] mode */
                attribs[na++] = AGL_RGBA;
                attribs[na++] = AGL_RED_SIZE;
                attribs[na++] = togl->RgbaRed;
                attribs[na++] = AGL_GREEN_SIZE;
                attribs[na++] = togl->RgbaGreen;
                attribs[na++] = AGL_BLUE_SIZE;
                attribs[na++] = togl->RgbaBlue;
                if (togl->AlphaFlag) {
                    attribs[na++] = AGL_ALPHA_SIZE;
                    attribs[na++] = togl->AlphaSize;
                }
            } else {
                /* Color index mode */
                attribs[na++] = AGL_BUFFER_SIZE;
                attribs[na++] = 8;
            }
            if (togl->DepthFlag) {
                attribs[na++] = AGL_DEPTH_SIZE;
                attribs[na++] = togl->DepthSize;
            }
            if (togl->DoubleFlag) {
                attribs[na++] = AGL_DOUBLEBUFFER;
            }
            if (togl->StencilFlag) {
                attribs[na++] = AGL_STENCIL_SIZE;
                attribs[na++] = togl->StencilSize;
            }
            if (togl->AccumFlag) {
                attribs[na++] = AGL_ACCUM_RED_SIZE;
                attribs[na++] = togl->AccumRed;
                attribs[na++] = AGL_ACCUM_GREEN_SIZE;
                attribs[na++] = togl->AccumGreen;
                attribs[na++] = AGL_ACCUM_BLUE_SIZE;
                attribs[na++] = togl->AccumBlue;
                if (togl->AlphaFlag) {
                    attribs[na++] = AGL_ACCUM_ALPHA_SIZE;
                    attribs[na++] = togl->AccumAlpha;
                }
            }
            if (togl->AuxNumber != 0) {
                attribs[na++] = AGL_AUX_BUFFERS;
                attribs[na++] = togl->AuxNumber;
            }
            attribs[na++] = AGL_NONE;

            if ((fmt = aglChoosePixelFormat(NULL, 0, attribs)) == NULL) {
                Tcl_SetResult(togl->Interp,
                        TCL_STUPID "Togl: couldn't choose pixel format",
                        TCL_STATIC);
                return DUMMY_WINDOW;
            }
        }

        /* 
         * Check whether to share lists.
         */
        if (togl->ShareList) {
            /* share display lists with existing togl widget */
            Togl   *shareWith = FindTogl(togl->ShareList);

            if (shareWith)
                shareCtx = shareWith->aglCtx;
        }
        if ((togl->aglCtx = aglCreateContext(fmt, shareCtx)) == NULL) {
            GLenum  err = aglGetError();

            aglDestroyPixelFormat(fmt);
            if (err == AGL_BAD_MATCH)
                Tcl_SetResult(togl->Interp,
                        TCL_STUPID
                        "Togl: couldn't create context, shared context doesn't match",
                        TCL_STATIC);
            else if (err == AGL_BAD_CONTEXT)
                Tcl_SetResult(togl->Interp,
                        TCL_STUPID
                        "Togl: couldn't create context, bad shared context",
                        TCL_STATIC);
            else if (err == AGL_BAD_PIXELFMT)
                Tcl_SetResult(togl->Interp,
                        TCL_STUPID
                        "Togl: couldn't create context, bad pixel format",
                        TCL_STATIC);
            else
                Tcl_SetResult(togl->Interp,
                        TCL_STUPID
                        "Togl: couldn't create context, unknown reason",
                        TCL_STATIC);
            return DUMMY_WINDOW;
        }

        aglDestroyPixelFormat(fmt);
        if (!aglSetDrawable(togl->aglCtx,
#  if defined(TOGL_AGL)
                        ((MacDrawable *) (window))->toplevel->grafPtr
#  else
                        ((MacDrawable *) (window))->toplevel->portPtr
#  endif
                )) {
            aglDestroyContext(togl->aglCtx);
            Tcl_SetResult(togl->Interp,
                    TCL_STUPID "Togl: couldn't set drawable", TCL_STATIC);
            return DUMMY_WINDOW;
        }

        /* Just for portability, define the simplest visinfo */
        visinfo = &VisInf;
        visinfo->visual = DefaultVisual(dpy, DefaultScreen(dpy));
        visinfo->depth = visinfo->visual->bits_per_rgb;

        Tk_SetWindowVisual(togl->TkWin, visinfo->visual, visinfo->depth, cmap);
    }
#endif /* TOGL_AGL_CLASSIC || TOGL_AGL */

#if defined(TOGL_X11)
    /* Check for a single/double buffering snafu */
    {
        int     dbl_flag;

        if (glXGetConfig(dpy, visinfo, GLX_DOUBLEBUFFER, &dbl_flag)) {
            if (!togl->DoubleFlag && dbl_flag) {
                /* We requested single buffering but had to accept a */
                /* double buffered visual.  Set the GL draw buffer to */
                /* be the front buffer to simulate single buffering. */
                glDrawBuffer(GL_FRONT);
            }
        }
    }
#endif /* TOGL_X11 */

    /* for EPS Output */
    if (!togl->RgbaFlag) {
        int     index_size;

#if defined(TOGL_X11) || defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
        GLint   index_bits;

        glGetIntegerv(GL_INDEX_BITS, &index_bits);
        index_size = 1 << index_bits;
#elif defined(TOGL_WGL)
        index_size = togl->CiColormapSize;
#endif /* TOGL_X11 */
        if (togl->EpsMapSize != index_size) {
            if (togl->EpsRedMap)
                free(togl->EpsRedMap);
            if (togl->EpsGreenMap)
                free(togl->EpsGreenMap);
            if (togl->EpsBlueMap)
                free(togl->EpsBlueMap);
            togl->EpsMapSize = index_size;
            togl->EpsRedMap = (GLfloat *) calloc(index_size, sizeof (GLfloat));
            togl->EpsGreenMap =
                    (GLfloat *) calloc(index_size, sizeof (GLfloat));
            togl->EpsBlueMap = (GLfloat *) calloc(index_size, sizeof (GLfloat));
        }
    }

    return window;
}

/* 
 * Togl_WorldChanged
 *
 *    Add support for setgrid option.
 */
static void
Togl_WorldChanged(ClientData instanceData)
{
    Togl   *togl = (Togl *) instanceData;

    Tk_GeometryRequest(togl->TkWin, togl->Width, togl->Height);
    Tk_SetInternalBorder(togl->TkWin, 0);
    if (togl->SetGrid > 0) {
        Tk_SetGrid(togl->TkWin, togl->Width / togl->SetGrid,
                togl->Height / togl->SetGrid, togl->SetGrid, togl->SetGrid);
    } else {
        Tk_UnsetGrid(togl->TkWin);
    }
}

/* 
 * ToglCmdDeletedProc
 *
 *      This procedure is invoked when a widget command is deleted.  If
 *      the widget isn't already in the process of being destroyed,
 *      this command destroys it.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      The widget is destroyed.
 *
 *----------------------------------------------------------------------
 */
static void
ToglCmdDeletedProc(ClientData clientData)
{
    Togl   *togl = (Togl *) clientData;
    Tk_Window tkwin = togl->TkWin;

    /* 
     * This procedure could be invoked either because the window was
     * destroyed and the command was then deleted (in which case tkwin
     * is NULL) or because the command was deleted, and then this procedure
     * destroys the widget.
     */

    if (togl && tkwin) {
        Tk_DeleteEventHandler(tkwin,
                ExposureMask | StructureNotifyMask,
                Togl_EventProc, (ClientData) togl);
    }
#if defined(TOGL_X11)
    if (togl->GlCtx) {
        if (FindToglWithSameContext(togl) == NULL)
            glXDestroyContext(togl->display, togl->GlCtx);
        togl->GlCtx = NULL;
    }
#  ifdef USE_OVERLAY
    if (togl->OverlayCtx) {
        Tcl_HashEntry *entryPtr;
        TkWindow *winPtr = (TkWindow *) togl->TkWin;

        if (winPtr) {
            entryPtr = Tcl_FindHashEntry(&winPtr->dispPtr->winTable,
                    (char *) togl->OverlayWindow);
            Tcl_DeleteHashEntry(entryPtr);
        }
        if (FindToglWithSameOverlayContext(togl) == NULL)
            glXDestroyContext(togl->display, togl->OverlayCtx);
        togl->OverlayCtx = NULL;
    }
#  endif /* USE_OVERLAY */
#endif
    /* TODO: delete contexts on other platforms */

    if (tkwin != NULL) {
        if (togl->SetGrid > 0) {
            Tk_UnsetGrid(tkwin);
        }
        togl->TkWin = NULL;
        Tk_DestroyWindow(tkwin);
    }
}


/* 
 * Togl_Destroy
 *
 * Gets called when an Togl widget is destroyed.
 */
static void
Togl_Destroy(
#if (TK_MAJOR_VERSION * 100 + TK_MINOR_VERSION) >= 401
        char *
#else
        ClientData
#endif
        clientData)
{
    Togl   *togl = (Togl *) clientData;

    Tk_FreeOptions(configSpecs, WIDGREC togl, togl->display, 0);

#ifndef NO_TK_CURSOR
    if (togl->Cursor != None) {
        Tk_FreeCursor(togl->display, togl->Cursor);
    }
#endif
    if (togl->DestroyProc) {
        togl->DestroyProc(togl);
    }

    /* remove from linked list */
    RemoveFromList(togl);

#if !defined(TOGL_WGL)
    /* TODO: why not on Windows? */
    free(togl);
#endif
}



/* 
 * This gets called to handle Togl window configuration events
 */
static void
Togl_EventProc(ClientData clientData, XEvent *eventPtr)
{
    Togl   *togl = (Togl *) clientData;

    switch (eventPtr->type) {
      case Expose:
          if (eventPtr->xexpose.count == 0) {
              if (!togl->UpdatePending
                      && eventPtr->xexpose.window == Tk_WindowId(togl->TkWin)) {
                  Togl_PostRedisplay(togl);
              }
#if defined(TOGL_X11)
              if (!togl->OverlayUpdatePending && togl->OverlayFlag
                      && togl->OverlayIsMapped
                      && eventPtr->xexpose.window == togl->OverlayWindow) {
                  Togl_PostOverlayRedisplay(togl);
              }
#endif /* TOGL_X11 */
          }
          break;
      case ConfigureNotify:
          if (togl->Width != Tk_Width(togl->TkWin)
                  || togl->Height != Tk_Height(togl->TkWin)) {
              togl->Width = Tk_Width(togl->TkWin);
              togl->Height = Tk_Height(togl->TkWin);
              (void) XResizeWindow(Tk_Display(togl->TkWin),
                      Tk_WindowId(togl->TkWin), togl->Width, togl->Height);
#if defined(TOGL_X11)
              if (togl->OverlayFlag) {
                  (void) XResizeWindow(Tk_Display(togl->TkWin),
                          togl->OverlayWindow, togl->Width, togl->Height);
                  (void) XRaiseWindow(Tk_Display(togl->TkWin),
                          togl->OverlayWindow);
              }
#endif /* TOGL_X11 */
              Togl_MakeCurrent(togl);
              if (togl->ReshapeProc) {
                  togl->ReshapeProc(togl);
              } else {
                  glViewport(0, 0, togl->Width, togl->Height);
#if defined(TOGL_X11)
                  if (togl->OverlayFlag) {
                      Togl_UseLayer(togl, TOGL_OVERLAY);
                      glViewport(0, 0, togl->Width, togl->Height);
                      Togl_UseLayer(togl, TOGL_NORMAL);
                  }
#endif /* TOGL_X11 */
              }
#ifndef TOGL_WGL                /* causes double redisplay on Win32 platform */
              Togl_PostRedisplay(togl);
#endif /* TOGL_WGL */
          }
          break;
      case MapNotify:
#if defined(TOGL_AGL)
      {
          /* 
           * See comment for the UnmapNotify case below.
           */
          AGLDrawable d = TkMacOSXGetDrawablePort(Tk_WindowId(togl->TkWin));

          aglSetDrawable(togl->aglCtx, d);
      }
#endif /* TOGL_AGL */
          break;
      case UnmapNotify:
#if defined(TOGL_AGL)
      {
          /* 
           * For Mac OS X Aqua, Tk subwindows are not implemented as
           * separate Aqua windows.  They are just different regions of
           * a single Aqua window.  To unmap them they are just not drawn.
           * Have to disconnect the AGL context otherwise they will continue
           * to be displayed directly by Aqua.
           */
          aglSetDrawable(togl->aglCtx, NULL);
      }
#endif /* TOGL_AGL */
          break;
      case DestroyNotify:
          if (togl->TkWin != NULL) {
              if (togl->SetGrid > 0) {
                  Tk_UnsetGrid(togl->TkWin);
              }
              togl->TkWin = NULL;
#if (TCL_MAJOR_VERSION * 100 + TCL_MINOR_VERSION) >= 800
              /* This function new in Tcl/Tk 8.0 */
              (void) Tcl_DeleteCommandFromToken(togl->Interp, togl->widgetCmd);
#endif
          }
          if (togl->TimerProc != NULL) {
#if (TK_MAJOR_VERSION * 100 + TK_MINOR_VERSION) >= 401
              Tcl_DeleteTimerHandler(togl->timerHandler);
#else
              Tk_DeleteTimerHandler(togl->timerHandler);
#endif

          }
          if (togl->UpdatePending) {
#if (TCL_MAJOR_VERSION * 100 + TCL_MINOR_VERSION) >= 705
              Tcl_CancelIdleCall(Togl_Render, (ClientData) togl);
#else
              Tk_CancelIdleCall(Togl_Render, (ClientData) togl);
#endif
          }
#if (TK_MAJOR_VERSION * 100 + TK_MINOR_VERSION) >= 401
          Tcl_EventuallyFree((ClientData) togl, Togl_Destroy);
#else
          Tk_EventuallyFree((ClientData) togl, Togl_Destroy);
#endif

          break;
      default:
          /* nothing */
          ;
    }
}



void
Togl_PostRedisplay(Togl *togl)
{
    if (!togl->UpdatePending) {
        togl->UpdatePending = True;
        Tk_DoWhenIdle(Togl_Render, (ClientData) togl);
    }
}



void
Togl_SwapBuffers(const Togl *togl)
{
    if (togl->DoubleFlag) {
#if defined(TOGL_WGL)
        int     res = SwapBuffers(togl->tglGLHdc);

        assert(res == TRUE);
#elif defined(TOGL_X11)
        glXSwapBuffers(Tk_Display(togl->TkWin), Tk_WindowId(togl->TkWin));
#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
        aglSwapBuffers(togl->aglCtx);
#endif /* TOGL_WGL */
    } else {
        glFlush();
    }
}



const char *
Togl_Ident(const Togl *togl)
{
    return togl->Ident;
}


int
Togl_Width(const Togl *togl)
{
    return togl->Width;
}


int
Togl_Height(const Togl *togl)
{
    return togl->Height;
}


Tcl_Interp *
Togl_Interp(const Togl *togl)
{
    return togl->Interp;
}


Tk_Window
Togl_TkWin(const Togl *togl)
{
    return togl->TkWin;
}


#if defined(TOGL_X11)
/* 
 * A replacement for XAllocColor.  This function should never
 * fail to allocate a color.  When XAllocColor fails, we return
 * the nearest matching color.  If we have to allocate many colors
 * this function isn't too efficient; the XQueryColors() could be
 * done just once.
 * Written by Michael Pichler, Brian Paul, Mark Kilgard
 * Input:  dpy - X display
 *         cmap - X colormap
 *         cmapSize - size of colormap
 * In/Out: color - the XColor struct
 * Output:  exact - 1=exact color match, 0=closest match
 */
static void
noFaultXAllocColor(Display *dpy, Colormap cmap, int cmapSize,
        XColor *color, int *exact)
{
    XColor *ctable, subColor;
    int     i, bestmatch;
    double  mindist;            /* 3*2^16^2 exceeds long int precision. */

    /* First try just using XAllocColor. */
    if (XAllocColor(dpy, cmap, color)) {
        *exact = 1;
        return;
    }

    /* Retrieve color table entries. */
    /* XXX alloca candidate. */
    ctable = (XColor *) malloc(cmapSize * sizeof (XColor));
    for (i = 0; i < cmapSize; i++) {
        ctable[i].pixel = i;
    }
    (void) XQueryColors(dpy, cmap, ctable, cmapSize);

    /* Find best match. */
    bestmatch = -1;
    mindist = 0;
    for (i = 0; i < cmapSize; i++) {
        double  dr = (double) color->red - (double) ctable[i].red;
        double  dg = (double) color->green - (double) ctable[i].green;
        double  db = (double) color->blue - (double) ctable[i].blue;
        double  dist = dr * dr + dg * dg + db * db;

        if (bestmatch < 0 || dist < mindist) {
            bestmatch = i;
            mindist = dist;
        }
    }

    /* Return result. */
    subColor.red = ctable[bestmatch].red;
    subColor.green = ctable[bestmatch].green;
    subColor.blue = ctable[bestmatch].blue;
    free(ctable);
    /* Try to allocate the closest match color.  This should only fail if the
     * cell is read/write.  Otherwise, we're incrementing the cell's reference
     * count. */
    if (!XAllocColor(dpy, cmap, &subColor)) {
        /* do this to work around a problem reported by Frank Ortega */
        subColor.pixel = (unsigned long) bestmatch;
        subColor.red = ctable[bestmatch].red;
        subColor.green = ctable[bestmatch].green;
        subColor.blue = ctable[bestmatch].blue;
        subColor.flags = DoRed | DoGreen | DoBlue;
    }
    *color = subColor;
}

#elif defined(TOGL_WGL)

static UINT
Win32AllocColor(const Togl *togl, float red, float green, float blue)
{
    /* Modified version of XAllocColor emulation of Tk. - returns index,
     * instead of color itself - allocates logical palette entry even for
     * non-palette devices */

    TkWinColormap *cmap = (TkWinColormap *) Tk_Colormap(togl->TkWin);
    UINT    index;
    COLORREF newColor, closeColor;
    PALETTEENTRY entry, closeEntry;
    int     new, refCount;
    Tcl_HashEntry *entryPtr;

    entry.peRed = (unsigned char) (red * 255 + .5);
    entry.peGreen = (unsigned char) (green * 255 + .5);
    entry.peBlue = (unsigned char) (blue * 255 + .5);
    entry.peFlags = 0;

    /* 
     * Find the nearest existing palette entry.
     */

    newColor = RGB(entry.peRed, entry.peGreen, entry.peBlue);
    index = GetNearestPaletteIndex(cmap->palette, newColor);
    GetPaletteEntries(cmap->palette, index, 1, &closeEntry);
    closeColor = RGB(closeEntry.peRed, closeEntry.peGreen, closeEntry.peBlue);

    /* 
     * If this is not a duplicate and colormap is not full, allocate a new entry.
     */

    if (newColor != closeColor) {
        if (cmap->size == (unsigned int) togl->CiColormapSize) {
            entry = closeEntry;
        } else {
            cmap->size++;
            ResizePalette(cmap->palette, cmap->size);
            index = cmap->size - 1;
            SetPaletteEntries(cmap->palette, index, 1, &entry);
            SelectPalette(togl->tglGLHdc, cmap->palette, TRUE);
            RealizePalette(togl->tglGLHdc);
        }
    }
    newColor = PALETTERGB(entry.peRed, entry.peGreen, entry.peBlue);
    entryPtr = Tcl_CreateHashEntry(&cmap->refCounts, (char *) newColor, &new);
    if (new) {
        refCount = 1;
    } else {
        refCount = ((int) Tcl_GetHashValue(entryPtr)) + 1;
    }
    Tcl_SetHashValue(entryPtr, (ClientData) refCount);

    /* for EPS output */
    togl->EpsRedMap[index] = (GLfloat) (entry.peRed / 255.0);
    togl->EpsGreenMap[index] = (GLfloat) (entry.peGreen / 255.0);
    togl->EpsBlueMap[index] = (GLfloat) (entry.peBlue / 255.0);
    return index;
}

static void
Win32FreeColor(const Togl *togl, unsigned long index)
{
    TkWinColormap *cmap = (TkWinColormap *) Tk_Colormap(togl->TkWin);
    COLORREF cref;
    UINT    count, refCount;
    PALETTEENTRY entry, *entries;
    Tcl_HashEntry *entryPtr;

    if (index >= cmap->size) {
        panic("Tried to free a color that isn't allocated.");
    }
    GetPaletteEntries(cmap->palette, index, 1, &entry);
    cref = PALETTERGB(entry.peRed, entry.peGreen, entry.peBlue);
    entryPtr = Tcl_FindHashEntry(&cmap->refCounts, (char *) cref);
    if (!entryPtr) {
        panic("Tried to free a color that isn't allocated.");
    }
    refCount = (int) Tcl_GetHashValue(entryPtr) - 1;
    if (refCount == 0) {
        count = cmap->size - index;
        entries = (PALETTEENTRY *) ckalloc(sizeof (PALETTEENTRY) * count);
        GetPaletteEntries(cmap->palette, index + 1, count, entries);
        SetPaletteEntries(cmap->palette, index, count, entries);
        SelectPalette(togl->tglGLHdc, cmap->palette, TRUE);
        RealizePalette(togl->tglGLHdc);
        ckfree((char *) entries);
        cmap->size--;
        Tcl_DeleteHashEntry(entryPtr);
    } else {
        Tcl_SetHashValue(entryPtr, (ClientData) refCount);
    }
}

static void
Win32SetColor(const Togl *togl,
        unsigned long index, float red, float green, float blue)
{
    TkWinColormap *cmap = (TkWinColormap *) Tk_Colormap(togl->TkWin);
    PALETTEENTRY entry;

    entry.peRed = (unsigned char) (red * 255 + .5);
    entry.peGreen = (unsigned char) (green * 255 + .5);
    entry.peBlue = (unsigned char) (blue * 255 + .5);
    entry.peFlags = 0;
    SetPaletteEntries(cmap->palette, index, 1, &entry);
    SelectPalette(togl->tglGLHdc, cmap->palette, TRUE);
    RealizePalette(togl->tglGLHdc);

    /* for EPS output */
    togl->EpsRedMap[index] = (GLfloat) (entry.peRed / 255.0);
    togl->EpsGreenMap[index] = (GLfloat) (entry.peGreen / 255.0);
    togl->EpsBlueMap[index] = (GLfloat) (entry.peBlue / 255.0);
}
#endif /* TOGL_X11 */


unsigned long
Togl_AllocColor(const Togl *togl, float red, float green, float blue)
{
    if (togl->RgbaFlag) {
        (void) fprintf(stderr,
                "Error: Togl_AllocColor illegal in RGBA mode.\n");
        return 0;
    }
    /* TODO: maybe not... */
    if (togl->PrivateCmapFlag) {
        (void) fprintf(stderr,
                "Error: Togl_FreeColor illegal with private colormap\n");
        return 0;
    }
#if defined(TOGL_X11)
    {
        XColor  xcol;
        int     exact;

        xcol.red = (short) (red * 65535.0);
        xcol.green = (short) (green * 65535.0);
        xcol.blue = (short) (blue * 65535.0);

        noFaultXAllocColor(Tk_Display(togl->TkWin), Tk_Colormap(togl->TkWin),
                Tk_Visual(togl->TkWin)->map_entries, &xcol, &exact);
        /* for EPS output */
        togl->EpsRedMap[xcol.pixel] = (float) xcol.red / 65535.0;
        togl->EpsGreenMap[xcol.pixel] = (float) xcol.green / 65535.0;
        togl->EpsBlueMap[xcol.pixel] = (float) xcol.blue / 65535.0;

        return xcol.pixel;
    }

#elif defined(TOGL_WGL)
    return Win32AllocColor(togl, red, green, blue);

#elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    /* still need to implement this on Mac... */
    return 0;

#endif /* TOGL_X11 */
}



void
Togl_FreeColor(const Togl *togl, unsigned long pixel)
{
    if (togl->RgbaFlag) {
        (void) fprintf(stderr,
                "Error: Togl_AllocColor illegal in RGBA mode.\n");
        return;
    }
    /* TODO: maybe not... */
    if (togl->PrivateCmapFlag) {
        (void) fprintf(stderr,
                "Error: Togl_FreeColor illegal with private colormap\n");
        return;
    }
#if defined(TOGL_X11)
    (void) XFreeColors(Tk_Display(togl->TkWin), Tk_Colormap(togl->TkWin),
            &pixel, 1, 0);
#elif defined(TOGL_WGL)
    Win32FreeColor(togl, pixel);
#endif /* TOGL_X11 */
}



void
Togl_SetColor(const Togl *togl,
        unsigned long index, float red, float green, float blue)
{

    if (togl->RgbaFlag) {
        (void) fprintf(stderr,
                "Error: Togl_AllocColor illegal in RGBA mode.\n");
        return;
    }
    if (!togl->PrivateCmapFlag) {
        (void) fprintf(stderr,
                "Error: Togl_SetColor requires a private colormap\n");
        return;
    }
#if defined(TOGL_X11)
    {
        XColor  xcol;

        xcol.pixel = index;
        xcol.red = (short) (red * 65535.0);
        xcol.green = (short) (green * 65535.0);
        xcol.blue = (short) (blue * 65535.0);
        xcol.flags = DoRed | DoGreen | DoBlue;

        (void) XStoreColor(Tk_Display(togl->TkWin), Tk_Colormap(togl->TkWin),
                &xcol);

        /* for EPS output */
        togl->EpsRedMap[xcol.pixel] = (float) xcol.red / 65535.0;
        togl->EpsGreenMap[xcol.pixel] = (float) xcol.green / 65535.0;
        togl->EpsBlueMap[xcol.pixel] = (float) xcol.blue / 65535.0;
    }
#elif defined(TOGL_WGL)
    Win32SetColor(togl, index, red, green, blue);
#endif /* TOGL_X11 */
}


#if TOGL_USE_FONTS == 1

#  if defined(TOGL_WGL)
#    include "tkWinInt.h"
#    include "tkFont.h"

/* 
 * The following structure represents Windows' implementation of a font.
 */

typedef struct WinFont
{
    TkFont  font;               /* Stuff used by generic font package.  Must be
                                 * first in structure. */
    HFONT   hFont;              /* Windows information about font. */
    HWND    hwnd;               /* Toplevel window of application that owns
                                 * this font, used for getting HDC. */
    int     widths[256];        /* Widths of first 256 chars in this font. */
} WinFont;
#  endif /* TOGL_WGL */


#  define MAX_FONTS 1000
static GLuint ListBase[MAX_FONTS];
static GLuint ListCount[MAX_FONTS];



/* 
 * Load the named bitmap font as a sequence of bitmaps in a display list.
 * fontname may be one of the predefined fonts like TOGL_BITMAP_8_BY_13
 * or an X font name, or a Windows font name, etc.
 */
GLuint
Togl_LoadBitmapFont(const Togl *togl, const char *fontname)
{
    static Bool FirstTime = True;

#  if defined(TOGL_X11)
    XFontStruct *fontinfo;
#  elif defined(TOGL_WGL)
    WinFont *winfont;
    HFONT   oldFont;
    TEXTMETRIC tm;
#  endif
    /* TOGL_X11 */
    int     first, last, count;
    GLuint  fontbase;
    const char *name;

    /* Initialize the ListBase and ListCount arrays */
    if (FirstTime) {
        int     i;

        for (i = 0; i < MAX_FONTS; i++) {
            ListBase[i] = ListCount[i] = 0;
        }
        FirstTime = False;
    }

    /* 
     * This method of selecting X fonts according to a TOGL_ font name
     * is a kludge.  To be fixed when I find time...
     */
    if (fontname == TOGL_BITMAP_8_BY_13) {
        name = "8x13";
    } else if (fontname == TOGL_BITMAP_9_BY_15) {
        name = "9x15";
    } else if (fontname == TOGL_BITMAP_TIMES_ROMAN_10) {
        name = "-adobe-times-medium-r-normal--10-100-75-75-p-54-iso8859-1";
    } else if (fontname == TOGL_BITMAP_TIMES_ROMAN_24) {
        name = "-adobe-times-medium-r-normal--24-240-75-75-p-124-iso8859-1";
    } else if (fontname == TOGL_BITMAP_HELVETICA_10) {
        name = "-adobe-helvetica-medium-r-normal--10-100-75-75-p-57-iso8859-1";
    } else if (fontname == TOGL_BITMAP_HELVETICA_12) {
        name = "-adobe-helvetica-medium-r-normal--12-120-75-75-p-67-iso8859-1";
    } else if (fontname == TOGL_BITMAP_HELVETICA_18) {
        name = "-adobe-helvetica-medium-r-normal--18-180-75-75-p-98-iso8859-1";
    } else if (!fontname) {
        name = DEFAULT_FONTNAME;
    } else {
        name = (const char *) fontname;
    }

    assert(name);

#  if defined(TOGL_X11)
    fontinfo = (XFontStruct *) XLoadQueryFont(Tk_Display(togl->TkWin), name);
    if (!fontinfo) {
        return 0;
    }
    first = fontinfo->min_char_or_byte2;
    last = fontinfo->max_char_or_byte2;
#  elif defined(TOGL_WGL)
    winfont = (WinFont *) Tk_GetFont(togl->Interp, togl->TkWin, name);
    if (!winfont) {
        return 0;
    }
    oldFont = SelectObject(togl->tglGLHdc, winfont->hFont);
    GetTextMetrics(togl->tglGLHdc, &tm);
    first = tm.tmFirstChar;
    last = tm.tmLastChar;
#  elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    first = 10;                 /* don't know how to determine font range on
                                 * Mac... */
    last = 127;
#  endif
    /* TOGL_X11 */

    count = last - first + 1;
    fontbase = glGenLists((GLuint) (last + 1));
    if (fontbase == 0) {
#  ifdef TOGL_WGL
        SelectObject(togl->tglGLHdc, oldFont);
        Tk_FreeFont((Tk_Font) winfont);
#  endif
        /* TOGL_WGL */
        return 0;
    }
#  if defined(TOGL_WGL)
    wglUseFontBitmaps(togl->tglGLHdc, first, count, (int) fontbase + first);
    SelectObject(togl->tglGLHdc, oldFont);
    Tk_FreeFont((Tk_Font) winfont);
#  elif defined(TOGL_X11)
    glXUseXFont(fontinfo->fid, first, count, (int) fontbase + first);
#  elif defined(TOGL_AGL_CLASSIC) || defined(TOGL_AGL)
    aglUseFont(togl->aglCtx, 1, 0, 14,  /* for now, only app font, regular
                                         * 14-point */
            10, 118, fontbase + first);
#  endif

    /* Record the list base and number of display lists for
     * Togl_UnloadBitmapFont(). */
    {
        int     i;

        for (i = 0; i < MAX_FONTS; i++) {
            if (ListBase[i] == 0) {
                ListBase[i] = fontbase;
                ListCount[i] = last + 1;
                break;
            }
        }
    }

    return fontbase;
}



/* 
 * Release the display lists which were generated by Togl_LoadBitmapFont().
 */
void
Togl_UnloadBitmapFont(const Togl *togl, GLuint fontbase)
{
    int     i;

    (void) togl;
    for (i = 0; i < MAX_FONTS; i++) {
        if (ListBase[i] == fontbase) {
            glDeleteLists(ListBase[i], ListCount[i]);
            ListBase[i] = ListCount[i] = 0;
            return;
        }
    }
}

#endif /* TOGL_USE_FONTS */


/* 
 * Overlay functions
 */


void
Togl_UseLayer(Togl *togl, int layer)
{
    if (!togl->OverlayWindow)
        return;
    if (layer == TOGL_OVERLAY) {
#if defined(TOGL_WGL)
        int     res = wglMakeCurrent(togl->tglGLHdc, togl->tglGLOverlayHglrc);

        assert(res == TRUE);
#elif defined(TOGL_X11)
        (void) glXMakeCurrent(Tk_Display(togl->TkWin),
                togl->OverlayWindow, togl->OverlayCtx);
#  if defined(__sgi)
        if (togl->OldStereoFlag)
            oldStereoMakeCurrent(Tk_Display(togl->TkWin),
                    togl->OverlayWindow, togl->OverlayCtx);
#  endif
        /* __sgi STEREO */
#endif /* TOGL_WGL */
    } else if (layer == TOGL_NORMAL) {
#if defined(TOGL_WGL)
        int     res = wglMakeCurrent(togl->tglGLHdc, togl->tglGLHglrc);

        assert(res == TRUE);
#elif defined(TOGL_X11)
        (void) glXMakeCurrent(Tk_Display(togl->TkWin),
                Tk_WindowId(togl->TkWin), togl->GlCtx);
#  if defined(__sgi)
        if (togl->OldStereoFlag)
            oldStereoMakeCurrent(Tk_Display(togl->TkWin),
                    Tk_WindowId(togl->TkWin), togl->GlCtx);
#  endif
        /* __sgi STEREO */
#endif /* TOGL_WGL */
    } else {
        /* error */
    }
}


void
Togl_ShowOverlay(Togl *togl)
{
#if defined(TOGL_X11)           /* not yet implemented on Windows */
    if (togl->OverlayWindow) {
        (void) XMapWindow(Tk_Display(togl->TkWin), togl->OverlayWindow);
        (void) XInstallColormap(Tk_Display(togl->TkWin), togl->OverlayCmap);
        togl->OverlayIsMapped = True;
    }
#endif /* TOGL_X11 */
}


void
Togl_HideOverlay(Togl *togl)
{
    if (togl->OverlayWindow && togl->OverlayIsMapped) {
        (void) XUnmapWindow(Tk_Display(togl->TkWin), togl->OverlayWindow);
        togl->OverlayIsMapped = False;
    }
}


void
Togl_PostOverlayRedisplay(Togl *togl)
{
    if (!togl->OverlayUpdatePending
            && togl->OverlayWindow && togl->OverlayDisplayProc) {
        Tk_DoWhenIdle(RenderOverlay, (ClientData) togl);
        togl->OverlayUpdatePending = True;
    }
}


void
Togl_OverlayDisplayFunc(Togl_Callback *proc)
{
    DefaultOverlayDisplayProc = proc;
}


int
Togl_ExistsOverlay(const Togl *togl)
{
    return togl->OverlayFlag;
}


int
Togl_GetOverlayTransparentValue(const Togl *togl)
{
    return togl->OverlayTransparentPixel;
}


int
Togl_IsMappedOverlay(const Togl *togl)
{
    return togl->OverlayFlag && togl->OverlayIsMapped;
}


unsigned long
Togl_AllocColorOverlay(const Togl *togl, float red, float green, float blue)
{
#if defined(TOGL_X11)           /* not yet implemented on Windows */
    if (togl->OverlayFlag && togl->OverlayCmap) {
        XColor  xcol;

        xcol.red = (short) (red * 65535.0);
        xcol.green = (short) (green * 65535.0);
        xcol.blue = (short) (blue * 65535.0);
        if (!XAllocColor(Tk_Display(togl->TkWin), togl->OverlayCmap, &xcol))
            return (unsigned long) -1;
        return xcol.pixel;
    }
#endif /* TOGL_X11 */
    return (unsigned long) -1;
}


void
Togl_FreeColorOverlay(const Togl *togl, unsigned long pixel)
{
#if defined(TOGL_X11)           /* not yet implemented on Windows */
    if (togl->OverlayFlag && togl->OverlayCmap) {
        (void) XFreeColors(Tk_Display(togl->TkWin), togl->OverlayCmap, &pixel,
                1, 0);
    }
#endif /* TOGL_X11 */
}


/* 
 * User client data
 */

void
Togl_ClientData(ClientData clientData)
{
    DefaultClientData = clientData;
}


ClientData
Togl_GetClientData(const Togl *togl)
{
    return togl->Client_Data;
}


void
Togl_SetClientData(Togl *togl, ClientData clientData)
{
    togl->Client_Data = clientData;
}


/* 
 * X11-only functions
 * Contributed by Miguel A. De Riera Pasenau (miguel@DALILA.UPC.ES)
 */

Display *
Togl_Display(const Togl *togl)
{
    return Tk_Display(togl->TkWin);
}

Screen *
Togl_Screen(const Togl *togl)
{
    return Tk_Screen(togl->TkWin);
}

int
Togl_ScreenNumber(const Togl *togl)
{
    return Tk_ScreenNumber(togl->TkWin);
}

Colormap
Togl_Colormap(const Togl *togl)
{
    return Tk_Colormap(togl->TkWin);
}



#ifdef MESA_COLOR_HACK
/* 
 * Let's know how many free colors do we have
 */
#  if 0
static unsigned char rojo[] = { 4, 39, 74, 110, 145, 181, 216, 251 }, verde[] = {
4, 39, 74, 110, 145, 181, 216, 251}, azul[] = {
4, 39, 74, 110, 145, 181, 216, 251};

unsigned char rojo[] = { 4, 36, 72, 109, 145, 182, 218, 251 }, verde[] = {
4, 36, 72, 109, 145, 182, 218, 251}, azul[] = {
4, 36, 72, 109, 145, 182, 218, 251};

azul[] = {
0, 85, 170, 255};
#  endif

#  define RLEVELS     5
#  define GLEVELS     9
#  define BLEVELS     5

/* to free dithered_rgb_colormap pixels allocated by Mesa */
static unsigned long *ToglMesaUsedPixelCells = NULL;
static int ToglMesaUsedFreeCells = 0;

static int
get_free_color_cells(Display *display, int screen, Colormap colormap)
{
    if (!ToglMesaUsedPixelCells) {
        XColor  xcol;
        int     i;
        int     colorsfailed, ncolors = XDisplayCells(display, screen);

        long    r, g, b;

        ToglMesaUsedPixelCells =
                (unsigned long *) calloc(ncolors, sizeof (unsigned long));

        /* Allocate X colors and initialize color_table[], red_table[], etc */
        /* de Mesa 2.1: xmesa1.c setup_dithered_(...) */
        i = colorsfailed = 0;
        for (r = 0; r < RLEVELS; r++)
            for (g = 0; g < GLEVELS; g++)
                for (b = 0; b < BLEVELS; b++) {
                    int     exact;

                    xcol.red = (r * 65535) / (RLEVELS - 1);
                    xcol.green = (g * 65535) / (GLEVELS - 1);
                    xcol.blue = (b * 65535) / (BLEVELS - 1);
                    noFaultXAllocColor(display, colormap, ncolors,
                            &xcol, &exact);
                    ToglMesaUsedPixelCells[i++] = xcol.pixel;
                    if (!exact) {
                        colorsfailed++;
                    }
                }
        ToglMesaUsedFreeCells = i;

        XFreeColors(display, colormap, ToglMesaUsedPixelCells,
                ToglMesaUsedFreeCells, 0x00000000);
    }
    return ToglMesaUsedFreeCells;
}


static void
free_default_color_cells(Display *display, Colormap colormap)
{
    if (ToglMesaUsedPixelCells) {
        XFreeColors(display, colormap, ToglMesaUsedPixelCells,
                ToglMesaUsedFreeCells, 0x00000000);
        free(ToglMesaUsedPixelCells);
        ToglMesaUsedPixelCells = NULL;
        ToglMesaUsedFreeCells = 0;
    }
}
#endif


/* 
 * Generate EPS file.
 * Contributed by Miguel A. De Riera Pasenau (miguel@DALILA.UPC.ES)
 */

/* Function that creates a EPS File from a created pixmap on the current
 * context. Based on the code from Copyright (c) Mark J. Kilgard, 1996.
 * Parameters: name_file, b&w / Color flag, redraw function. The redraw
 * function is needed in order to draw things into the new created pixmap. */

/* Copyright (c) Mark J. Kilgard, 1996. */

static GLvoid *
grabPixels(int inColor, unsigned int width, unsigned int height)
{
    GLvoid *buffer;
    GLint   swapbytes, lsbfirst, rowlength;
    GLint   skiprows, skippixels, alignment;
    GLenum  format;
    unsigned int size;

    if (inColor) {
        format = GL_RGB;
        size = width * height * 3;
    } else {
        format = GL_LUMINANCE;
        size = width * height * 1;
    }

    buffer = (GLvoid *) malloc(size);
    if (buffer == NULL)
        return NULL;

    /* Save current modes. */
    glGetIntegerv(GL_PACK_SWAP_BYTES, &swapbytes);
    glGetIntegerv(GL_PACK_LSB_FIRST, &lsbfirst);
    glGetIntegerv(GL_PACK_ROW_LENGTH, &rowlength);
    glGetIntegerv(GL_PACK_SKIP_ROWS, &skiprows);
    glGetIntegerv(GL_PACK_SKIP_PIXELS, &skippixels);
    glGetIntegerv(GL_PACK_ALIGNMENT, &alignment);
    /* Little endian machines (DEC Alpha for example) could benefit from
     * setting GL_PACK_LSB_FIRST to GL_TRUE instead of GL_FALSE, but this would
     * * * * * * * * * require changing the generated bitmaps too. */
    glPixelStorei(GL_PACK_SWAP_BYTES, GL_FALSE);
    glPixelStorei(GL_PACK_LSB_FIRST, GL_FALSE);
    glPixelStorei(GL_PACK_ROW_LENGTH, 0);
    glPixelStorei(GL_PACK_SKIP_ROWS, 0);
    glPixelStorei(GL_PACK_SKIP_PIXELS, 0);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);

    /* Actually read the pixels. */
    glReadPixels(0, 0, width, height, format,
            GL_UNSIGNED_BYTE, (GLvoid *) buffer);

    /* Restore saved modes. */
    glPixelStorei(GL_PACK_SWAP_BYTES, swapbytes);
    glPixelStorei(GL_PACK_LSB_FIRST, lsbfirst);
    glPixelStorei(GL_PACK_ROW_LENGTH, rowlength);
    glPixelStorei(GL_PACK_SKIP_ROWS, skiprows);
    glPixelStorei(GL_PACK_SKIP_PIXELS, skippixels);
    glPixelStorei(GL_PACK_ALIGNMENT, alignment);
    return buffer;
}


static int
generateEPS(const char *filename, int inColor,
        unsigned int width, unsigned int height)
{
    FILE   *fp;
    GLvoid *pixels;
    unsigned char *curpix;
    unsigned int components, i;
    int     pos;
    unsigned int bitpixel;

    pixels = grabPixels(inColor, width, height);
    if (pixels == NULL)
        return 1;
    if (inColor)
        components = 3;         /* Red, green, blue. */
    else
        components = 1;         /* Luminance. */

    fp = fopen(filename, "w");
    if (fp == NULL) {
        return 2;
    }
    (void) fprintf(fp, "%%!PS-Adobe-2.0 EPSF-1.2\n");
    (void) fprintf(fp, "%%%%Creator: OpenGL pixmap render output\n");
    (void) fprintf(fp, "%%%%BoundingBox: 0 0 %d %d\n", width, height);
    (void) fprintf(fp, "%%%%EndComments\n");

    i = (((width * height) + 7) / 8) / 40;      /* # of lines, 40 bytes per
                                                 * line */
    (void) fprintf(fp, "%%%%BeginPreview: %d %d %d %d\n%%", width, height, 1,
            i);
    pos = 0;
    curpix = (unsigned char *) pixels;
    for (i = 0; i < width * height * components;) {
        bitpixel = 0;
        if (inColor) {
            double  pix = 0;

            pix = 0.30 * (double) curpix[i] + 0.59 * (double) curpix[i + 1] +
                    0.11 * (double) curpix[i + 2];
            i += 3;
            if (pix > 127.0)
                bitpixel |= 0x80;
            pix = 0.30 * (double) curpix[i] + 0.59 * (double) curpix[i + 1] +
                    0.11 * (double) curpix[i + 2];
            i += 3;
            if (pix > 127.0)
                bitpixel |= 0x40;
            pix = 0.30 * (double) curpix[i] + 0.59 * (double) curpix[i + 1] +
                    0.11 * (double) curpix[i + 2];
            i += 3;
            if (pix > 127.0)
                bitpixel |= 0x20;
            pix = 0.30 * (double) curpix[i] + 0.59 * (double) curpix[i + 1] +
                    0.11 * (double) curpix[i + 2];
            i += 3;
            if (pix > 127.0)
                bitpixel |= 0x10;
            pix = 0.30 * (double) curpix[i] + 0.59 * (double) curpix[i + 1] +
                    0.11 * (double) curpix[i + 2];
            i += 3;
            if (pix > 127.0)
                bitpixel |= 0x08;
            pix = 0.30 * (double) curpix[i] + 0.59 * (double) curpix[i + 1] +
                    0.11 * (double) curpix[i + 2];
            i += 3;
            if (pix > 127.0)
                bitpixel |= 0x04;
            pix = 0.30 * (double) curpix[i] + 0.59 * (double) curpix[i + 1] +
                    0.11 * (double) curpix[i + 2];
            i += 3;
            if (pix > 127.0)
                bitpixel |= 0x02;
            pix = 0.30 * (double) curpix[i] + 0.59 * (double) curpix[i + 1] +
                    0.11 * (double) curpix[i + 2];
            i += 3;
            if (pix > 127.0)
                bitpixel |= 0x01;
        } else {
            if (curpix[i++] > 0x7f)
                bitpixel |= 0x80;
            if (curpix[i++] > 0x7f)
                bitpixel |= 0x40;
            if (curpix[i++] > 0x7f)
                bitpixel |= 0x20;
            if (curpix[i++] > 0x7f)
                bitpixel |= 0x10;
            if (curpix[i++] > 0x7f)
                bitpixel |= 0x08;
            if (curpix[i++] > 0x7f)
                bitpixel |= 0x04;
            if (curpix[i++] > 0x7f)
                bitpixel |= 0x02;
            if (curpix[i++] > 0x7f)
                bitpixel |= 0x01;
        }
        (void) fprintf(fp, "%02x", bitpixel);
        if (++pos >= 40) {
            (void) fprintf(fp, "\n%%");
            pos = 0;
        }
    }
    if (pos)
        (void) fprintf(fp, "\n%%%%EndPreview\n");
    else
        (void) fprintf(fp, "%%EndPreview\n");

    (void) fprintf(fp, "gsave\n");
    (void) fprintf(fp, "/bwproc {\n");
    (void) fprintf(fp, "    rgbproc\n");
    (void) fprintf(fp, "    dup length 3 idiv string 0 3 0\n");
    (void) fprintf(fp, "    5 -1 roll {\n");
    (void) fprintf(fp, "    add 2 1 roll 1 sub dup 0 eq\n");
    (void) fprintf(fp, "    { pop 3 idiv 3 -1 roll dup 4 -1 roll dup\n");
    (void) fprintf(fp, "        3 1 roll 5 -1 roll put 1 add 3 0 }\n");
    (void) fprintf(fp, "    { 2 1 roll } ifelse\n");
    (void) fprintf(fp, "    } forall\n");
    (void) fprintf(fp, "    pop pop pop\n");
    (void) fprintf(fp, "} def\n");
    (void) fprintf(fp, "systemdict /colorimage known not {\n");
    (void) fprintf(fp, "    /colorimage {\n");
    (void) fprintf(fp, "        pop\n");
    (void) fprintf(fp, "        pop\n");
    (void) fprintf(fp, "        /rgbproc exch def\n");
    (void) fprintf(fp, "        { bwproc } image\n");
    (void) fprintf(fp, "    } def\n");
    (void) fprintf(fp, "} if\n");
    (void) fprintf(fp, "/picstr %d string def\n", width * components);
    (void) fprintf(fp, "%d %d scale\n", width, height);
    (void) fprintf(fp, "%d %d %d\n", width, height, 8);
    (void) fprintf(fp, "[%d 0 0 %d 0 0]\n", width, height);
    (void) fprintf(fp, "{currentfile picstr readhexstring pop}\n");
    (void) fprintf(fp, "false %d\n", components);
    (void) fprintf(fp, "colorimage\n");

    curpix = (unsigned char *) pixels;
    pos = 0;
    for (i = width * height * components; i != 0; i--) {
        (void) fprintf(fp, "%02hx", *curpix++);
        if (++pos >= 40) {
            (void) fprintf(fp, "\n");
            pos = 0;
        }
    }
    if (pos)
        (void) fprintf(fp, "\n");

    (void) fprintf(fp, "grestore\n");
    free(pixels);
    if (fclose(fp) != 0)
        return 1;
    return 0;
}


/* int Togl_DumpToEpsFile( const Togl *togl, const char *filename, int inColor, 
 * void (*user_redraw)(void)) */
/* changed by GG */
int
Togl_DumpToEpsFile(const Togl *togl, const char *filename,
        int inColor, void (*user_redraw) (const Togl *))
{
    Bool    using_mesa = False;

#if 0
    Pixmap  eps_pixmap;
    GLXPixmap eps_glxpixmap;
    XVisualInfo *vi = togl->VisInfo;
    Window  win = Tk_WindowId(togl->TkWin);
#endif
    int     retval;
    unsigned int width = togl->Width, height = togl->Height;

#if defined(TOGL_X11)
    Display *dpy = Tk_Display(togl->TkWin);
    int     scrnum = Tk_ScreenNumber(togl->TkWin);

    if (strstr(glXQueryServerString(dpy, scrnum, GLX_VERSION), "Mesa"))
        using_mesa = True;
    else
#endif /* TOGL_X11 */
        using_mesa = False;
    /* I don't use Pixmap do drawn into, because the code should link with Mesa
     * libraries and OpenGL libraries, and the which library we use at run time
     * should not matter, but the name of the calls differs one from another:
     * MesaGl: glXCreateGLXPixmapMESA( dpy, vi, eps_pixmap,
     * Tk_Colormap(togl->TkWin)) OpenGl: glXCreateGLXPixmap( dpy, vi,
     * eps_pixmap); instead of this I read direct from back buffer of the
     * screeen. */
#if 0
    eps_pixmap = XCreatePixmap(dpy, win, width, height, vi->depth);
    if (using_mesa)
        eps_glxpixmap =
                glXCreateGLXPixmapMESA(dpy, vi, eps_pixmap,
                Tk_Colormap(togl->TkWin));
    else
        eps_glxpixmap = glXCreateGLXPixmap(dpy, vi, eps_pixmap);

    glXMakeCurrent(dpy, eps_glxpixmap, togl->GlCtx);
    user_redraw();
#endif
    if (!togl->RgbaFlag) {

#if defined(TOGL_WGL)
        /* Due to the lack of a unique inverse mapping from the frame buffer to
         * the logical palette we need a translation map from the complete
         * logical palette. */
        {
            int     n, i;
            TkWinColormap *cmap = (TkWinColormap *) Tk_Colormap(togl->TkWin);
            LPPALETTEENTRY entry =
                    malloc(togl->EpsMapSize * sizeof (PALETTEENTRY));
            n = GetPaletteEntries(cmap->palette, 0, togl->EpsMapSize, entry);
            for (i = 0; i < n; i++) {
                togl->EpsRedMap[i] = (GLfloat) (entry[i].peRed / 255.0);
                togl->EpsGreenMap[i] = (GLfloat) (entry[i].peGreen / 255.0);
                togl->EpsBlueMap[i] = (GLfloat) (entry[i].peBlue / 255.0);
            }
            free(entry);
        }
#endif /* TOGL_WGL */

        glPixelMapfv(GL_PIXEL_MAP_I_TO_R, togl->EpsMapSize, togl->EpsRedMap);
        glPixelMapfv(GL_PIXEL_MAP_I_TO_G, togl->EpsMapSize, togl->EpsGreenMap);
        glPixelMapfv(GL_PIXEL_MAP_I_TO_B, togl->EpsMapSize, togl->EpsBlueMap);
    }
    /* user_redraw(); */
    user_redraw(togl);          /* changed by GG */
    /* glReadBuffer( GL_FRONT); */
    /* by default it read GL_BACK in double buffer mode */
    glFlush();
    retval = generateEPS(filename, inColor, width, height);
#if 0
    glXMakeCurrent(dpy, win, togl->GlCtx);
    glXDestroyGLXPixmap(dpy, eps_glxpixmap);
    XFreePixmap(dpy, eps_pixmap);
#endif
    return retval;
}

/* 
 * Full screen stereo for SGI graphics
 * Contributed by Ben Evans (Ben.Evans@anusf.anu.edu.au)
 * This code was based on SGI's /usr/share/src/OpenGL/teach/stereo
 */

#if defined(__sgi)

static struct stereoStateRec
{
    Bool    useSGIStereo;
    Display *currentDisplay;
    Window  currentWindow;
    GLXContext currentContext;
    GLenum  currentDrawBuffer;
    int     currentStereoBuffer;
    Bool    enabled;
    char   *stereoCommand;
    char   *restoreCommand;
} stereo;

/* call instead of glDrawBuffer */
void
Togl_OldStereoDrawBuffer(GLenum mode)
{
    if (stereo.useSGIStereo) {
        stereo.currentDrawBuffer = mode;
        switch (mode) {
          case GL_FRONT:
          case GL_BACK:
          case GL_FRONT_AND_BACK:
              /* 
               ** Simultaneous drawing to both left and right buffers isn't
               ** really possible if we don't have a stereo capable visual.
               ** For now just fall through and use the left buffer.
               */
          case GL_LEFT:
          case GL_FRONT_LEFT:
          case GL_BACK_LEFT:
              stereo.currentStereoBuffer = STEREO_BUFFER_LEFT;
              break;
          case GL_RIGHT:
          case GL_FRONT_RIGHT:
              stereo.currentStereoBuffer = STEREO_BUFFER_RIGHT;
              mode = GL_FRONT;
              break;
          case GL_BACK_RIGHT:
              stereo.currentStereoBuffer = STEREO_BUFFER_RIGHT;
              mode = GL_BACK;
              break;
          default:
              break;
        }
        if (stereo.currentDisplay && stereo.currentWindow) {
            glXWaitGL();        /* sync with GL command stream before calling X 
                                 */
            XSGISetStereoBuffer(stereo.currentDisplay,
                    stereo.currentWindow, stereo.currentStereoBuffer);
            glXWaitX();         /* sync with X command stream before calling GL 
                                 */
        }
    }
    glDrawBuffer(mode);
}

/* call instead of glClear */
void
Togl_OldStereoClear(GLbitfield mask)
{
    GLenum  drawBuffer;

    if (stereo.useSGIStereo) {
        drawBuffer = stereo.currentDrawBuffer;
        switch (drawBuffer) {
          case GL_FRONT:
              Togl_OldStereoDrawBuffer(GL_FRONT_RIGHT);
              glClear(mask);
              Togl_OldStereoDrawBuffer(drawBuffer);
              break;
          case GL_BACK:
              Togl_OldStereoDrawBuffer(GL_BACK_RIGHT);
              glClear(mask);
              Togl_OldStereoDrawBuffer(drawBuffer);
              break;
          case GL_FRONT_AND_BACK:
              Togl_OldStereoDrawBuffer(GL_RIGHT);
              glClear(mask);
              Togl_OldStereoDrawBuffer(drawBuffer);
              break;
          case GL_LEFT:
          case GL_FRONT_LEFT:
          case GL_BACK_LEFT:
          case GL_RIGHT:
          case GL_FRONT_RIGHT:
          case GL_BACK_RIGHT:
          default:
              break;
        }
    }
    glClear(mask);
}

static void
oldStereoMakeCurrent(Display *dpy, Window win, GLXContext ctx)
{

    if (dpy && (dpy != stereo.currentDisplay)) {
        int     event, error;

        /* Make sure new Display supports SGIStereo */
        if (XSGIStereoQueryExtension(dpy, &event, &error) == False) {
            dpy = NULL;
        }
    }
    if (dpy && win && (win != stereo.currentWindow)) {
        /* Make sure new Window supports SGIStereo */
        if (XSGIQueryStereoMode(dpy, win) == X_STEREO_UNSUPPORTED) {
            win = None;
        }
    }
    if (ctx && (ctx != stereo.currentContext)) {
        GLint   drawBuffer;

        glGetIntegerv(GL_DRAW_BUFFER, &drawBuffer);
        Togl_OldStereoDrawBuffer((GLenum) drawBuffer);
    }
    stereo.currentDisplay = dpy;
    stereo.currentWindow = win;
    stereo.currentContext = ctx;
}


/* call before using stereo */
static void
oldStereoInit(Togl *togl, int stereoEnabled)
{
    stereo.useSGIStereo = stereoEnabled;
    stereo.currentDisplay = NULL;
    stereo.currentWindow = None;
    stereo.currentContext = NULL;
    stereo.currentDrawBuffer = GL_NONE;
    stereo.currentStereoBuffer = STEREO_BUFFER_NONE;
    stereo.enabled = False;
}

#endif /* __sgi STEREO */


void
Togl_StereoFrustum(GLfloat left, GLfloat right, GLfloat bottom, GLfloat top,
        GLfloat zNear, GLfloat zFar, GLfloat eyeDist, GLfloat eyeOffset)
{
    GLfloat eyeShift = (eyeDist - zNear) * (eyeOffset / eyeDist);

    glFrustum(left + eyeShift, right + eyeShift, bottom, top, zNear, zFar);
    glTranslatef(-eyeShift, 0, 0);
}


#ifdef TOGL_AGL_CLASSIC
/* needed to make shared library on Mac with CodeWarrior; should be overridden
 * by user app */
/* 
 * int main(int argc, char *argv[]) { return -1; } */

/* the following code is borrowed from tkMacAppInit.c */

/* 
 *----------------------------------------------------------------------
 *
 * MacintoshInit --
 *
 *      This procedure calls Mac specific initilization calls.  Most of
 *      these calls must be made as soon as possible in the startup
 *      process.
 *
 * Results:
 *      Returns TCL_OK if everything went fine.  If it didn't the
 *      application should probably fail.
 *
 * Side effects:
 *      Inits the application.
 *
 *----------------------------------------------------------------------
 */

int
Togl_MacInit(void)
{
    int     i;
    long    result, mask = 0x0700;      /* mask = system 7.x */

#  if GENERATING68K && !GENERATINGCFM
    SetApplLimit(GetApplLimit() - (TK_MAC_68K_STACK_GROWTH));
#  endif
    MaxApplZone();
    for (i = 0; i < 4; i++) {
        (void) MoreMasters();
    }

    /* 
     * Tk needs us to set the qd pointer it uses.  This is needed
     * so Tk doesn't have to assume the availablity of the qd global
     * variable.  Which in turn allows Tk to be used in code resources.
     */
    tcl_macQdPtr = &qd;

    /* 
     * If appearance is present, then register Tk as an Appearance client
     * This means that the mapping from non-Appearance to Appearance cdefs
     * will be done for Tk regardless of the setting in the Appearance
     * control panel.
     */
    if (TkMacHaveAppearance()) {
        RegisterAppearanceClient();
    }

    InitGraf(&tcl_macQdPtr->thePort);
    InitFonts();
    InitWindows();
    InitMenus();
    InitDialogs((long) NULL);
    InitCursor();

    /* 
     * Make sure we are running on system 7 or higher
     */
    if ((NGetTrapAddress(_Gestalt, ToolTrap) ==
                    NGetTrapAddress(_Unimplemented, ToolTrap))
            || (((Gestalt(gestaltSystemVersion, &result) != noErr)
                            || (result < mask)))) {
        panic("Tcl/Tk requires System 7 or higher.");
    }

    /* 
     * Make sure we have color quick draw
     * (this means we can't run on 68000 macs)
     */
    if (((Gestalt(gestaltQuickdrawVersion, &result) != noErr)
                    || (result < gestalt32BitQD13))) {
        panic("Tk requires Color QuickDraw.");
    }

    FlushEvents(everyEvent, 0);
    SetEventMask(everyEvent);

    Tcl_MacSetEventProc(TkMacConvertEvent);
    return TCL_OK;
}

int
Togl_MacSetupMainInterp(Tcl_Interp *interp)
{
    TkMacInitAppleEvents(interp);
    TkMacInitMenus(interp);
    return TCL_OK;
}

#endif /* TOGL_AGL_CLASSIC */
