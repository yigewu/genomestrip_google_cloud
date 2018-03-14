#!/bin/bash

## Usage: bash gs_create_bam_path.sh {LowPass/HighPass} {cancer}

inputDir="../inputs/"
wgs_table="TCGA_WGS_gspath_WWL_Jan2018.txt"
wgs_table_cut=${inputDir}${wgs_table}"_cut"
bamDir="/home/yigewu2012/genomestrip/bams/"

ls ${bamDir}*.bam > ${inputDir}"bams.list"
