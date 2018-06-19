#!/bin/bash

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install docker-ce
sudo usermod -a -G docker ${USER}

## configure git
git config --global user.email yigewu@wustl.edu
git config --global user.name yigewu

## add additional disks
## format the disks
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
wait
sudo mount -o discard,defaults /dev/sdb /
wait
## mount disks on the VMs
## grant write access to the device for all users
sudo chmod a+w /

exit
