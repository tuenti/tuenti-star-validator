#!/usr/bin/env ocaml
#directory "pkg";;
#use "topkg.ml";;

let alcotest = Env.bool "alcotest"
let () = Pkg.describe "tuenti-star-validator" ~builder:(`Other("corebuild" "_build")) [
    Pkg.lib "pkg/META";
    Pkg.lib ~exts:Exts.module_library "score";
    Pkg.bin ~auto:true "validator";
    Pkg.bin ~cond:alcotest ~auto:true "score_tests";
    Pkg.doc "README.md"; ]
