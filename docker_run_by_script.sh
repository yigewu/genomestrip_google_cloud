#!/bin/bash

## Usage: bash gs_localrunbystep.sh {LowPass/HighPass} {cancer} script_to_run

## identifiers
t=$1
c=$2

## combined identifier
d=$t"_"$c

## script name to run
s=$3

## user ID with permission to the input files
uid=$(id -u)

## the path to master directory containing genomestrip scripts, input dependencies and output directories
#mainRunDir="/diskmnt/Projects/cptac/genomestrip"
mainRunDir="/home/yigewu2012/genomestrip/"

## the path to master directory containing input BAM files
bamDir="/home/yigewu2012/bams"

## the path to the directory containing the reheadered BAM files (because Genome STRiP doesn't recognized Illumina_HiSeq2000)
rhbamDir="/home/yigewu2012/genomestrip/bams"

## the file name containing the bam paths
batchbamMapFile="bams.list"

## the name of the file containing the gender map
genderFile="gender_map"

#mkdir ${mainRunDir}"logs"

bashCMD="docker run --user "${uid}" -v "${mainRunDir}":"${mainRunDir}" -v "${rhbamDir}":"${rhbamDir}" -w "${mainRunDir}"logs skashin/genome-strip /bin/bash "${mainRunDir}"/genomestrip/"${s}" "${t}" "${c}" "${mainRunDir}" "${batchbamMapFile}" "${genderFile}" "${bamDir}" "${rhbamDir}" |& tee "${s}"_"${d}".log" 
echo $bashCMD
${bashCMD}
