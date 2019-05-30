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
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(toupper(vname[i]))("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, toupper($2), $3);
      }
   }'
}

# create variables set for mustache
function parse_scheme_options {
  printf "SCHEME_NAME=\"${SCHEME_SCHEME}\"\n";
  printf "SCHEME_AUTHOR=\"${SCHEME_AUTHOR}\"\n";
  
  for n in $(seq 0 15); do
     scheme_var="SCHEME_BASE${hex}"

     # print hex colour value
     hex=$(printf "%02X" $n)
     printf "BASE${hex}=\"${!scheme_var}\"\n"
     printf "BASE${hex}_HEX_R=\"%02X\"\n" 0x${!scheme_var:0:2} 
     printf "BASE${hex}_HEX_G=\"%02X\"\n" 0x${!scheme_var:2:2} 
     printf "BASE${hex}_HEX_B=\"%02X\"\n" 0x${!scheme_var:4:2}

     # print dec colour value
     dec=$(printf "%02d" $((16#$n)))
     printf "BASE${dec}_DEC_R=\"%02d\"\n" $((16#${!scheme_var:0:2}))
     printf "BASE${dec}_DEC_G=\"%02d\"\n" $((16#${!scheme_var:2:2}))
     printf "BASE${dec}_DEC_B=\"%02d\"\n" $((16#${!scheme_var:4:2}))
  done
}

function shellify_base16_template () {
  sed -e ':a' -e 's|{{\([^}]*\)-|{{\1_|;t a' -e 's|{{\([^}]*\)|{{\U\1|g' $1
}

eval $(parse_yaml $1 "SCHEME_")
eval $(parse_scheme_options)
#$(shellify_base16_template $2) | ./lib/mo

