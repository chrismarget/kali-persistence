#!/bin/sh

parted /dev/sda mklabel gpt
parted -a opt /dev/sda mkpart primary ext4 0% 100%
mkfs.ext4 -L persistence /dev/sda1
mkdir -p /mnt/persistence
mount -o defaults /dev/sda1 /mnt/persistence
cd 
