#!/bin/bash

# ~1 hr
yes | bash gs_prepvm.sh
yes | bash gs_genomestrip_dependencies.sh

## 1 hr
yes | bash gs_copy_bams.sh LowPass BRCA

## 3 hrs
bash gs_localrunbystep.sh LowPass BRCA gs_reheader_platform.sh
yes | bash gs_create_bam_paths.sh
## ?
bash gs_localrunbystep.sh LowPass BRCA gs_create_gender_map.sh
## 10 hrs
bash gs_localrunbystep.sh LowPass BRCA svPreprocess.sh
## 1 hr
bash gs_localrunbystep.sh LowPass BRCA svDiscovery.sh
## 3.5 hrs, CPU: 12-25%
bash gs_localrunbystep.sh LowPass BRCA delGenotype.sh 

## 10 hrs
bash gs_localrunbystep.sh LowPass BRCA cnvDiscovery.sh 

## 10 mins, CPU: 25%
bash gs_localrunbystep.sh LowPass BRCA cnvGenotype.sh
