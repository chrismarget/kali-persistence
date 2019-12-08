#!/bin/sh
xrandr -s 1440x900
/usr/bin/passwd -l root
systemctl start ssh
