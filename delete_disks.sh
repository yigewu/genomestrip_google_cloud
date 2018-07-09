#!/bin/bsh

## Usage: detach persistent disks for storing BAM files
bamDir=$1
logDir=$2
istName=$3
zone=$4

## get the list of device names of the disks storing BAM files
lsblk | grep ${bamDir} | awk '{print $1}' > ${logDir}"bam_device_names"
#while read device_name; do
#	gcloud compute instances detach-disk ${istName} --device-name=${device_name} --zone=${zone}
#done<${logDir}"bam_device_names"

## get the list of names for the persistent disks storing the BAM files of this instance
gcloud compute disks list --filter="users:("${istName}")" | grep bam | awk '{print $1}' > ${logDir}"bam_disk_names"
while read disk_name; do
	gcloud compute instances detach-disk ${istName} --device-name=${disk_name} --zone=${zone}
	gcloud compute disks delete ${disk_name} --zone=${zone}

	## in development
	read -r -p "Are you Sure? [Y/n] " input
	case $input in
		[yY][eE][sS]|[yY])
			echo "Yes"
			;;

		[nN][oO]|[nN])
			echo "No"
			;;

		*)
		echo "Invalid input..."
		;;
	esac
done<${logDir}"bam_disk_names"

## reference:
## https://cloud.google.com/sdk/gcloud/reference/compute/instances/detach-disk
## https://cloud.google.com/sdk/gcloud/reference/compute/disks/delete
