#!/bin/bash

set -e

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
Tool for converting a Raspbian image into a balenaFin Raspbian one.

Options:
        -h, --help
                Display this help and exit.
        -r, --reboot
                The Debian package to upload. Required.
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
        -r|--reboot)
            REBOOT="1"
            ;;
        *)
            log ERROR "Unrecognized option $1."
            ;;
    esac
    shift
done

if [[ $EUID -ne 0 ]]; then
	log ERROR "This script must be run as root"
fi

log "Importing bintray gpg key..."
curl -fsSL 'https://bintray.com/user/downloadSubjectPublicKey?username=bintray' | apt-key add -

log "Adding balenafin raspbian repository..."
echo "deb https://dl.bintray.com/balenaos/raspbian stretch main" > /etc/apt/sources.list.d/balenafin.list

log "Installing required packages..."
apt-get install apt-transport-https
apt-get update
apt-get upgrade
apt-get install balenafin-firmware raspberrypi-kernel-headers sd8887-mrvl

log "Done. Enjoy your balenaFin!"
if [ "$REBOOT" -eq 1 ]; then
	log WARN "Reboot was requested through arguments. Rebooting in 10 seconds..."
	sleep 10
	reboot
else
	log WARN "In order to have the board pick up the new firmware, please reboot the board."
fi
