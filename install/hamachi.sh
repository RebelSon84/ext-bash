#!/bin/bash
domain="vpn.net"
page="$domain/linux"
RELEASE=$(. "/etc/os-release"; echo "$ID")
if [ $RELEASE == "arch" ]; then echo "Enter your non root user login" && read user;fi

installGit() {
pacman -S git --noconfirm
}

installYay() {
        if [[ ! -e /usr/bin/git ]]; then installGit;fi
        pacman -Sy base-devel git --noconfirm
        sudo -u $user git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        sudo -u $user makepkg -si --noconfirm
        rm -rf /tmp/yay
}

installHamachiDebian() {
        if [[ ! -e /usr/bin/curl ]]; then apt update && apt install curl;fi
        string=$(curl https://$page | grep "amd64.deb")
        extracted=$(echo "$string" | grep -oE 'href="([^"]+)"' | sed -E 's/^href="(.+)">.+$/\1/')
        cleaned=$(echo "$extracted" | sed 's/href="//;s/"$//')
        echo "$domain""$cleaned"
        wget https://"$domain""$cleaned" -O /tmp/hamachi.deb
        apt update
        apt install /tmp/hamachi.deb -y
        rm /tmp/hamachi.deb
}

installHamachiArch() {
        sudo -u $user yay -S logmein-hamachi --noconfirm
}

if [ $RELEASE == "debian" ]; then installHamachiDebian;fi
if [[ $RELEASE == "arch" && -e /usr/bin/yay ]]; then installHamachiArch;fi
if [[ $RELEASE == "arch" && ! -e /usr/bin/yay ]]; then installYay && installHamachiArch;fi
