#!/bin/bash

## Usage: bash gs_copy_bams.sh {LowPass/HighPass} {cancer}

inputDir="/home/yigewu2012/genomestrip/inputs/"
wgs_table="TCGA_WGS_gspath_WWL_Feb2018.txt"
wgs_table_cut=${inputDir}${wgs_table}"_cut"
bamDir="/home/yigewu2012/bams"
#bamDir="/mnt/disks/sdb/bams/"

## grep the bam paths as a batch according to cancer type and low/high pass
grep $1 ${inputDir}${wgs_table} | grep $2 | grep normal | sort -k2,2 -k10,10nr | awk 'NR == 1 {p=$2; next} p != $2 { print } {p=$2}' FS='\t' > ${wgs_table_cut}

## copy original bam and index in 7 batches, make sure about the size of bams fit the size of the disks(2000G)
copyed_lines=0
total_lines=$(wc ${wgs_table_cut} | awk -F ' ' '{print $1}')
for number in 1 2 3 4 5 6 7
do
mkdir -p ${bamDir}${number}
size_10=$(tail -n `expr ${total_lines} - ${copyed_lines}` ${wgs_table_cut} | head -n 10 | awk -F '\t' '{print $10}' | paste -sd+ - | bc)
size_9=$(tail -n `expr ${total_lines} - ${copyed_lines}` ${wgs_table_cut} | head -n 9 | awk -F '\t' '{print $10}' | paste -sd+ - | bc)
if [ "${size_10}" -lt 2147483648000 ]
then
	copyed_bam_num=10
elif [ "${size_9}" -lt  2147483648000 ]
then
	copyed_bam_num=9
fi
leftover_lines=`expr ${total_lines} - ${copyed_lines}`
if [ "${leftover_lines}" -lt "${copyed_bam_num}" ]
then
	copyed_bam_num=${leftover_lines}
fi
echo "bams"${number}
echo ${copyed_bam_num}
cd ${bamDir}${number}
ls *bam > bam_names
cm="cat ${wgs_table_cut} | tail -n ${leftover_lines} | head -n "${copyed_bam_num}" | grep -f ${bamDir}${number}/bam_names -v | awk -F '\t' '{print $""14}' | gsutil -m cp -c -L "${bamDir}${number}"/cp.log -I "${bamDir}${number}
echo ${cm}
cm="cat ${wgs_table_cut} | tail -n ${leftover_lines} | head -n "${copyed_bam_num}" | grep -f ${bamDir}${number}/bam_names -v | awk -F '\t' '{print $""15}' | gsutil -m cp -c -L "${bamDir}${number}"/cp.log -I "${bamDir}${number}
echo ${cm}
copyed_lines=`expr ${copyed_lines} + ${copyed_bam_num}`
echo ${copyed_lines}
done
