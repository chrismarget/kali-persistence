#!/bin/sh

setup_disk() {
  sudo parted $1 mklabel gpt
  sudo parted -a opt $1 mkpart primary ext4 0% 100%
  sudo mkfs.ext4 -L persistence ${1}1
}

mount_disk() {
  sudo mount -o defaults $1 $2
  sudo chown kali $2
}

remaining_to_file() {
  cat > $1
}

extract() {
  base64 --decode $1 | tar -C $2 -zxf -
}


setup_disk /dev/sda

mntpnt=$(mktemp -d)
mount_disk /dev/sda1 $mntpnt

tmp=$(mktemp)
echo temp data is $tmp

remaining_to_file $tmp && extract $tmp $mntpnt && sudo chattr +i $mntpnt/etc/ssh/sshd_config && sudo reboot
