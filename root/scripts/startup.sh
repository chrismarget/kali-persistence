#!/bin/sh
/usr/bin/xrandr -s 1440x900
/usr/bin/passwd -l root
/usr/bin/systemctl start ssh
/usr/bin/gsettings set org.gnome.desktop.screensaver lock-enabled false
