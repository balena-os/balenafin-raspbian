ARG DISTRO=buster
FROM balenalib/rpi-raspbian:${DISTRO}

RUN apt-get update
RUN apt-get -y install coreutils quilt parted debootstrap zerofree pxz zip dosfstools bsdtar libcap2-bin grep rsync xz-utils file git curl kmod fakeroot device-tree-compiler dkms
RUN apt-get -y install build-essential dh-make
