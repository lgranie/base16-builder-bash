#!/usr/bin/env bash

function usage() {
  printf "base16-builder-bash -s [SCHEME] -t [TEMPLATE] -o [OUTPUT_DIR]\n"
}

if [ $# -eq 0 ]; then
  usage
fi

# parse arguments from https://stackoverflow.com/questions/192249/
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage;
      exit 0;;
    -s|--scheme)
      SCHEME="$2";
      shift 2;;
    -t|--template)
      TEMPLATE="$2";
      shift 2;;
    -o|--output)
      OUTPUT_DIR="$2";
      shift 2;;
  esac;
done

# default values and additionnals arguments
if [ -z $SCHEME ]; then
  SCHEME_FILE="ALL";
else
  SCHEME_FILE=$(find schemes/ -name "${SCHEME}*" -print)
fi

# analyse TEMPLATE
if [ -z $TEMPLATE ]; then
  TEMPLATE="ALL";
fi

# function found here https://stackoverflow.com/questions/5014632/
# remove comment with https://stackoverflow.com/questions/4798149/
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
  printf "export SCHEME_NAME=\"${SCHEME_SCHEME}\"\n";
  printf "export SCHEME_AUTHOR=\"${SCHEME_AUTHOR}\"\n";
  
  for n in $(seq 0 15); do
     local hex=$(printf "%02X" ${n})
     local scheme_var="SCHEME_BASE${hex}"

     # print HEX colour value
     printf "export BASE${hex}=\"${!scheme_var}\"\n"
     printf "export BASE${hex}_HEX_R=\"%02X\"\n" 0x${!scheme_var:0:2} 
     printf "export BASE${hex}_HEX_G=\"%02X\"\n" 0x${!scheme_var:2:2} 
     printf "export BASE${hex}_HEX_B=\"%02X\"\n" 0x${!scheme_var:4:2}

     # print RGB colour value
     printf "export BASE${hex}_RGB_R=\"%02d\"\n" $((16#${!scheme_var:0:2}))
     printf "export BASE${hex}_RGB_G=\"%02d\"\n" $((16#${!scheme_var:2:2}))
     printf "export BASE${hex}_RGB_B=\"%02d\"\n" $((16#${!scheme_var:4:2}))
     
     # print DEC colour value
     printf "export BASE${hex}_DEC_R=\"%.4f\"\n" $(bc -l <<< "$((16#${!scheme_var:0:2})) / 255")
     printf "export BASE${hex}_DEC_G=\"%.4f\"\n" $(bc -l <<< "$((16#${!scheme_var:2:2})) / 255")
     printf "export BASE${hex}_DEC_B=\"%.4f\"\n" $(bc -l <<< "$((16#${!scheme_var:4:2})) / 255")
  done
}

# uppercasing variables names
# replace '-' with '_' in variables names
function shellify_base16_template () {
  sed -e ":a" -e "s|{{\([^}]*\)-|{{\1_|;t a" \
      -e "s|{{\([^}]*\)|{{\U\1|g" $1
}

# read $TEMPLATE extension
function get_extension() {
  TEMPLATE_CONFIG="templates/"${TEMPLATE}"/templates/config.yaml"
  parse_yaml ${TEMPLATE_CONFIG} "TEMPLATE_"
  echo ${TEMPLATE_DEFAULT_EXTENSION}
}

eval $(parse_yaml ${SCHEME_FILE} "SCHEME_")
eval $(parse_scheme_options)

EXTENSION=$(get_extension ${TEMPLATE})
echo ${EXTENSION}
exit 0
shellify_base16_template $TEMPLATE > /tmp/template
./lib/mo /tmp/template > ${TEMPLATE}.${EXTENSION}

