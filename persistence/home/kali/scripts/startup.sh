#!/bin/sh
#/usr/bin/xrandr -s 1440x900
/usr/bin/xrandr -s 1680x1050
/usr/bin/xrandr --dpi 96
sudo /usr/bin/passwd -l kali
sudo /usr/bin/systemctl start ssh
/usr/bin/gsettings set org.gnome.desktop.screensaver lock-enabled false
