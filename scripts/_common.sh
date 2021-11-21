#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

# dependencies used by the app
pkg_dependencies="postgresql python3 python3-pip python3-dev imagemagick fonts-liberation optipng gnupg libpq-dev libmagic-dev mime-support unpaper ghostscript icc-profiles-free qpdf liblept5 libxml2 pngquant zlib1g tesseract-ocr redis-server"

#=================================================
# PERSONAL HELPERS
#=================================================

paperless_set_paperless_path_url () {
    if [[ "$1" == "/" ]]
    then
        paperless_path_url=""
    else
        paperless_path_url=$1
    fi
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
