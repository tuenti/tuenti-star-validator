all: lib validator test

lib: score.mli score.ml
	corebuild score.cmx

validator: score.mli score.ml validator.ml
	corebuild validator.native

test: lib score_tests.ml
	corebuild score_tests.native

clean:
	rm -rf *.native *.cmx _build
