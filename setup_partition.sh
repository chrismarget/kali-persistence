#!/bin/sh

setup_disk() {
  sudo parted $1 mklabel gpt
  sudo parted -a opt $1 mkpart primary ext4 0% 100%
  sudo mkfs.ext4 -L persistence ${1}1
}

mount_disk() {
  mkdir -p /tmp/persistence
  sudo mount -o defaults $1 /tmp/persistence
  sudo chown kali /tmp/persistence
}

remaining_to_file() {
  cat > $1
}

extract() {
  base64 --decode $1 | tar -C /tmp/persistence -zxf -
}


setup_disk /dev/sda
mount_disk /dev/sda1

remaining_to_file $tmp && extract $tmp && sudo chattr +i /tmp/persistence/etc/ssh/sshd_config && sudo reboot
