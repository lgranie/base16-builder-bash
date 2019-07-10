# Base16 Builder BASH
An example BASH implementation of a base16 builder that follows the conventions described at https://github.com/chriskempson/base16.
Requires BASH 5.0 or greater.

## Installation

    git clone https://github.com/lgranie/base16-builder-bash
    cd base16-builder-bash

## Usage

    ./base16-builder-bash.sh -u|--update
Updates all schemes and templates repositories as defined in $CONFIG_DIR/schemes/`schemes.yaml` and $CONFIG_DIR/templates/`templates.yaml`.

    ./base16-builder-bash.sh -s|--scheme [SCHEME]
Build all templates using $SCHEME

    ./base16-builder-bash.sh -t|--template [TEMPLATE]
Build $TEMPLATE using $SCHEME

    ./base16-builder-bash.sh -s|--scheme [SCHEME] -t|--template [TEMPLATE]
Build $TEMPLATE using $SCHEME

    ./base16-builder-bash.sh -o|--output
Specify $OUTPUT_DIR (default is ~/.config/base16)

    ./base16-builder-bash.sh -c|--config_dir
Specify $CONFIG_DIR (default is ~/.config/base16-builder-bash)

## Why BASH?
'Cause bash is everywhere ^^
