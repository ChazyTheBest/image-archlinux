## -*- docker-image-name: "armbuild/scw-distrib-archlinux:latest" -*-
FROM armbuild/archlinux-disk:2014-12-02
MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Environment
ENV SCW_BASE_IMAGE armbuild/scw-archlinux:2014-12-02


# Force openssl upgrade first (bad symbol issue)
RUN pacman -Sy --noconfirm --force openssl


# Install packages
RUN pacman -Sy --noconfirm \
    bash-completion \
    bc \
    binutils \
    cronie \
    curl \
    dhcpcd \
    dnsutils \
    fakeroot \
    file \
    htop \
    iptables \
    less \
    localepurge \
    lsb-release \
    man \
    mg \
    nano \
    nbd \
    ntp \
    openbsd-netcat \
    openssh \
    rsync \
    rsyslog \
    screen \
    socat \
    sudo \
    tmux \
    vim \
    wget


# Locales
RUN sed -e s/^\#en_US.UTF-8/en_US.UTF-8/ -i /etc/locale.gen \
 && locale-gen


# Patch rootfs
RUN curl -Lkq http://j.mp/scw-skeleton | FLAVORS=common,docker-based,systemd bash -e
ADD ./patches/etc/ /etc/
ADD ./patches/usr/ /usr/


# Systemd
RUN systemctl enable \
	scw-fetch-ssh-keys \
	scw-sync-kernel-modules \
	scw-generate-ssh-keys \
	scw-gen-machine-id.service \
	ntpdate.service \
	sshd.service \
	serial-getty@ttyS0.service \
  && systemctl mask \
	getty@tty1.service


# packages upgrade
RUN pacman --noconfirm -Suy


# Remove root password
RUN passwd -d root


# Cleanup
RUN pacman-db-upgrade \
 && pacman -Rns linux-armv7 --noconfirm \
 && pacman -Sc --noconfirm \
 && rm -rf /var/cache/pacman/pkg \
 && localepurge-config && localepurge \
 && pacman-db-upgrade
