#!/usr/bin/env bash

# function found here https://stackoverflow.com/questions/5014632/
# remove comment with https:/:stackoverflow.com/questions/4798149/
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -e "s|#.*||g" \
      -ne "s|^\($s\):|\1|" \
       -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
       -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# create variables set for mustache
function parse_scheme_options {
  printf "scheme-name=\"${SCHEME_scheme}\"\n";
  printf "scheme-author=\"${SCHEME_author}\"\n";
  
  for n in $(seq 0 15); do
     hex=$(printf "%02X" $n)
     scheme_var="SCHEME_base$hex"

     # print hex color value
     printf "base$hex=\"${!scheme_var}\"\n"
     printf "base$hex-hex-r=\"%02X\"\n" 0x${!scheme_var:0:2} 
     printf "base$hex-hex-g=\"%02X\"\n" 0x${!scheme_var:2:2} 
     printf "base$hex-hex-b=\"%02X\"\n" 0x${!scheme_var:4:2}
  done
}

eval $(parse_yaml $1 "SCHEME_")
eval "env '$(parse_scheme_options)' ./lib/mo $2"
