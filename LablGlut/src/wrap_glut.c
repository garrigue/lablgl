/*
 *  wrap_glut.c
 *  
 *  an OCaml wrapper for a subset of Mark Kilgard's GLUT 
 *
 *  written by ijt
 *
 */

#ifdef __APPLE__
#include <glut.h>
#else
#include <GL/glut.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include <caml/mlvalues.h>
//#include <caml/alloc.h>
#include <caml/memory.h>
//#include <caml/fail.h>
#include <caml/callback.h>

#include "ml_glut.h"

#define VoidPtr_val(x) ((void*) Int_val(x))

ML_0(glutSwapBuffers) /* makes a function called ml_glutSwapBuffers() */
ML_0(glutPostRedisplay)
ML_2(glutInitWindowSize, Int_val, Int_val)
ML_2(glutInitWindowPosition, Int_val, Int_val)
ML_1_(glutCreateWindow, String_val, Val_int)
ML_0(glutMainLoop)
ML_5_(glutCreateSubWindow, Int_val, Int_val, Int_val, Int_val, Int_val, Val_int)
ML_1(glutDestroyWindow, Int_val)
ML_0_(glutGetWindow, Val_int) /* return win id */
ML_1(glutSetWindow, Int_val)
ML_1(glutSetWindowTitle, String_val)
ML_1(glutSetIconTitle, String_val)
ML_2(glutPositionWindow, Int_val, Int_val)
ML_2(glutReshapeWindow, Int_val, Int_val)
ML_0(glutPopWindow)
ML_0(glutPushWindow)
ML_0(glutIconifyWindow)
ML_0(glutShowWindow)
ML_0(glutHideWindow)
ML_0(glutFullScreen)
ML_1(glutSetCursor, Int_val)
ML_0(glutEstablishOverlay)
ML_0(glutRemoveOverlay)
ML_1(glutUseLayer, Int_val)
ML_0(glutPostOverlayRedisplay)
ML_0(glutShowOverlay)
ML_0(glutHideOverlay)
ML_1(glutDestroyMenu, Int_val)
ML_0_(glutGetMenu, Val_int)
ML_1(glutSetMenu, Int_val)
ML_2(glutAddMenuEntry, String_val, Int_val)
ML_2(glutAddSubMenu, String_val, Int_val)
ML_3(glutChangeToMenuEntry, Int_val, String_val, Int_val)
ML_3(glutChangeToSubMenu, Int_val, String_val, Int_val)
ML_1(glutRemoveMenuItem, Int_val)
ML_1(glutAttachMenu, Int_val)
ML_1(glutDetachMenu, Int_val)
ML_4(glutSetColor, Int_val, Float_val, Float_val, Float_val)
ML_2_(glutGetColor, Int_val, Int_val, copy_double)
ML_1(glutCopyColormap, Int_val)
ML_1_(glutGet, Int_val, Val_int)
ML_1_(glutDeviceGet, Int_val, Val_int)
ML_1_(glutExtensionSupported, String_val, Val_bool)
ML_0_(glutGetModifiers, Val_int)
ML_1_(glutLayerGet, Int_val, Val_int)

ML_1_(glutVideoResizeGet, Int_val, Val_int)
ML_0(glutSetupVideoResizing)
ML_0(glutStopVideoResizing)
ML_4(glutVideoResize, Int_val, Int_val, Int_val, Int_val)
ML_4(glutVideoPan, Int_val, Int_val, Int_val, Int_val)
ML_0(glutReportErrors)

ML_3(glutWireSphere, Float_val, Int_val, Int_val)
ML_3(glutSolidSphere, Float_val, Int_val, Int_val)
ML_4(glutWireCone, Float_val, Float_val, Int_val, Int_val)
ML_4(glutSolidCone, Float_val, Float_val, Int_val, Int_val)
ML_1(glutWireCube, Float_val)
ML_1(glutSolidCube, Float_val)
ML_4(glutWireTorus, Float_val, Float_val, Int_val, Int_val)
ML_4(glutSolidTorus, Float_val, Float_val, Int_val, Int_val)
ML_0(glutWireDodecahedron)
ML_0(glutSolidDodecahedron)
ML_1(glutWireTeapot, Float_val)
ML_1(glutSolidTeapot, Float_val)
ML_0(glutWireOctahedron)
ML_0(glutSolidOctahedron)
ML_0(glutWireTetrahedron)
ML_0(glutSolidTetrahedron)
ML_0(glutWireIcosahedron)
ML_0(glutSolidIcosahedron)
ML_1(glutGameModeString, String_val)
ML_0(glutEnterGameMode)
ML_0(glutLeaveGameMode)
ML_1_(glutGameModeGet, Int_val, Val_int)

value ml_glutInit( value v_argc, value v_argv )
{
    int i, argc;
    char** argv; 
  
    /* make an array for GLUT to handle */
    argc = Int_val(v_argc);
    /* the +1 is for the null terminal */
    argv = (char**) malloc(sizeof(char*) * (argc+1)); 
    for(i=0; i<argc; i++) 
    {
        char * arg = String_val(Field(v_argv, i));
        argv[i] = (char*) malloc(strlen(arg)+1);
        strcpy(argv[i], arg);
        argv[i][strlen(arg)] = '\0';
    }
    argv[argc] = NULL;

    glutInit(&argc, argv);

    /* 
    glutInit modifies argv, so we hand the result back to ocaml by repeatedly 
    calling a callback.  
    */
    for(i=0; i<argc; i++) {
        callback(*caml_named_value("add_arg"), copy_string(argv[i]));
    }

    /* clean up */
    for(i=0; i<argc; i++) {
        free(argv[i]);
    }
    free(argv);

    return Val_unit;
}


value native_glutInitDisplayMode(
    value double_buffer, 
    value index, 
    value accum,
    value alpha, 
    value depth,
    value stencil,
    value multisample,
    value stereo,
    value luminance)
{
    unsigned int acc = 0;
    acc |= Bool_val(double_buffer) ? GLUT_DOUBLE : 0; 
    acc |= Bool_val(index) ? GLUT_INDEX : 0; 
    acc |= Bool_val(accum) ? GLUT_ACCUM : 0;
    acc |= Bool_val(alpha) ? GLUT_RGBA : 0; 
    acc |= Bool_val(depth) ? GLUT_DEPTH : 0;
    acc |= Bool_val(stencil) ? GLUT_STENCIL : 0;
    acc |= Bool_val(multisample) ? GLUT_MULTISAMPLE : 0;
    acc |= Bool_val(stereo) ? GLUT_STEREO : 0;
    acc |= Bool_val(luminance) ? GLUT_LUMINANCE : 0;
    glutInitDisplayMode(acc);
    return Val_unit;
}

value bytecode_glutInitDisplayMode ( value * args, int num_args)
{
    assert(num_args == 9);
    native_glutInitDisplayMode(
        args[0],/*double_buffer*/
        args[1],/*index*/
        args[2],/*accum*/
        args[3],/*alpha*/
        args[4],/*depth*/
        args[5],/*stencil*/
        args[6],/*multisample*/
        args[7],/*stereo*/
        args[8] /*luminance*/
    );
    return Val_unit;
}

static char* cbname(const char glutname[])
{
    static char ret[128];
    //printf("cbname\n"); fflush(stdout);
    sprintf(ret, "ocaml_%s_cb_%i", glutname, (int) glutGetWindow());
    //printf("   %s\n", ret); fflush(stdout);
    return ret;
}

/* associations between callback functions and window ids are made on the 
   OCaml side. */

/* TODO: make these easier to read.  gcc was complaining about backslashes,
   for reasons that aren't clear to me. */

#define CB_0(glut_func) static void glut_func ## _cb() { callback(*caml_named_value(cbname(#glut_func)), Val_unit); } value ml_##glut_func(value unit) { glut_func( & glut_func##_cb ); return Val_unit; }

#define CB_1(glut_func, type1, conv1) static void glut_func##_cb( type1 arg1 ) { callback(*caml_named_value(cbname(#glut_func)), conv1(arg1)); } value ml_##glut_func(value unit) { glut_func( & glut_func##_cb ); return Val_unit; }

#define CB_2(glut_func, type1, conv1,  type2, conv2) static void glut_func##_cb( type1 arg1, type2 arg2 ) { callback2(*caml_named_value(cbname(#glut_func)), conv1(arg1), conv2(arg2)); } value ml_##glut_func(value unit) { glut_func( & glut_func##_cb ); return Val_unit; }

#define CB_3(glut_func, type1, conv1,  type2, conv2,  type3, conv3) static void glut_func##_cb( type1 arg1, type2 arg2, type3 arg3 ) { callback3(*caml_named_value(cbname(#glut_func)), conv1(arg1), conv2(arg2), conv3(arg3)); } value ml_##glut_func(value unit) { glut_func( & glut_func##_cb ); return Val_unit; } 

#define CB_4(glut_func, type1, conv1, type2, conv2, type3, conv3, type4, conv4) static void glut_func##_cb( type1 arg1, type2 arg2, type3 arg3, type4 arg4 ) { value args[4]; args[0] = conv1(arg1); args[1] = conv2(arg2); args[2] = conv3(arg3); args[3] = conv4(arg4); callbackN (*caml_named_value(cbname(#glut_func)), 4, args); } value ml_##glut_func(value unit) { glut_func( & glut_func##_cb ); return Val_unit; } 

/* callbacks whose hooking functions have return values */
#define CB_1_(glut_func, type1, conv1, conv) static void glut_func##_cb( type1 arg1 ) { callback(*caml_named_value("ocaml_"#glut_func), conv1(arg1)); } value ml_##glut_func(value unit) { return conv(glut_func( & glut_func##_cb )); }



#if 0
CB_0(glutDisplayFunc)
#else
static void glutDisplayFunc_cb(void)
{
    char * name;
    name = (char*) cbname("glutDisplayFunc");
    //printf("glutDisplayFunc: name = %s\n", name); fflush(stdout);
    callback(*caml_named_value(name), Val_unit);
    //printf("glutDisplayFunc done\n", name); fflush(stdout);
}
value ml_glutDisplayFunc(value unit)
{
    glutDisplayFunc(&glutDisplayFunc_cb);  
    return Val_unit; 
}
#endif

#if 1
CB_1(glutVisibilityFunc, int, Val_int)
#else
static void glutVisibilityFunc_cb(int state)
{
    callback(*caml_named_value(cbname("glutVisibilityFunc")), Val_int(state));
}
value ml_glutVisibilityFunc(value unit)
{
    glutVisibilityFunc(&glutVisibilityFunc_cb);  
    return Val_unit; 
}
#endif

//CB_1_(glutCreateMenu, int, Val_int,  Val_int)
//#define CB_1_(glut_func, type1, conv1, conv) static void glut_func##_cb( type1 arg1 ) { callback(*caml_named_value("ocaml_"#glut_func), conv1(arg1)); } value ml_##glut_func(value unit) { return conv(glut_func( & glut_func##_cb )); }
static void glutCreateMenu_cb( int menu_id ) 
{ 
  // ocaml_glutCreateMenu really means "menu callback on the ocaml side"
  callback(*caml_named_value("ocaml_glutCreateMenu"), Val_int(menu_id)); 
} 
value ml_glutCreateMenu(value unit) 
{ 
  return Val_int(glutCreateMenu(&glutCreateMenu_cb));
}

CB_2(glutReshapeFunc, int, Val_int,  int, Val_int)
CB_3(glutKeyboardFunc, unsigned char, Val_int,  int, Val_int,  int, Val_int)
CB_2(glutMotionFunc, int, Val_int,  int, Val_int)
CB_3(glutSpecialFunc, int, Val_int,  int, Val_int,  int, Val_int)
CB_2(glutPassiveMotionFunc, int, Val_int,  int, Val_int)
CB_1(glutEntryFunc, int, Val_int)
CB_1(glutMenuStateFunc, int, Val_int)
CB_3(glutSpaceballMotionFunc, int, Val_int,  int, Val_int,  int, Val_int)
CB_3(glutSpaceballRotateFunc, int, Val_int,  int, Val_int,  int, Val_int)
CB_2(glutSpaceballButtonFunc, int, Val_int,  int, Val_int)
CB_2(glutButtonBoxFunc, int, Val_int,  int, Val_int) 
CB_2(glutDialsFunc, int, Val_int,  int, Val_int)
CB_2(glutTabletMotionFunc, int, Val_int,  int, Val_int)
CB_4(glutTabletButtonFunc, int, Val_int,  int, Val_int,  int, Val_int,  int, Val_int)
CB_3(glutMenuStatusFunc, int, Val_int,  int, Val_int,  int, Val_int)
CB_0(glutOverlayDisplayFunc)
CB_4(glutMouseFunc, int, Val_int,  int, Val_int,  int, Val_int,  int, Val_int)


value ml_glutSetIdleFuncToNull( value unit )
{
    glutIdleFunc(NULL);
    return Val_unit;
}

#if 0
CB_0(glutIdleFunc)
#else
static void glutIdleFunc_cb(void)
{
    callback (*caml_named_value("ocaml_glutIdleFunc"), Val_unit);
}
value ml_glutIdleFunc( value unit )
{
    glutIdleFunc(&glutIdleFunc_cb);
    return Val_unit;
}
#endif

static void glutTimerFunc_cb(int value)
{
    callback (*caml_named_value("ocaml_glutTimerFunc"), Val_int(value) );
}
value ml_glutTimerFunc( value millis_val, value val_val ) // set Timer callback
{
    unsigned int millis;
    int val;
    val = Int_val(val_val);
    millis = Int_val(millis_val);
    glutTimerFunc( millis, &glutTimerFunc_cb, val ); // register with GLUT
    return Val_unit;
}

/* font stuff */

static int streq(const char s1[], const char s2[]) { 
  return !strcmp(s1, s2);
}

/* integer code to font */
static void* i2font(int i)
{
  switch(i) { 
    case 0: return GLUT_STROKE_ROMAN; 
    case 1: return GLUT_STROKE_MONO_ROMAN; 
    case 2: return GLUT_BITMAP_9_BY_15; 
    case 3: return GLUT_BITMAP_8_BY_13; 
    case 4: return GLUT_BITMAP_TIMES_ROMAN_10; 
    case 5: return GLUT_BITMAP_TIMES_ROMAN_24; 
    case 6: return GLUT_BITMAP_HELVETICA_10; 
    case 7: return GLUT_BITMAP_HELVETICA_12; 
    case 8: return GLUT_BITMAP_HELVETICA_18; 
    default: {
      fprintf(stderr, "wrap_glut.c: unrecognized font. impossible...\n");
      fflush(stderr);
      exit(-1);
    }
  }
}

value ml_glutBitmapCharacter(value font, value c)
{
  glutBitmapCharacter(i2font(Int_val(font)), Int_val(c));
  return Val_unit;
}

value ml_glutBitmapWidth(value font, value c)
{
  return Val_int(glutBitmapWidth(i2font(Int_val(font)), Int_val(c)));
}

value ml_glutStrokeCharacter(value font, value c)
{
  glutStrokeCharacter(i2font(Int_val(font)), Int_val(c)); 
  return Val_unit;
}

value ml_glutStrokeWidth(value font, value c)
{
  return Val_int(glutStrokeWidth(i2font(Int_val(font)), Int_val(c)));
}

/* GLUT 4 functions included with GLUT 3.7 */
ML_1(glutInitDisplayString, String_val) 
ML_2(glutWarpPointer, Int_val, Int_val)

value ml_glutBitmapLength(value font, value str)
{
  /* need to do something about the unsignedness of the chars expected? */
  return Val_int(glutBitmapLength(i2font(Int_val(font)), String_val(str)));
}

value ml_glutStrokeLength(value font, value str)
{
  /* need to do something about the unsignedness of the chars expected? */
  return Val_int(glutStrokeLength(i2font(Int_val(font)), String_val(str)));
}

CB_1(glutWindowStatusFunc,  int, Val_int)

ML_1(glutPostWindowRedisplay, Int_val)

ML_1(glutPostWindowOverlayRedisplay, Val_int)
CB_3(glutKeyboardUpFunc,  unsigned char, Val_int,  int, Val_int,  int, Val_int)
CB_3(glutSpecialUpFunc,  int, Val_int,  int, Val_int,  int, Val_int)
ML_1(glutIgnoreKeyRepeat, Int_val)
ML_1(glutSetKeyRepeat, Int_val)

static void joystick_cb(unsigned int buttonMask, int x, int y, int z)
{
  value args[4]; 
  args[0] = Val_int(buttonMask);
  args[1] = Val_int(x);
  args[2] = Val_int(y);
  args[3] = Val_int(z);
  callbackN (*caml_named_value(cbname("glutJoystickFunc")), 4, args); 
}
value ml_glutJoystickFunc(value pollInterval) 
{ 
  glutJoystickFunc( &joystick_cb, Int_val(pollInterval) );
  return Val_unit;
} 

ML_0(glutForceJoystickFunc)


