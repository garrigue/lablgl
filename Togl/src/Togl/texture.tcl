# $Id: texture.tcl,v 1.2 1998-09-16 10:17:32 garrigue Exp $

# Togl - a Tk OpenGL widget
# Copyright (C) 1996  Brian Paul and Ben Bederson
# See the LICENSE file for copyright details.


# $Log: texture.tcl,v $
# Revision 1.2  1998-09-16 10:17:32  garrigue
# patched for use with LablGL
#
# Revision 1.1  1996/10/23 23:18:36  brianp
# Initial revision
#


# Togl texture map demo



# Called magnification filter changes
proc new_magfilter {} {
    global magfilter
    .view mag_filter $magfilter
}


# Called minification filter changes
proc new_minfilter {} {
    global minfilter
    .view min_filter $minfilter
}


# Called when texture image radio button changes
proc new_image {} {
    global teximage
    .view image $teximage
}


# Called when texture S wrap button changes
proc new_swrap {} {
    global swrap
    .view swrap $swrap
}


# Called when texture T wrap button changes
proc new_twrap {} {
    global twrap
    .view twrap $twrap
}


# Called when texture environment radio button selected
proc new_env {} {
    global envmode
    .view envmode $envmode
}


# Called when polygon color sliders change
proc new_color { foo } {
    global poly_red poly_green poly_blue
    .view polycolor $poly_red $poly_green $poly_blue
}


proc new_coord_scale { name element op } {
    global coord_scale
    .view coord_scale $coord_scale
}




# Make the widgets
proc setup {} {
    global magfilter
    global minfilter
    global teximage
    global swrap
    global twrap
    global envmode
    global poly_red
    global poly_green
    global poly_blue
    global coord_scale
    global startx starty         # location of mouse when button pressed
    global xangle yangle
    global xangle0 yangle0
    global scale scale0

    wm title . "Texture Map Options"

    ### The OpenGL window
    togl .view -width 500 -height 400 -rgba true -double true -depth true


    ### Filter radio buttons
    frame .filter -relief ridge -borderwidth 3

    frame .filter.mag -relief ridge -borderwidth 2

    label .filter.mag.label -text "Magnification Filter" -anchor w
    radiobutton .filter.mag.nearest -text GL_NEAREST -anchor w -variable magfilter -value GL_NEAREST -command new_magfilter
    radiobutton .filter.mag.linear -text GL_LINEAR -anchor w -variable magfilter -value GL_LINEAR -command new_magfilter

    frame .filter.min -relief ridge -borderwidth 2

    label .filter.min.label -text "Minification Filter" -anchor w
    radiobutton .filter.min.nearest -text GL_NEAREST -anchor w -variable minfilter -value GL_NEAREST -command new_minfilter
    radiobutton .filter.min.linear -text GL_LINEAR -anchor w -variable minfilter -value GL_LINEAR -command new_minfilter
    radiobutton .filter.min.nearest_mipmap_nearest -text GL_NEAREST_MIPMAP_NEAREST -anchor w -variable minfilter -value GL_NEAREST_MIPMAP_NEAREST -command new_minfilter
    radiobutton .filter.min.linear_mipmap_nearest -text GL_LINEAR_MIPMAP_NEAREST -anchor w -variable minfilter -value GL_LINEAR_MIPMAP_NEAREST -command new_minfilter
    radiobutton .filter.min.nearest_mipmap_linear -text GL_NEAREST_MIPMAP_LINEAR -anchor w -variable minfilter -value GL_NEAREST_MIPMAP_LINEAR -command new_minfilter
    radiobutton .filter.min.linear_mipmap_linear -text GL_LINEAR_MIPMAP_LINEAR -anchor w -variable minfilter -value GL_LINEAR_MIPMAP_LINEAR -command new_minfilter

    pack .filter.mag -fill x
    pack .filter.mag.label -fill x
    pack .filter.mag.nearest -side top -fill x
    pack .filter.mag.linear -side top -fill x

    pack .filter.min -fill both -expand true
    pack .filter.min.label -side top -fill x
    pack .filter.min.nearest -side top -fill x
    pack .filter.min.linear -side top -fill x 
    pack .filter.min.nearest_mipmap_nearest  -side top -fill x
    pack .filter.min.linear_mipmap_nearest  -side top -fill x
    pack .filter.min.nearest_mipmap_linear  -side top -fill x
    pack .filter.min.linear_mipmap_linear  -side top -fill x


    ### Texture coordinate scale and wrapping
    frame .coord -relief ridge -borderwidth 3
    frame .coord.scale -relief ridge -borderwidth 2
    label .coord.scale.label -text "Max Texture Coord" -anchor w
    entry .coord.scale.entry -textvariable coord_scale
    trace variable coord_scale w new_coord_scale

    frame .coord.s -relief ridge -borderwidth 2
    label .coord.s.label -text "GL_TEXTURE_WRAP_S" -anchor w
    radiobutton .coord.s.repeat -text "GL_REPEAT" -anchor w -variable swrap -value GL_REPEAT -command new_swrap
    radiobutton .coord.s.clamp -text "GL_CLAMP" -anchor w -variable swrap -value GL_CLAMP -command new_swrap

    frame .coord.t -relief ridge -borderwidth 2
    label .coord.t.label -text "GL_TEXTURE_WRAP_T" -anchor w
    radiobutton .coord.t.repeat -text "GL_REPEAT" -anchor w -variable twrap -value GL_REPEAT -command new_twrap
    radiobutton .coord.t.clamp -text "GL_CLAMP" -anchor w -variable twrap -value GL_CLAMP -command new_twrap

    pack .coord.scale -fill both -expand true
    pack .coord.scale.label -side top -fill x
    pack .coord.scale.entry -side top -fill x

    pack .coord.s -fill x
    pack .coord.s.label -side top -fill x
    pack .coord.s.repeat -side top -fill x
    pack .coord.s.clamp -side top -fill x

    pack .coord.t -fill x
    pack .coord.t.label -side top -fill x
    pack .coord.t.repeat -side top -fill x
    pack .coord.t.clamp -side top -fill x


    ### Texture image radio buttons (just happens to fit into the coord frame)
    frame .coord.image -relief ridge -borderwidth 2
    label .coord.image.label -text "Texture Image" -anchor w
    radiobutton .coord.image.checker -text "Checker" -anchor w -variable teximage -value CHECKER -command new_image
    radiobutton .coord.image.tree -text "Tree" -anchor w -variable teximage -value TREE -command new_image
    radiobutton .coord.image.face -text "Face" -anchor w -variable teximage -value FACE -command new_image
    pack .coord.image  -fill x
    pack .coord.image.label -side top -fill x
    pack .coord.image.checker -side top -fill x
    pack .coord.image.tree -side top -fill x
    pack .coord.image.face -side top -fill x


    ### Texture Environment
    frame .env -relief ridge -borderwidth 3
    label .env.label -text "GL_TEXTURE_ENV_MODE" -anchor w
    radiobutton .env.modulate -text "GL_MODULATE" -anchor w -variable envmode -value GL_MODULATE -command new_env
    radiobutton .env.decal -text "GL_DECAL" -anchor w -variable envmode -value GL_DECAL -command new_env
    radiobutton .env.blend -text "GL_BLEND" -anchor w -variable envmode -value GL_BLEND -command new_env
    pack .env.label -fill x
    pack .env.modulate -side top -fill x
    pack .env.decal -side top -fill x
    pack .env.blend -side top -fill x

    ### Polygon color
    frame .color -relief ridge -borderwidth 3
    label .color.label -text "Polygon color" -anchor w
    scale .color.red -label Red -from 0 -to 255 -orient horizontal -variable poly_red -command new_color
    scale .color.green -label Green -from 0 -to 255 -orient horizontal -variable poly_green -command new_color
    scale .color.blue -label Blue -from 0 -to 255 -orient horizontal -variable poly_blue -command new_color
    pack .color.label -fill x
    pack .color.red -side top -fill x
    pack .color.green -side top -fill x
    pack .color.blue -side top -fill x


    ### Main widgets
    pack .view -fill both -expand true
    pack .filter -side left -fill y
    pack .coord -side left -fill y
    pack .env -side top -fill x
    pack .color -fill x

    bind .view <ButtonPress-1> {
	set startx %x
	set starty %y
	set xangle0 $xangle
	set yangle0 $yangle
    }

    bind .view <B1-Motion> {
        set xangle [expr $xangle0 + (%x - $startx) / 3.0 ]
        set yangle [expr $yangle0 + (%y - $starty) / 3.0 ]
        .view yrot $xangle
        .view xrot $yangle
    }

    bind .view <ButtonPress-2> {
	set startx %x
	set starty %y
	set scale0 $scale
    }

    bind .view <B2-Motion> {
        set q [ expr ($starty - %y) / 400.0 ]
	set scale [expr $scale0 * exp($q)]
        .view scale $scale
    }

    # set default values:
    set minfilter GL_NEAREST_MIPMAP_LINEAR
    set magfilter GL_LINEAR
    set swrap GL_REPEAT
    set twrap GL_REPEAT
    set envmode GL_MODULATE
    set teximage CHECKER
    set poly_red 255
    set poly_green 255
    set poly_blue 255
    set coord_scale 1.0

    set xangle 0.0
    set yangle 0.0
    set scale 1.0
}


# Execution starts here!
setup

