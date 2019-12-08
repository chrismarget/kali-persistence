#!/bin/sh
/usr/bin/xrandr -s 1440x900
/usr/bin/passwd -l root
/usr/bin/systemctl start ssh
