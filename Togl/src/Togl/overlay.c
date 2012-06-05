/* $Id: overlay.c,v 1.7 2005/04/23 07:49:13 gregcouch Exp $ */

/* 
 * Togl - a Tk OpenGL widget
 * Copyright (C) 1996-1997  Brian Paul and Ben Bederson
 * See the LICENSE file for copyright details.
 */


/* 
 * An example Togl program using an overlay.
 */


#include "togl.h"
#include <stdlib.h>
#include <string.h>


/* 
 * The following variable is a special hack that is needed in order for
 * Sun shared libraries to be used for Tcl.
 */
#ifdef SUN
extern int matherr();
int    *tclDummyMathPtr = (int *) matherr;
#endif


/* Overlay color indexes: */
static unsigned long Red, Green;


/* 
 * Togl widget create callback.  This is called by Tcl/Tk when the widget has
 * been realized.  Here's where one may do some one-time context setup or
 * initializations.
 */
void
create_cb(Togl *togl)
{
    /* allocate overlay color indexes */
    Red = Togl_AllocColorOverlay(togl, 1.0, 0.0, 0.0);
    Green = Togl_AllocColorOverlay(togl, 0.0, 1.0, 0.0);

    /* in this demo we always show the overlay */
    if (Togl_ExistsOverlay(togl)) {
        Togl_ShowOverlay(togl);
        printf("Red and green lines are in the overlay\n");
    } else {
        printf("Sorry, this display doesn't support overlays\n");
    }
}


/* 
 * Togl widget reshape callback.  This is called by Tcl/Tk when the widget
 * has been resized.  Typically, we call glViewport and perhaps setup the
 * projection matrix.
 */
void
reshape_cb(Togl *togl)
{
    int     width = Togl_Width(togl);
    int     height = Togl_Height(togl);
    float   aspect = (float) width / (float) height;

    /* Set up viewing for normal plane's context */
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-aspect, aspect, -1.0, 1.0, -1.0, 1.0);
    glMatrixMode(GL_MODELVIEW);

    /* Set up viewing for overlay plane's context */
    if (Togl_ExistsOverlay(togl)) {
        Togl_UseLayer(togl, TOGL_OVERLAY);
        glViewport(0, 0, width, height);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);
        glMatrixMode(GL_MODELVIEW);
        Togl_UseLayer(togl, TOGL_NORMAL);
    }
}


/* 
 * Togl widget overlay display callback.  This is called by Tcl/Tk when the
 * overlay has to be redrawn.
 */
void
overlay_display_cb(Togl *togl)
{
    glClear(GL_COLOR_BUFFER_BIT);

    glIndexi(Red);
    glBegin(GL_LINES);
    glVertex2f(-1.0, -1.0);
    glVertex2f(1.0, 1.0);
    glVertex2f(-1.0, 1.0);
    glVertex2f(1.0, -1.0);
    glEnd();

    glIndexi(Green);
    glBegin(GL_LINE_LOOP);
    glVertex2f(-0.5, -0.5);
    glVertex2f(0.5, -0.5);
    glVertex2f(0.5, 0.5);
    glVertex2f(-0.5, 0.5);
    glEnd();
    glFlush();
}


/* 
 * Togl widget display callback.  This is called by Tcl/Tk when the widget's
 * contents have to be redrawn.  Typically, we clear the color and depth
 * buffers, render our objects, then swap the front/back color buffers.
 */
void
display_cb(Togl *togl)
{
    glClear(GL_COLOR_BUFFER_BIT);

    glLoadIdentity();

    glBegin(GL_TRIANGLES);

    glColor3f(1.0, 0.0, 1.0);
    glVertex2f(-0.5, -0.3);
    glVertex2f(0.5, -0.3);
    glVertex2f(0.0, 0.6);

    glColor3f(1.0, 1.0, 0.0);
    glVertex2f(-0.5 + 0.2, -0.3 - 0.2);
    glVertex2f(0.5 + 0.2, -0.3 - 0.2);
    glVertex2f(0.0 + 0.2, 0.6 - 0.2);

    glColor3f(0.0, 1.0, 1.0);
    glVertex2f(-0.5 + 0.4, -0.3 - 0.4);
    glVertex2f(0.5 + 0.4, -0.3 - 0.4);
    glVertex2f(0.0 + 0.4, 0.6 - 0.4);

    glEnd();

    glFlush();
}


/* 
 * Called by Tk_Main() to let me initialize the modules (Togl) I will need.
 */
TOGL_EXTERN int
Overlay_Init(Tcl_Interp *interp)
{
    /* 
     * Initialize Tcl, Tk, and the Togl widget module.
     */
#ifdef USE_TCL_STUBS
    if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
        return TCL_ERROR;
    }
#endif
#ifdef USE_TK_STUBS
    if (Tk_InitStubs(interp, "8.1", 0) == NULL) {
        return TCL_ERROR;
    }
#endif
    if (Togl_Init(interp) == TCL_ERROR) {
        return TCL_ERROR;
    }

    /* 
     * Specify the C callback functions for widget creation, display,
     * and reshape.
     */
    Togl_CreateFunc(create_cb);
    Togl_DisplayFunc(display_cb);
    Togl_ReshapeFunc(reshape_cb);

    Togl_OverlayDisplayFunc(overlay_display_cb);

    /* 
     * Make a new Togl widget command so the Tcl code can set a C variable.
     */
    /* NONE */

    /* 
     * Call Tcl_CreateCommand for application-specific commands, if
     * they weren't already created by the init procedures called above.
     */
    return TCL_OK;
}
