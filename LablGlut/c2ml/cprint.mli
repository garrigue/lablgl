
val print : out_channel -> Cabs.file -> unit
(*d 
[Cprint.print output definitions] displays the given [definitions] in
C abstract syntax back into text form on the given [output].
*)
  
val set_tab : int -> unit
(*d
[Cprint.set_tab indentation] change the size in characters of indentation
step of FrontC pretty-printer.
*)

val set_width : int -> unit
(*d
[Cprint.set_width width] change the width in characters of the page of
FrontC pretty-printer.
*)