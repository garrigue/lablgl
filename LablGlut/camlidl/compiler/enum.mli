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

(* $Id: enum.mli,v 1.1 2003-10-28 18:52:31 ijtrotts Exp $ *)

(* Handling of enums *)

open Idltypes

val enum_ml_to_c : 
  (out_channel -> bool -> Prefix.t -> idltype -> string -> string -> unit) ->
    out_channel -> enum_decl -> string -> string -> unit
val enum_c_to_ml : 
  (out_channel -> Prefix.t -> idltype -> string -> string -> unit) ->
    out_channel -> enum_decl -> string -> string -> unit

val enumset_ml_to_c : 
  (out_channel -> bool -> Prefix.t -> idltype -> string -> string -> unit) ->
    out_channel -> enum_decl -> string -> string -> unit
val enumset_c_to_ml : 
  (out_channel -> Prefix.t -> idltype -> string -> string -> unit) ->
    out_channel -> enum_decl -> string -> string -> unit

