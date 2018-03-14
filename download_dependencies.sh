#!/bin/bash

## pull the genomestrip docker image
docker pull skashin/genome-strip

# copy the table with address to WGS bams
gsutil cp gs://dinglab/yige/genomestrip/dependencies/TCGA_WGS_gspath_WWL_Feb2018.txt ../inputs/

# copy the clinical info for gender map provided to genomestrip
gsutil cp gs://dinglab/isb-cgc/tcga/germline/release1.0/exonOnly/combineClassified/PanCan_ClinicalData_V4_wAIM_filtered10389.txt ../inputs/

# download Reference Genome Metadata
wget -O ../inputs/Homo_sapiens_assembly19_12May2015.tar.gz ftp://ftp.broadinstitute.org/pub/svtoolkit/reference_metadata_bundles/Homo_sapiens_assembly19_12May2015.tar.gz
tar -xvzf ../inputs/Homo_sapiens_assembly19_12May2015.tar.gz 
mv Homo_sapiens_assembly19 ../inputs/
