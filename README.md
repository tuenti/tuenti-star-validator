# Submission validator and score calculator for #TuentiChallenge6's Tuenti Star challenge

The submission validator and score calculator used for the [20th challenge](https://contest.tuenti.net/Challenges?id=20) in [Tuenti Challenge 6](https://contest.tuenti.net). You can see problem description at DESCRIPTION.md and the input for the challenge at input.txt.

## Installation
Our validator is written in [OCaml](http://ocaml.org), and depends on [Core](https://opam.ocaml.org/packages/core/core.113.33.03/) and [Alcotest](https://opam.ocaml.org/packages/alcotest/alcotest.0.4.11/) (only needed to build the testsuite) packages. [OPAM](https://opam.ocaml.org) (1.2.0 or later) can be used to install both a recent version of OCaml (4.01.0 or later) and the dependencies. Look at OPAM's [install](https://opam.ocaml.org/doc/Install.html) and [usage](https://opam.ocaml.org/doc/Usage.html) instructions if needed. To install the dependencies just do:

```sh
opam install core alcotest
```

To build the validator:

```sh
make validator
```

Look at Makefile file for additional build options.

## Usage

To validate a solution and get a score:

```sh
./validator.native input.txt my_optimum_solution.txt
```

## LICENSE

Licensed under the Apache License, Version 2.0. See LICENSE for details.