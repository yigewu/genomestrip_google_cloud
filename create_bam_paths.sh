#!/bin/bash

## Usage: bash gs_create_bam_path.sh {LowPass/HighPass} {cancer}

inputDir="/home/yigewu2012/genomestrip/inputs/"
wgs_table="TCGA_WGS_gspath_WWL_Mar2018.txt"
wgs_table_cut=${inputDir}${wgs_table}"_cut"
bamDir="/home/yigewu2012/"

touch ${inputDir}"bams.list" > ${inputDir}"bams.list"
touch ${wgs_table_cut} > ${wgs_table_cut}
for number in 1 2 3 4 5 6 7
do
	cd ${bamDir}"bams"${number}
	ls *bam > tmp
	while read b; do
		analyte_type=$(grep ${b} ${inputDir}${wgs_table} | awk '{print $5}')
		sample_type=$(grep ${b} ${inputDir}${wgs_table} | awk '{print $4}')
		if [ "${analyte_type}" == "DNA" ] && [ "${sample_type}" == "10.0" ]; then
			echo ${bamDir}"bams"${number}"/"${b} >> ${inputDir}"bams.list"
			grep ${b} ${inputDir}${wgs_table} >> ${wgs_table_cut}
		fi
	done<tmp
	#ls ${bamDir}"bams"${number}/*.bam >> ${inputDir}"bams.list"
done

#for number in 8
#do
#	ls ${bamDir}"bams"${number}/*.reheadered >> ${inputDir}"bams.list"
#done
