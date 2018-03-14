#!/bin/bash

group1="LowPass"
group2="BRCA"

# ~1 hr
cm="yes | bash prep_vm.sh"
echo $cm
cm="yes | bash download_dependencies.sh" 
echo $cm

## copy BAMS to this VM
## 1 hr
cm="yes | bash copy_bams.sh "${group1}" "${group2}
echo $cm

## re-process the header of the BAMs
## 3 hrs
cm="bash docker_run_by_script.sh "${group1}" "${group2}" reheader_bam_platform.sh"
echo $cm

## create the file containing the path to the new BAMs
cm="yes | bash create_bam_paths.sh"
echo $cm

## create the gender info file for all the BAMs
## ?
cm="bash docker_run_by_script.sh "${group1}" "${group2}" gs_create_gender_map.sh"
echo $cm

## preprocess the BAMS
## 10 hrs
cm="bash docker_run_by_script.sh "${group1}" "${group2}" svPreprocess.sh"
echo $cm

## discover deletions
## 1 hr
cm="bash docker_run_by_script.sh "${group1}" "${group2}" svDiscovery.sh"
echo $cm

## genotype deletions
## 3.5 hrs, CPU: 12-25%
cm="bash docker_run_by_script.sh "${group1}" "${group2}" delGenotype.sh"
echo $cm

## discover CNVs (deletions and amplifciations) 
## 10 hrs
cm="bash docker_run_by_script.sh "${group1}" "${group2}" cnvDiscovery.sh" 
echo $cm

## genotype CNVs
## 10 mins, CPU: 25%
cm="bash docker_run_by_script.sh "${group1}" "${group2}" cnvGenotype.sh"
echo $cm

## copy outputs to buckets
