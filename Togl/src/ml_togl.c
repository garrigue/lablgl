/* $Id: ml_togl.c,v 1.16 2006-03-23 06:01:55 garrigue Exp $ */

#define CAML_NAME_SPACE

#ifdef _WIN32
#include <wtypes.h>
#endif
#include <stdlib.h>
#ifdef __APPLE__
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif
#include <tcl.h>
#include <tk.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/fail.h>
#include "togl.h"
#include "ml_gl.h"
#include "togl_tags.h"

/* extern Tcl_Interp *cltclinterp; */ /* The Tcl interpretor */
/* extern void tk_error (char *message); */ /* Raise TKerror */

int TOGLenum_val(value tag)
{
    switch(tag)
    {
#include "togl_tags.c"
    }
    invalid_argument ("Unknown Togl tag");
}

/* Avoid direct use of stderr */
void togl_prerr(const char *msg)
{
    value ml_msg = copy_string(msg);
    value *prerr = caml_named_value("togl_prerr");
    if (!prerr) caml_failwith(msg);
    caml_callback_exn(*prerr, ml_msg);
}

CAMLprim value ml_Togl_Init (value unit)  /* ML */
{
    value *interp = caml_named_value("cltclinterp");
    Tcl_Interp *cltclinterp =
      (interp ? (Tcl_Interp *) Nativeint_val(Field(*interp,0)) : NULL);
    if (cltclinterp == NULL || Togl_Init(cltclinterp) == TCL_ERROR)
      raise_with_string(*caml_named_value("tkerror"), "Togl_Init failed");
    return Val_unit;
}

/* Does not register the structure with Caml !
static value Val_togl (struct Togl *togl)
{
    value wrapper = alloc(1,No_scan_tag);
    Field(wrapper,0) = (value) togl;
    return wrapper;
}
*/

enum {
     CreateFunc = 0,
     DisplayFunc,
     ReshapeFunc,
     DestroyFunc,
     TimerFunc,
     OverlayDisplayFunc,
     RenderFunc,
     LastFunc
};

static value *callbacks = NULL;

#define CALLBACK(func) \
static void callback_##func (struct Togl *togl) \
{ callback (Field(*callbacks, func), Val_addr(togl)); }
#define CALLBACK_const(func) \
static void callback_##func (const struct Togl *togl) \
{ callback (Field(*callbacks, func), Val_addr(togl)); }

#define ENABLER(func) \
CAMLprim value ml_Togl_##func (value unit) \
{ if (callbacks == NULL) callbacks = caml_named_value ("togl_callbacks"); \
  Togl_##func (callback_##func); \
  return Val_unit; }

CALLBACK (CreateFunc)
CALLBACK (DisplayFunc)
CALLBACK (ReshapeFunc)
CALLBACK (DestroyFunc)
CALLBACK (TimerFunc)
CALLBACK (OverlayDisplayFunc)
CALLBACK_const (RenderFunc)

ENABLER (CreateFunc)
ENABLER (DisplayFunc)
ENABLER (ReshapeFunc)
ENABLER (DestroyFunc)
ENABLER (TimerFunc)
ENABLER (OverlayDisplayFunc)

ML_0 (Togl_ResetDefaultCallbacks)
ML_1 (Togl_PostRedisplay, Addr_val)
ML_1 (Togl_SwapBuffers, Addr_val)
ML_1_ (Togl_Ident, Addr_val, copy_string)
ML_1_ (Togl_Width, Addr_val, Val_int)
ML_1_ (Togl_Height, Addr_val, Val_int)

CAMLprim value ml_Togl_LoadBitmapFont (value togl, value font)  /* ML */
{
    char *fontname = NULL;

    if (Is_block(font)) fontname = String_val (Field(font,0));
    else switch (font) {
    case MLTAG_Fixed_8x13:	fontname = TOGL_BITMAP_8_BY_13; break;
    case MLTAG_Fixed_9x15:	fontname = TOGL_BITMAP_9_BY_15; break;
    case MLTAG_Times_10:	fontname = TOGL_BITMAP_TIMES_ROMAN_10; break;
    case MLTAG_Times_24:	fontname = TOGL_BITMAP_TIMES_ROMAN_24; break;
    case MLTAG_Helvetica_10:	fontname = TOGL_BITMAP_HELVETICA_10; break;
    case MLTAG_Helvetica_12:	fontname = TOGL_BITMAP_HELVETICA_12; break;
    case MLTAG_Helvetica_18:	fontname = TOGL_BITMAP_HELVETICA_18; break;
    }
    return Val_int (Togl_LoadBitmapFont (Addr_val(togl), fontname));
}

ML_2 (Togl_UnloadBitmapFont, Addr_val, Int_val)
ML_2 (Togl_UseLayer, Addr_val, TOGLenum_val)
#ifdef _WIN32
CAMLprim value ml_Togl_ShowOverlay(value v)
{ invalid_argument("Togl_ShowOverlay: not implemented"); return Val_unit; }
#else
ML_1 (Togl_ShowOverlay, Addr_val)
#endif
ML_1 (Togl_HideOverlay, Addr_val)
ML_1 (Togl_PostOverlayRedisplay, Addr_val)
ML_1_ (Togl_ExistsOverlay, Addr_val, Val_int)
ML_1_ (Togl_GetOverlayTransparentValue, Addr_val, Val_int)

CAMLprim value ml_Togl_DumpToEpsFile (value togl, value filename, value rgb)
{
    if (callbacks == NULL) callbacks = caml_named_value ("togl_callbacks");
    if (Togl_DumpToEpsFile(Addr_val(togl), String_val(filename),
			   Int_val(rgb), callback_RenderFunc)
	== TCL_ERROR)
        raise_with_string(*caml_named_value("tkerror"),
                          "Dump to EPS file failed");
    return Val_unit;
}

#if 0 && defined(_WIN32) && !defined(CAML_DLL) && (WINVER < 0x0500)
/* VC7 or later, building with pre-VC7 runtime libraries */
long _ftol( double ); /* defined by VC6 C libs */
long _ftol2( double dblSource ) { return _ftol( dblSource ); }
#endif
