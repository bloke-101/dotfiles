#!/usr/bin/bash

set -euxo pipefail

CONFIG_DIR=$HOME/.config

cp -r alacritty $CONFIG_DIR

mkdir -p $CONFIG_DIR/i3 && cp i3/config $CONFIG_DIR/i3
cp -r i3status i3lock $CONFIG_DIR

cp i3/.Xresources $HOME

mkdir -p $HOME/.local/share/backgrounds
cp i3/wallpaper.png $HOME/.local/share/backgrounds

cp vim/.vimrc $HOME

cp bash/.bashrc $HOME

sudo cp fonts/* /usr/share/fonts/truetype

