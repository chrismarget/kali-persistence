# kali-persistence
Data persistence and personalization of a Kali live image

I run a Kali live image in Virtualbox on my MacBook. It's specifically a live image, rather than an installed copy of of Kali for safety/repeatability reasons. This repo contains the little bits that get it booting directly into a mostly usable state.

## How to use it
1) Create a disk image in virtualbox, attach it to the VM's SATA controller.
2) Partition the disk image within the VM.
3) Create a filesystem (I use ext4; don't use VFAT because of permissions/symlinks) on the partition, label the filesystem "persistence"
4) Copy the contents of this repo into the persistence filesystem.

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
