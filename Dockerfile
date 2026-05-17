FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        dbus-x11 \
        dbus \
        xfce4 \
        xfce4-goodies \
        xfce4-terminal \
        xfce4-whiskermenu-plugin \
        tigervnc-standalone-server \
        tigervnc-common \
        novnc \
        python3-websockify \
        firefox \
        wget \
        curl \
        git \
        nano \
        vim \
        sudo \
        locales \
        fonts-noto \
        fonts-noto-cjk \
        papirus-icon-theme \
        pulseaudio \
        pavucontrol \
        thunar \
        mousepad \
        ristretto \
        htop \
        neofetch \
        gnome-themes-extra \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN git clone --depth=1 https://github.com/ZorinOS/zorin-desktop-themes.git /tmp/zorin-desktop-themes && \
    mkdir -p /usr/share/themes && \
    cp -r /tmp/zorin-desktop-themes/*/ /usr/share/themes/ && \
    rm -rf /tmp/zorin-desktop-themes

RUN git clone --depth=1 https://github.com/ZorinOS/zorin-icon-themes.git /tmp/zorin-icon-themes && \
    mkdir -p /usr/share/icons && \
    cp -r /tmp/zorin-icon-themes/*/ /usr/share/icons/ && \
    rm -rf /tmp/zorin-icon-themes

RUN mkdir -p /usr/share/backgrounds/zorin && \
    wget -q "https://raw.githubusercontent.com/ZorinOS/zorin-wallpapers/master/backgrounds/Zorin-12-Light.png" -O /usr/share/backgrounds/zorin/zorin.jpg 2>/dev/null || true

COPY wallpapers/ /usr/share/backgrounds/zorin/

RUN useradd -m -s /bin/bash -G sudo zorin && \
    echo "zorin:zorin" | chpasswd && \
    echo "zorin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/zorin && \
    chmod 440 /etc/sudoers.d/zorin

RUN mkdir -p /home/zorin/.vnc && chown -R zorin:zorin /home/zorin/.vnc

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5901 6080

ENV VNC_RESOLUTION=1920x1080
ENV VNC_PASSWORD=zorin
ENV VNC_DEPTH=24

USER zorin
WORKDIR /home/zorin

ENTRYPOINT ["/entrypoint.sh"]
