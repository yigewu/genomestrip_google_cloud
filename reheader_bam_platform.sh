#!/bin/bash


## identifier
d=$1

## the name of the file containing the bam paths
bamList=$2

## the path to master directory containing genomestrip scripts, input dependencies and output directories
gsDir=$3

## the name of the file containing the gender map
genderFile=$4

## the path to the folder holding the original bam files
bamDir=$5

## the path to the directory containing the reheadered BAM files (because Genome STRiP doesn't recognized Illumina_HiSeq2000)
rhbamDir=$6

cd ${bamDir}
ls *bam > bam_names

# input BAM
inputDir=${gsDir}"/inputs"
inputFile=${inputDir}"/"${bamList}

while read p; do
	samtools view -H ${p} > $p"-header.sam"
	echo ${p}" header extracted!"
	sed "s/Illumina_HiSeq2000/ILLUMINA/" ${p}"-header.sam" > ${p}"-header_corrected.sam"
	echo ${p}" header corrected!"
	samtools reheader ${p}"-header_corrected.sam" ${p} > ${rhbamDir}"/"${p}
	echo ${p}" reheadered and moved!"
	samtools index -b ${rhbamDir}"/"${p} ${rhbamDir}"/"$p".bai"
	echo "reheadered "${p}" indexed!"
done<bam_names
