#!/bin/bash

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

pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH="$(pwd)"
popd > /dev/null 2>&1
SCRIPTNAME="$(basename $0)"

PACKAGE="$1"

if [ -z "$PACKAGE" ]; then
	log ERROR "Specify a package argument"
fi

PACKAGE_ROOT="$SCRIPTPATH/debs/$PACKAGE"

if [ ! -d "$PACKAGE_ROOT" ];then
	log ERROR "$PACKAGE_ROOT is not a directory."
fi

if [ ! -d "$PACKAGE_ROOT/deb-root/debian" ]; then
	log ERROR "$PACKAGE_ROOT doesn't seem to be a debian package directory."
fi

DEBIAN_ROOT="$PACKAGE_ROOT/deb-root"

log "Change working directory to $DEBIAN_ROOT..."
pushd "$DEBIAN_ROOT" &> /dev/null
	SRC_ROOT="../src"
	VERSION="$(dpkg-parsechangelog | sed -nr '/^Version:/s/Version: (.*:)?(.*)-(.*)/\2/p')"
	NAME="$(dpkg-parsechangelog | sed -nr '/^Source:/s/Source: (.*:)?(.*)/\2/p')"
	if [ -n "$VERSION" ] && [ -n "$NAME" ]; then
		log "Detected package $NAME on version $VERSION."
	else
		log ERROR "Can't detect package name and/or version."
	fi

	SRC_FILE="${NAME}_${VERSION}.orig.tar.xz"
	SRC_FILE_PATH="../$SRC_FILE"

	if [ -d "$SRC_ROOT" ] && [ ! -f "$SRC_FILE_PATH" ]; then
		pushd "$SRC_ROOT" &> /dev/null
			log "Generating source archive... Might take a while..."
			if ! DEBEMAIL=localhost DEBFULLNAME=builder dh_make -s -y -p "${NAME}_${VERSION}" --createorig; then
				log ERROR "Failed to generate source archive."
			fi
			rm -rf debian # remove generated templates as we have our own
		popd &> /dev/null
	fi

	if [ -f "$SRC_FILE_PATH" ]; then
		log "Dearchiving source from $SRC_FILE_PATH..."
		tar -xf "$SRC_FILE_PATH"
	fi

	log "Building..."
	if dpkg-buildpackage -uc -us; then
		log "deb package generated."
	else
		log ERROR "Failed to generate deb package."
	fi

	log "Cleaning..."
	dh clean
	ls -A | grep -v debian | xargs rm -r &> /dev/null
popd &> /dev/null

log "Done."
