type parsing_result = PARSING_ERROR | PARSING_OK of Cabs.definition list
(*d
This is the return type of a parse job from FrontC. PARSING_ERROR value is
returned when there's an error during parsing. (PARSING_OK definitions)
is the result of a successful parsing. [definitions] are a
[Cabs.definition] list.
*)
  
val parse_interactive : in_channel -> out_channel -> parsing_result
(*d
[Frontc.parse_interactive input error] parses a C program from  an
interactive input channel and display errors on the [error] channel.
[!quit!] or ^D will stop parsing.
*)

  val parse_console : 'a -> parsing_result
(*d
[FrontC.parse_console ()] works like [Frontc.parse_interactive] but use
standard input and standard error channels.
*)
  
val parse_file : string -> out_channel -> parsing_result
(*d
[FrontC.parse_file file_name error] parses a C program from the given
[file_name] and output errors on the [error] channel.
*)