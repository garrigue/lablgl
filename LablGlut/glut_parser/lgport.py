#!/usr/bin/env python

# lgport.py : a utility to partially automate translation of glut demos 
#             to lablglut.  reads from stdin and writes to stdout.
#
# example: lgport.py < mydemo.c   > mydemo.ml
#
# Copyright (c) Issac Trotts 2002
#
# This program is freely distributable without licensing fees 
# and is provided without guarantee or warrantee expressed or 
# implied. This program is -not- in the public domain.
#

import os, sys, string, re

def replace(old, new, lines):
  my_re = re.compile(old)
  for i in range(len(lines)):
    lines[i] = my_re.sub(new, lines[i])

def remove_if(regex, lines):
  my_re = re.compile(regex)
  newlines = []
  for line in lines:
    if not my_re.search(line):
      newlines.append(line)
  return newlines

def strip_newlines(lines):
  l2 = []
  for line in lines:
    l2.append(line[:-1])
  return l2

def find_failures(lines):
  l2 = []
  p_re = re.compile(r'printf\("FAIL:')
  e_re = re.compile(r"\s*exit\(.\);")
  prev_fail = 0
  for i in range(len(lines)-1):
    if p_re.search(lines[i]) and e_re.search(lines[i+1]):
      l2.append(p_re.sub('failwith("', lines[i]))
      prev_fail = 1
    else:
      if not prev_fail:
        l2.append(lines[i])
      prev_fail = 0
  return l2

def glutlower(s):
  lg = len("Glut.")
  s2 = s[:lg]
  for i in range(lg, len(s)):
    if s[i-lg:i] == "Glut." and s[i+1] > 'Z': # do it if next is lower case
      s2 += string.lower(s[i])
    else:
      s2 += s[i]
  return s2

def date():
  d = os.popen("date")
  ll = d.readlines()
  d.close()
  return ll[0][:-1]

lines = strip_newlines(sys.stdin.readlines())

replace("glClear", "GlClear.clear", lines)
replace("glFlush", "Gl.flush",      lines)
replace(r"/\*",    "(*",            lines)
replace(r"\*/",    "*)",            lines)
replace("!=",      "<>",            lines)
replace(r"\bglut",  "Glut.",         lines)
replace(r"\bGLUT_", "Glut.",         lines)

lines = map(glutlower, lines)

lines = find_failures(lines) 

replace("==",      "=",             lines)
replace("switch\s*\((.*)\)\s*{\s*$",  r"match \1 with",         lines)
replace(",",               r" ",        lines)
replace(r"^}\s*$",         r"  ;;",     lines)
replace(r'([^|])\|([^|])', r'\1 lor \2', lines)
replace(r'([^&])&([^&])',  r'\1 land \2', lines)
replace(r"\bcase\b(.*):",  r"|\1 ->",   lines)
replace(r"\b(.*)\b\+\+",   r"incr \1",  lines)
replace(r"default\s*:",    r"| _ -> ",  lines)
replace(r'!',              r' not ',    lines)
replace(r"if(.*){",        r"if\1then", lines)
replace(r'\[([^]]+)\]',    r'.(\1)',    lines) # array elts

lines = remove_if(r"^\s*{\s*$",             lines)
lines = remove_if(r"^\s*}\s*$",             lines)

lines.append("let _ = main();;")

lines = [
  "#!/usr/bin/env lablglut", 
  "", 
  "(* Ported to lablglut by Issac Trotts on "+date()+". *)",
  "",
  "open Printf"] + lines

for line in lines: print line

