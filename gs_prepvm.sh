#!/bin/bash

#sudo apt-get update
#sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
#sudo apt-key fingerprint 0EBFCD88
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install docker-ce
sudo usermod -a -G docker ${USER}
exit