INCLDIRS = -I +lablGL -I +lablglut

teaspin: trackball.cmi trackball.cmo teaspin.cmo 
	ocamlc $(INCLDIRS) -o teaspin lablgl.cma lablglut.cma trackball.cmo teaspin.cmo 

teaspin.cmo: teaspin.ml
	ocamlc $(INCLDIRS) -c teaspin.ml

trackball.cmi: trackball.mli
	ocamlc $(INCLDIRS) -c trackball.mli

trackball.cmo: trackball.ml
	ocamlc $(INCLDIRS) -c trackball.ml

clean: 
	rm *.cm* teaspin



