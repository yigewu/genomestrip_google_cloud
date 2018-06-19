#!/bin/bash


## identifier
d=$1

## the path to master directory containing genomestrip scripts, input dependencies and output directories
mainRunDir=$2

# input BAM
inputDir=${mainRunDir}"inputs"
inputFile=${inputDir}"/bams.list"
bamDir="/home/yigewu2012/bams"

## the name of directory containing step-wise scripts
githubDir=$6

## get the list of bams that need to be reheadered
#for number in 1 2 3 4 5 6 7
for number in 3 4 5 6 7
do
	cd ${bamDir}${number}
	ls *bam > bams.list
	touch bam_names2reheader > bam_names2reheader
	#awk -F '/' '{print $5}' bams.list > bam_names2reheader
	while read p; do
		samtools view -H ${p} | grep PL: | awk -F 'PL:' '{print $2}' | awk -F '\t' '{print $1}' | sort | uniq > PL.tmp
		PL=$(cat PL.tmp)
		if [ "${PL}" != "ILLUMINA" ] & [ "${PL}" != "LS454" ] & [ "${PL}" != "SOLID" ]
		then
			echo $PL
			echo ${p} >> bam_names2reheader
		fi
	done<bams.list
	## process one BAM at each input BAM directory each time
	cat bam_names2reheader | parallel -j10  -k bash ${mainRunDir}${githubDir}"/replaceBAMheader.sh" {}
done
