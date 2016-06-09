#!/usr/bin/env ocaml
#directory "pkg"
#use "topkg-ext.ml"

module Config = struct
  include Config_default
  let vars =
    [ "NAME", "tuenti-star-validator";
      "VERSION", Git.describe ~chop_v:true "master";
      "MAINTAINER", "Alfredo Beaumont <abeaumont\\@tuenti.com>" ]
end
