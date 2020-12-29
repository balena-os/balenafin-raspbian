#!/bin/bash

source distro-config.inc

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
Tool for generating debian packages.

Options:
	-h, --help
		Display this help and exit.
	-p, --package
		Package name.
	-m, --modules-only
		Module only package.
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
        -p|--package)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            PACKAGE="$2"
            shift
            ;;
        -m|--modules-only)
	    modules_only=true
            ;;
        *)
            log ERROR "Unrecognized option $1."
            ;;
    esac
    shift
done

pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH="$(pwd)"
popd > /dev/null 2>&1
SCRIPTNAME="$(basename $0)"

[ -z "$PACKAGE" ] && log ERROR "Package argument not provided. See help."


log "Building $PACKAGE debian package..."
docker build -t balenafin-raspbian --build-arg DISTRO=${DISTRO} --build-arg UID=$(id -u ${USER}) .
docker rm -f balenafin-raspbian-container &> /dev/null
docker run --rm \
	-v "$SCRIPTPATH:/balenafin-raspbian" \
	--name balenafin-raspbian-container \
	-e MODULES_ONLY=${modules_only} \
	balenafin-raspbian \
	/balenafin-raspbian/gen-deb.sh "$PACKAGE"

if [ "$?" -eq 0 ]; then
	log "Debian packages generated for $PACKAGE:"
	ls -al "$SCRIPTPATH/debs/$PACKAGE/$PACKAGE"*
else
	log ERROR "Debian package failed to get generated. See above for logs."
fi
