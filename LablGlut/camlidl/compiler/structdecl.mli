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

(* $Id: structdecl.mli,v 1.1 2003-10-28 18:52:34 ijtrotts Exp $ *)

(* Generation of converters for structs *)

open Idltypes

val ml_declaration : out_channel -> struct_decl -> unit
val c_declaration : out_channel -> struct_decl -> unit
val declare_transl: out_channel -> struct_decl -> unit
val emit_transl : out_channel -> struct_decl -> unit
