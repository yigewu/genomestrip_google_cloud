#!/bin/bash

## Usage: bash gs_copy_bams.sh {LowPass/HighPass} {cancer}

inputDir="../inputs/"
wgs_table="TCGA_WGS_gspath_WWL_Jan2018.txt"
wgs_table_cut=${inputDir}${wgs_table}"_cut"
bamDir="/home/yigewu2012/bams/"

## grep the bam paths as a batch according to cancer type and low/high pass
grep $1 ${inputDir}${wgs_table} | grep $2 | grep normal > ${wgs_table_cut}

## copy original bam and index
mkdir ${bamDir}
awk '{print $15}' ${wgs_table_cut} | gsutil -m cp -I ${bamDir} 
awk '{print $14}' ${wgs_table_cut} | gsutil -m cp -I ${bamDir} 
