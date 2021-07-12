#!/bin/bash

set -e

DISTRO=$(grep VERSION_CODENAME < /etc/os-release | cut -d "=" -f2)

SCRIPTNAME="$(basename "$0")"
REBOOT=0

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
                Reboot the device after the update.
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

curl -1sLf 'https://dl.cloudsmith.io/public/balena/raspbian/gpg.B7FAEF712E16C847.key' | apt-key add

log "Adding balenaFin Raspbian repository..."
echo "deb https://dl.cloudsmith.io/public/balena/raspbian/deb/raspbian ${DISTRO} main" > /etc/apt/sources.list.d/balenafin.list

log "Installing required packages..."
apt-get -y update
apt-get -y install apt-transport-https
apt-get -y full-upgrade
apt-get -y install balenafin-firmware raspberrypi-kernel-headers sd8887-nxp

log "Done. Enjoy your balenaFin board!"
if [ "$REBOOT" -eq 1 ]; then
	log WARN "Reboot was requested through arguments. Rebooting in 10 seconds..."
	sleep 10
	reboot
else
	log WARN "In order to have the board pick up the new firmware, please reboot the board."
fi
