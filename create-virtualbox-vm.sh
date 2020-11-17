#!/bin/bash

set -ex

name="kali-live-persistence"
iso="${HOME}/iso/kali-linux-2020.3-live-amd64.iso"
vboxdir="${HOME}/VirtualBox VMs"
disk="${vboxdir}/${name}/persistence.vdi"
sshPersistDir="persistence/home/kali/.ssh"

if [ ! -f "${iso}" ]
then
    echo "iso file does not exist at '${iso}'"
    exit 1
fi

mkdir -p "${sshPersistDir}"
cp "${HOME}/.ssh/id_rsa.pub" "${sshPersistDir}/authorized_keys"
vboxmanage createvm --name $name --ostype Linux_64 --register
vboxmanage createhd --filename "$disk" --size 5000
vboxmanage storagectl $name --name "SATA Controller" --add sata
vboxmanage storageattach $name --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium $iso
vboxmanage storageattach $name --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$disk"
vboxmanage modifyvm $name --boot1 dvd --boot2 none --boot3 none --boot4 none
vboxmanage modifyvm $name --memory 4096 --vram 128
vboxmanage modifyvm $name --cpus 2
vboxmanage modifyvm $name --graphicscontroller vmsvga
vboxmanage modifyvm $name --natpf1 "guestssh,tcp,,2222,,22"
vboxmanage startvm $name
(cat setup-persistence.sh; tar czf - -C persistence . | base64 -b 80) | nc -l 5000
