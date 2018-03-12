#!/bin/bash


## identifier
d=$1

## the name of the file containing the bam paths
bamList=$2

## the path to master directory containing genomestrip scripts, input dependencies and output directories
gsDir=$3

## the name of the file containing the gender map
genderFile=$4

## the path to the folder holding the bam files
bamDir=$5

# input BAM
inputDir=${gsDir}"/inputs"
inputFile=${inputDir}"/"${bamList}

wgs_table="TCGA_WGS_gspath_WWL_Jan2018.txt"
wgs_table_cut=${inputDir}"/"${wgs_table}"_cut"

gender_table=${inputDir}"/PanCan_ClinicalData_V4_wAIM_filtered10389.txt"

touch ${inputDir}"/"${genderFile} > ${inputDir}"/"${genderFile}

while read p; do
	case_barcode=$(echo $p | awk -F ' ' '{print $1}')
	gender=$(fgrep "$case_barcode" "${gender_table}" | cut -f 4)
	if [ "$gender" = "FEMALE" ]; then
		genderNum="F"
	else
		genderNum="M"
	fi
	bamName=$(echo $p | awk -F ' ' '{print $9}')
	samtools view -H ${bamDir}"/"${bamName} | grep SM | sed 's/.*SM:\(.*\)/\1/'| awk -F '\t' '{print $1}' | uniq | awk -v gender="${genderNum}" '{printf $1" "gender"\n"}' >> ${inputDir}"/"${genderFile}
done < ${wgs_table_cut}
