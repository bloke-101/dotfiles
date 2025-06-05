#!/usr/bin/bash

set -euxo pipefail

function install_onlyoffice_desktop() {
    local url=https://github.com/ONLYOFFICE/DesktopEditors/releases/latest
    local command=download
    local package_name=onlyoffice-desktopeditors_amd64.deb
    wget $url/$command/$package_name
    
    sudo apt install -y ./$package_name
    rm ./$package_name
    
    return
}

function install_terminal_emulator() {
    local pkgs=(pkg-config libfontconfig1-dev libxcb-xfixes0-dev
        libxkbcommon-dev
    )
    sudo apt install -y "${pkgs[@]}"
    
    cargo install alacritty
    
    return
}

function install_rust_toolchain() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    . $HOME/.cargo/env
    return
}

function add_repository() {
    local arch=$(dpkg --print-architecture)
    local key_path=$1
    local link=$2
    local codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    local category=$3

    local repo_desc="deb [arch=$arch signed-by=$key_path]"
    repo_desc+=" $link"
    repo_desc+=" $codename"
    repo_desc+=" $category"

    local file_name=$4
    local apt_sources=/etc/apt/sources.list.d

    echo $repo_desc | sudo tee $apt_sources/$file_name > /dev/null
    sudo apt update
    
    return
}

function install_docker() {
    sudo apt update
    sudo apt install -y ca-certificates
    
    sudo install -m 0755 -d /etc/apt/keyrings

    local key_link=https://download.docker.com/linux/ubuntu/gpg
    local key_path=/usr/share/keyrings/docker.asc
    sudo curl -fsSL $key_link -o $key_path
    sudo chmod a+r $key_path

    local repo_link=https://download.docker.com/linux/ubuntu
    local repo_category=stable
    local repo_file_name=docker.list
    add_repository $key_path $repo_link $repo_category $repo_file_name
    sudo apt update
    
    local pkgs=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin
        docker-compose-plugin
    )
    sudo apt install -y "${pkgs[@]}"
    
    sudo usermod -aG docker $USER
    newgrp docker

    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    
    return
}

function add_i3_repository() {
    local pck_name=sur5r-keyring_2025.03.09_all.deb
    local link=https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring
    local hash=SHA256:2c2601e6053d5c68c2c60bcd088fa9797acec5f285151d46de9c830aaba6173c

    /usr/lib/apt/apt-helper download-file $link/$pck_name $pck_name $hash
    
    sudo apt install -y ./$pck_name
    rm ./$pck_name
    
    local key_path=/usr/share/keyrings/sur5r-keyring.gpg
    local repo_link=http://debian.sur5r.net/i3/
    local repo_category=universe
    local repo_file_name=sur5r-i3.list
    add_repository $key_path $repo_link $repo_category $repo_file_name
    
    return
}

function install_i3lock_color() {
    local pkgs=(autoconf gcc make pkg-config libpam0g-dev libcairo2-dev
        libfontconfig1-dev libxcb-composite0-dev libev-dev
        libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev
        libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev
        libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev
        libjpeg-dev libgif-dev libtool xutils-dev
    )
    sudo apt install -y "${pkgs[@]}"
    
    PROJECT_DIR=$HOME/Projects/i3lock-color
    mkdir -p $PROJECT_DIR
    cd $PROJECT_DIR
    git clone https://github.com/Raymo111/i3lock-color.git .
    chmod +x install-i3lock-color.sh && ./install-i3lock-color.sh
    
    return
}

function install_i3() {
    add_i3_repository

    local pkgs=(xorg i3-wm i3status i3blocks dmenu dbus-x11 feh)
    sudo apt install -y "${pkgs[@]}"
    
    install_i3lock_color

    i3-config-wizard
    
    return
}

function install_all_packages() {
    sudo apt update && sudo apt upgrade -y

    local pkgs=(cargo firefox git openssh-client openssh-server
        qbittorrent telegram-desktop vim unrar unzip vlc
        adb build-essential cmake wireshark atril wget
        curl network-manager-openconnect-gnome maim xclip
    )
    sudo apt install -y "${pkgs[@]}"
    
    install_onlyoffice_desktop
    install_rust_toolchain
    install_terminal_emulator
    install_docker
    install_i3

    return
}

install_all_packages

