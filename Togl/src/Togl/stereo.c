/* $Id: stereo.c,v 1.6 2005/04/23 07:49:13 gregcouch Exp $ */

/* 
 * Togl - a Tk OpenGL widget
 * Copyright (C) 1996-1997  Brian Paul and Ben Bederson
 * See the LICENSE file for copyright details.
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


static GLuint FontBase;
static float xAngle = 0.0, yAngle = 0.0, zAngle = 0.0;
static GLfloat CornerX, CornerY, CornerZ;       /* where to print strings */
static GLfloat scale = 1.0;



/* 
 * Togl widget create callback.  This is called by Tcl/Tk when the widget has
 * been realized.  Here's where one may do some one-time context setup or
 * initializations.
 */
void
create_cb(Togl *togl)
{
    FontBase = Togl_LoadBitmapFont(togl, TOGL_BITMAP_8_BY_13);
    if (!FontBase) {
        printf("Couldn't load font!\n");
        exit(1);
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

    glViewport(0, 0, width, height);

    /* Set up projection transform */
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-aspect, aspect, -1.0, 1.0, 1.0, 10.0);

    CornerX = -aspect;
    CornerY = -1.0;
    CornerZ = -1.1;

    /* Change back to model view transform for rendering */
    glMatrixMode(GL_MODELVIEW);
}



static void
print_string(const char *s)
{
    glCallLists(strlen(s), GL_UNSIGNED_BYTE, s);
}


/* 
 * Togl widget display callback.  This is called by Tcl/Tk when the widget's
 * contents have to be redrawn.  Typically, we clear the color and depth
 * buffers, render our objects, then swap the front/back color buffers.
 */
void
display_cb(Togl *togl)
{
    const char *ident;
    GLfloat eyeDist = 2.0;
    GLfloat eyeOffset = 0.05;

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glLoadIdentity();           /* Reset modelview matrix to the identity
                                 * matrix */
    glTranslatef(0.0, 0.0, -3.0);       /* Move the camera back three units */
    glScalef(scale, scale, scale);      /* Zoom in and out */
    glRotatef(xAngle, 1.0, 0.0, 0.0);   /* Rotate by X, Y, and Z angles */
    glRotatef(yAngle, 0.0, 1.0, 0.0);
    glRotatef(zAngle, 0.0, 0.0, 1.0);

    glEnable(GL_DEPTH_TEST);

    /* stereo right eye */
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    Togl_StereoFrustum(-1, 1, -1, 1, 1, 10, eyeDist, eyeOffset);
    glMatrixMode(GL_MODELVIEW);
#ifdef OLD_STEREO
    Togl_OldStereoDrawBuffer(GL_BACK_RIGHT);
    Togl_OldStereoClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
#else
    glDrawBuffer(GL_BACK_RIGHT);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
#endif

    /* Front face */
    glBegin(GL_QUADS);
    glColor3f(0.0, 0.7, 0.1);   /* Green */
    glVertex3f(-1.0, 1.0, 1.0);
    glVertex3f(1.0, 1.0, 1.0);
    glVertex3f(1.0, -1.0, 1.0);
    glVertex3f(-1.0, -1.0, 1.0);
    /* Back face */
    glColor3f(0.9, 1.0, 0.0);   /* Yellow */
    glVertex3f(-1.0, 1.0, -1.0);
    glVertex3f(1.0, 1.0, -1.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(-1.0, -1.0, -1.0);
    /* Top side face */
    glColor3f(0.2, 0.2, 1.0);   /* Blue */
    glVertex3f(-1.0, 1.0, 1.0);
    glVertex3f(1.0, 1.0, 1.0);
    glVertex3f(1.0, 1.0, -1.0);
    glVertex3f(-1.0, 1.0, -1.0);
    /* Bottom side face */
    glColor3f(0.7, 0.0, 0.1);   /* Red */
    glVertex3f(-1.0, -1.0, 1.0);
    glVertex3f(1.0, -1.0, 1.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(-1.0, -1.0, -1.0);
    glEnd();

    /* stereo left eye */
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    Togl_StereoFrustum(-1, 1, -1, 1, 1, 10, eyeDist, -eyeOffset);
    glMatrixMode(GL_MODELVIEW);

#ifdef OLD_STEREO
    Togl_OldStereoDrawBuffer(GL_BACK_LEFT);
    Togl_OldStereoClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
#else
    glDrawBuffer(GL_BACK_LEFT);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
#endif

    /* Front face */
    glBegin(GL_QUADS);
    glColor3f(0.0, 0.7, 0.1);   /* Green */
    glVertex3f(-1.0, 1.0, 1.0);
    glVertex3f(1.0, 1.0, 1.0);
    glVertex3f(1.0, -1.0, 1.0);
    glVertex3f(-1.0, -1.0, 1.0);
    /* Back face */
    glColor3f(0.9, 1.0, 0.0);   /* Yellow */
    glVertex3f(-1.0, 1.0, -1.0);
    glVertex3f(1.0, 1.0, -1.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(-1.0, -1.0, -1.0);
    /* Top side face */
    glColor3f(0.2, 0.2, 1.0);   /* Blue */
    glVertex3f(-1.0, 1.0, 1.0);
    glVertex3f(1.0, 1.0, 1.0);
    glVertex3f(1.0, 1.0, -1.0);
    glVertex3f(-1.0, 1.0, -1.0);
    /* Bottom side face */
    glColor3f(0.7, 0.0, 0.1);   /* Red */
    glVertex3f(-1.0, -1.0, 1.0);
    glVertex3f(1.0, -1.0, 1.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(-1.0, -1.0, -1.0);
    glEnd();


    glDisable(GL_DEPTH_TEST);
    glLoadIdentity();
    glColor3f(1.0, 1.0, 1.0);
    glRasterPos3f(CornerX, CornerY, CornerZ);
    glListBase(FontBase);
    /* ident = Togl_Ident( togl ); if (strcmp(ident,"Single")==0) {
     * print_string( "Single buffered" ); } else { print_string( "Double
     * buffered" ); } */
    print_string(Togl_Ident(togl));
    Togl_SwapBuffers(togl);
}


int
setXrot_cb(Togl *togl, int argc, CONST84 char *argv[])
{
    Tcl_Interp *interp = Togl_Interp(togl);

    /* error checking */
    if (argc != 3) {
        Tcl_SetResult(interp,
                "wrong # args: should be \"pathName setXrot ?angle?\"",
                TCL_STATIC);
        return TCL_ERROR;
    }

    xAngle = atof(argv[2]);

    /* printf( "before %f ", xAngle ); */

    if (xAngle < 0.0) {
        xAngle += 360.0;
    } else if (xAngle > 360.0) {
        xAngle -= 360.0;
    }

    /* printf( "after %f \n", xAngle ); */

    Togl_PostRedisplay(togl);

    /* Let result string equal value */
    strcpy(interp->result, argv[2]);
    return TCL_OK;
}


int
setYrot_cb(Togl *togl, int argc, CONST84 char *argv[])
{
    Tcl_Interp *interp = Togl_Interp(togl);

    /* error checking */
    if (argc != 3) {
        Tcl_SetResult(interp,
                "wrong # args: should be \"pathName setYrot ?angle?\"",
                TCL_STATIC);
        return TCL_ERROR;
    }

    yAngle = atof(argv[2]);

    if (yAngle < 0.0) {
        yAngle += 360.0;
    } else if (yAngle > 360.0) {
        yAngle -= 360.0;
    }

    Togl_PostRedisplay(togl);

    /* Let result string equal value */
    strcpy(interp->result, argv[2]);
    return TCL_OK;
}


int
getXrot_cb(ClientData clientData, Tcl_Interp *interp,
        int argc, CONST84 char *argv[])
{
    sprintf(interp->result, "%d", (int) xAngle);
    return TCL_OK;
}


int
getYrot_cb(ClientData clientData, Tcl_Interp *interp,
        int argc, CONST84 char *argv[])
{
    sprintf(interp->result, "%d", (int) yAngle);
    return TCL_OK;
}


int
scale_cb(Togl *togl, int argc, CONST84 char *argv[])
{
    Tcl_Interp *interp = Togl_Interp(togl);

    /* error checking */
    if (argc != 3) {
        Tcl_SetResult(interp,
                "wrong # args: should be \"pathName scale ?value?\"",
                TCL_STATIC);
        return TCL_ERROR;
    }

    scale = atof(argv[2]);

    Togl_PostRedisplay(togl);

    /* Let result string equal value */
    strcpy(interp->result, argv[2]);
    return TCL_OK;
}


TOGL_EXTERN int
Stereo_Init(Tcl_Interp *interp)
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

    /* 
     * Make a new Togl widget command so the Tcl code can set a C variable.
     */

    Togl_CreateCommand("setXrot", setXrot_cb);
    Togl_CreateCommand("setYrot", setYrot_cb);
    Togl_CreateCommand("scale", scale_cb);

    /* 
     * Call Tcl_CreateCommand for application-specific commands, if
     * they weren't already created by the init procedures called above.
     */

    Tcl_CreateCommand(interp, "getXrot", getXrot_cb, (ClientData) NULL,
            (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "getYrot", getYrot_cb, (ClientData) NULL,
            (Tcl_CmdDeleteProc *) NULL);

    return TCL_OK;
}
