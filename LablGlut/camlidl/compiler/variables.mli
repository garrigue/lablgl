(***********************************************************************)
(*                                                                     *)
(*                              CamlIDL                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1999 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0                *)
(*                                                                     *)
(***********************************************************************)

(* $Id: variables.mli,v 1.1 2003-10-28 18:52:35 ijtrotts Exp $ *)

(* Generate temporaries *)

val new_var : string -> string
val new_c_variable : Idltypes.idltype -> string
val new_ml_variable : unit -> string
val new_ml_variable_block : int -> string
val output_variable_declarations : out_channel -> unit
val init_value_block : out_channel -> string -> int -> unit
val copy_values_to_block : out_channel -> string -> string -> int -> unit
val need_context : bool ref
