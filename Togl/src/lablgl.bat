@echo off
REM start lablgl toplevel

ocaml -I +labltk -I +lablgl labltk.cma lablgl.cma togl.cma %1 %2 %3 %4 %5 %6 %7 %8 %9
