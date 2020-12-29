ARG DISTRO=buster
FROM balenalib/rpi-raspbian:${DISTRO}

ARG UID
ARG GID

RUN apt-get update
RUN apt-get -y install coreutils quilt parted debootstrap zerofree pxz zip dosfstools bsdtar libcap2-bin grep rsync xz-utils file git curl kmod fakeroot device-tree-compiler dkms
RUN apt-get -y install build-essential dh-make sudo raspberrypi-kernel-headers bc

ARG UID
RUN adduser --disabled-password --gecos '' --uid $UID  builder && adduser builder sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER builder
