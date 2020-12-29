#!/bin/bash

source distro-config.inc

SCRIPTNAME="$(basename "$0")"

# Log function helper
function log {
    # Address log levels
    case $1 in
        ERROR)
            loglevel=ERROR                                               
            shift
            ;;
        WARN)
            loglevel=WARNING
            shift
            ;;
        *)
            loglevel=LOG
            ;;
    esac
    printf "[%s][$SCRIPTNAME] %s\n" "$loglevel" "$1"
    if [ "$loglevel" == "ERROR" ]; then
        exit 1
    fi
}

function help {
        cat << EOF
Tool for uploading deb files to bintray.

Options:
        -h, --help
                Display this help and exit.
        -d, --debfile
                The Debian package to upload. Required.
        -k, --apikey
                Bintray API key. Required.
EOF
}

# Parse arguments
while [[ $# -ge 1 ]]; do
    i="$1"
    case $i in
        -h|--help)
            help
            exit 0
            ;;
        -f|--debfile)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            DEB="$2"
            shift
            ;;
        -k|--apikey)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            KEY="$2"
            shift
            ;;
        *)
            log ERROR "Unrecognized option $1."
            ;;
    esac
    shift
done

if [ -z "$KEY" ] || [ -z "$DEB" ]; then
	log ERROR "Required arguments missing. See help."
fi

if [ ! -f "$DEB" ]; then
	log ERROR "Can't find $DEB file."
fi

PACKAGE="$(basename "$DEB" |  sed 's/.deb//g' | cut -d '_' -f1)"
VER="$(basename "$DEB" |  sed 's/.deb//g' | cut -d '_' -f2)"
ARCH="$(basename "$DEB" |  sed 's/.deb//g' | cut -d '_' -f3)"

COMPONENT=main

log "Pushing $DEB to bintray..."
curl -T "$DEB" "-ubalenaos:$KEY" "https://api.bintray.com/content/balenaos/raspbian/$PACKAGE/$VER/pool/main/$(basename "$DEB" | head -c 1)/$PACKAGE/$(basename "$DEB");deb_distribution=$DISTRO;deb_component=$COMPONENT;deb_architecture=$ARCH"
echo
