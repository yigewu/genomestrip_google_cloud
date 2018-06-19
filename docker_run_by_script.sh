#!/bin/bash

## Usage: bash gs_localrunbystep.sh {LowPass/HighPass} {cancer} script_to_run

## identifiers
t=$1
c=$2

## combined identifier
d=$t"_"$c

## script name to run
scriptName=$3
stepName=$(echo ${scriptName} | awk -F '\\.' '{print $1}')

## chromosome to prcess
chr=$4

## user ID with permission to the input files
uid=$(id -u)

## the path to master directory containing genomestrip scripts, input dependencies and output directories
#mainRunDir="/diskmnt/Projects/cptac/genomestrip"
mainRunDir="/home/yigewu2012/genomestrip/"

## the name of directory containing step-wise scripts
githubDir="genomestrip_google_cloud"

## the path to master directory containing input BAM files
bamDir="/home/yigewu2012/"

## the path to the directory containing the reheadered BAM files (because Genome STRiP doesn't recognized Illumina_HiSeq2000)
rhbamDir="/home/yigewu2012/genomestrip/bams"

## the file name containing the bam paths
batchbamMapFile="bams.list"

## the name of the file containing the gender map
genderFile="gender_map"

## the name of the docker image
imageName="skashin/genome-strip"

## the name of the tag for the docker image
tagName="latest"

#mkdir ${mainRunDir}"logs"

#bashCMD="docker run --user "${uid}" -v "${mainRunDir}":"${mainRunDir}" -v "${bamDir}":"${bamDir}" -v "${rhbamDir}":"${rhbamDir}" -w "${mainRunDir}"logs skashin/genome-strip /bin/bash "${mainRunDir}${githubDir}"/"${scriptName}" "${d}" "${mainRunDir}" "${batchbamMapFile}" "${genderFile}" "${bamDir}" "${rhbamDir}" |& tee "${scriptName}"_"${d}".log" 
bashCMD="docker run --name "${stepName}"CHR"${chr}"D"$(date +%Y%m%d%H%M%S)" --user "${uid}" -v "${mainRunDir}":"${mainRunDir}" -v "${bamDir}":"${bamDir}" -v "${rhbamDir}":"${rhbamDir}" -w "${mainRunDir}"logs ${imageName}:${tagName} /bin/bash "${mainRunDir}${githubDir}"/"${scriptName}" "${d}" "${mainRunDir}" "${batchbamMapFile}" "${genderFile}" "${bamDir}" "${githubDir}" "${chr} 
echo $bashCMD" >& "${mainRunDir}"logs/"${stepName}"CHR"${chr}"_"${d}"_"$(date +%Y%m%d%H%M%S)".log &"
echo "disown"
