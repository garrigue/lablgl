(* $Id: glMisc.ml,v 1.3 2000-04-12 07:40:24 garrigue Exp $ *)

external get_string : [`vendor|`renderer|`version|`extensions] -> string
    = "ml_glGetString"

type equation = float * float * float * float
external clip_plane : plane:int -> equation -> unit
    = "ml_glClipPlane"
let clip_plane ~plane equation =
  if plane < 0 or plane > 5 then invalid_arg "Gl.clip_plane";
  clip_plane ~plane equation

type hint_target =
    [`fog|`line_smooth|`perspective_correction|`point_smooth|`polygon_smooth]
external hint : hint_target -> [`fastest|`nicest|`dont_care] -> unit
    = "ml_glHint"

external init_names : unit -> unit = "ml_glInitNames"
external load_name : int -> unit = "ml_glLoadName"
external pop_name : unit -> unit = "ml_glPopName"
external push_name : int -> unit = "ml_glPushName"

external pop_attrib : unit -> unit = "ml_glPopAttrib"
type attrib =
    [ `accum_buffer|`color_buffer|`current|`depth_buffer|`enable|`eval|`fog
    | `hint|`lighting|`line|`list|`pixel_mode|`point|`polygon|`polygon_stipple
    | `scissor|`stencil_buffer|`texture|`transform|`viewport ]
external push_attrib : attrib list -> unit = "ml_glPushAttrib"

external pass_through : float -> unit = "ml_glPassThrough"
external render_mode : [`render|`select|`feedback] -> int = "ml_glRenderMode"
external select_buffer : [`uint] Raw.t -> unit = "ml_glSelectBuffer"
