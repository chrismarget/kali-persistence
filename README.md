# kali-persistence
Data persistence and personalization of a Kali live image

I run a Kali live image in Virtualbox on my MacBook. It's specifically a live image, rather than an installed copy of of Kali for safety/repeatability reasons. This repo contains the little bits that get it booting directly into a mostly usable state.

## How to use it
(See the `Tips and Tricks` section for additional help.)

1) Create a disk image in virtualbox, attach it to the VM's SATA controller.
2) Partition the disk image within the VM.
3) Create a filesystem (I use ext4; don't use VFAT because of permissions/symlinks) on the partition, label the filesystem "persistence"
4) Copy the contents of this repo into the persistence filesystem.

## How to use it (copy paste edition)
```
name="kali-live-persistence"
iso=~"/iso/kali-linux-2020.3-live-amd64.iso"
vboxdir=~"/VirtualBox VMs"
disk="${vboxdir}/${name}/persistence.vdi"

vboxmanage createvm --name $name --ostype Linux_64 --register
vboxmanage createhd --filename $disk --size 5000
vboxmanage storagectl $name --name "SATA Controller" --add sata
vboxmanage storageattach $name --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium $iso
vboxmanage storageattach $name --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium $disk
vboxmanage modifyvm $name --boot1 dvd --boot2 none --boot3 none --boot4 none
vboxmanage modifyvm $name --memory 4096 --vram 128
vboxmanage modifyvm $name --cpus 2
vboxmanage startvm $name
cat setup_partition.sh | nc -l 5000
```


## How it works
On bootup, select "Live USB Persistence" from the Kali boot menu. Note that USB doesn't need to be involved, that's just how the Kali folks imagined you'd be using it.

With the option selected, the OS looks for filesystems labled "persistence", mounts them at `/usr/lib/live/mount/persistence/<partition>`. The OS then examines the `persistence.conf` file on the partition and creates bind mounds and symlinks between the live image filesystem and the partition. In this case, the persistence.conf says:
```
/etc/ssh
/root/.ssh
/root/scripts
/root/.config/autostart
```
It causes the contents of those 4 directories from the persistence partition to be overlaid onto the live image filesystem.

The two ssh directories are where keys live. They keys are excluded from the git repo. sshd keys will be created here automatically. Copy your public key into `/root/.ssh/authorized_keys` for access to the VM.

The `/root/.config/autostart` directory contains a file that specifies a script run by Gnome when the Kali desktop starts. The script is at `/root/scripts/startup.sh`. It does 3 things:
1) resizes the desktop to fit my MacBook screen.
2) locks the well-known Kali root password.
3) starts sshd.

Additional directores can be added to `persistence.conf` for keeping track of project-related data.

## Tips and tricks
If you are interested, here are some additional tips and tricks you can use when
working with a persistent virtual volume.

#### Setting up the persistent volume in Kali
The following steps can be used to partition and format the persistent volume in
Kali. These steps assume you have already created and attached the virtual
volume to the VM using VirtualBox (or another tool).

1) Once logged in as `root` in Kali, open a terminal
2) Create a new partition (assuming `/dev/sda` is the block device):
```
parted /dev/sda mklabel gpt
parted -a opt /dev/sda mkpart primary ext4 0% 100%
```
3) Format the newly created partition (again, assuming `/dev/sda`):
```
mkfs.ext4 -L persistence /dev/sda1
# Note: The label can be changed if needed with 'e2label'.
```
4) Lastly, you can mount the filesystem to `/mnt/persistence` like so:
```
mkdir -p /mnt/persistence
mount -o defaults /dev/sda1 /mnt/persistence
```

#### Transfering this repo to the persistence volume
After creating and mounting the persistence volume, you will need to copy this
repository to it (see notes from the earlier section of this README). There are
many ways to accomplish this.

###### Using nc and encrypting payload with openssl
If you want a "little more" security when transfering the repo to the Kali VM,
you can use nc and openssl. The included `servethis.sh` does the first few steps
for you if you are feeling lazy.

1) Set a password:
```
read KP_PASS
# Type a password and hit the Enter key.
export KP_PASS
```
2) Compress, encrypt, and serve the repository via TCP:
```
# Note 1: The '-md sha256' argument is very important for compatibility between
# different versions and variants of openssl (e.g., libressl and openssl).
#
# Note 2: This assumes the "server" is also the VirtualBox host. If not,
# remove '127.0.0.1'.
(cd ~/Development/kali-persistence/; tar czf - .) | openssl enc -aes-256-cbc -pass env:KP_PASS -base64 -md sha256 | nc -l 127.0.0.1 8080
```
3) In the Kali VM, retrieve and write the repository to `/mnt/persistence`
like so:
```
# Note 1: This assumes the "server" is the VirtualVM host. You should replace
# the IP address below if you are not using VirtualBox - this is the default
# address used by the VirtualBox host.
#
# Note 2: This also assumes you want the repository files to be owned by 'root'.
nc 10.0.2.2 8080 | openssl enc -aes-256-cbc -d -base64 | (cd /mnt/persistence/ && tar -xzf - && chown -R root:root ./)
```

## References
- "How To Partition and Format Storage Devices in Linux" - Justin Ellingwood
    - https://www.digitalocean.com/community/tutorials/how-to-partition-and-format-storage-devices-in-linux
- "Encrypt & Decrypt Files With Password Using OpenSSL" - ShellHacks
    - https://www.shellhacks.com/encrypt-decrypt-file-password-openssl/
- "bash-cli-openssl-stdin-encryption" - robert2d
    - https://gist.github.com/robert2d/e31846fc9a954aa2609d
- "How to resolve the “EVP_DecryptFInal_ex: bad decrypt” (...)" - Sean Dawson,
  katspaugh, and Andrew Savinykh
    - https://stackoverflow.com/a/43847627
