#!/bin/bash

## Usage: attach additional disks to the VMs and mount
bamDir="/home/yigewu2012/bams/"

### add additional disks

### format the disks
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdc
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdd
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sde
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdf
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdg
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdh
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdi

### Use the mount tool to mount the disk to the instance with the discard option enabled:
sudo mkdir -p ${bamDir}
sudo mount -o discard,defaults /dev/sdb ${bamDir}
sudo mount -o discard,defaults /dev/sdc ${bamDir}
sudo mount -o discard,defaults /dev/sdd ${bamDir}
sudo mount -o discard,defaults /dev/sde ${bamDir}
sudo mount -o discard,defaults /dev/sdf ${bamDir}
sudo mount -o discard,defaults /dev/sdg ${bamDir}
sudo mount -o discard,defaults /dev/sdh ${bamDir}

### change permission of directory the disks are mounted on
sudo chmod 777 ${bamDir}

## add the persistent disk to the /etc/fstab file so that the device automatically mounts again when the instance restarts.

### Create a backup of your current /etc/fstab file
sudo cp /etc/fstab /etc/fstab.backup

### Use the blkid command to find the UUID for the persistent disk. The system generates this UUID when you format the disk. Use UUIDs to mount persistent disks because UUIDs do not change when you move disks between systems.
echo UUID=`sudo blkid -s UUID -o value /dev/sdb` ${bamDir} ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
echo UUID=`sudo blkid -s UUID -o value /dev/sdc` ${bamDir} ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
echo UUID=`sudo blkid -s UUID -o value /dev/sdd` ${bamDir} ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
echo UUID=`sudo blkid -s UUID -o value /dev/sde` ${bamDir} ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
echo UUID=`sudo blkid -s UUID -o value /dev/sdf` ${bamDir} ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
echo UUID=`sudo blkid -s UUID -o value /dev/sdg` ${bamDir} ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
echo UUID=`sudo blkid -s UUID -o value /dev/sdh` ${bamDir} ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
