#!/bin/bash

inputDir="../inputs/"
refFasta="GRCh37-lite_WUGSC_variant_4.fa"


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

## download picard jar file
wget -O ${inputDir}"picard.jar" https://github.com/broadinstitute/picard/releases/download/2.18.7/picard.jar

gsutil cp gs://melt_data/reference/GRCh37-lite_WUGSC_variant_4.fa ../inputs/
gsutil cp gs://melt_data/reference/GRCh37-lite_WUGSC_variant_4.fa.fai ../inputs/
gsutil cp gs://dinglab/yige/genomestrip/dependencies/GRCh37-lite_WUGSC_variant_4.fa.gz .
gsutil cp gs://dinglab/yige/genomestrip/dependencies/GRCh37-lite_WUGSC_variant_4.fa.fai .

if [ -d ${inputDir}${refFasta} ]
then
	echo "reference fasta file already unzipped!"
else
	echo "reference fasta file is being unzipped!"
	cd ${inputDir}
	gunzip -k ${refFasta}".gz"
fi

## create fasta dict file
java -jar /home/yigewu2012/genomestrip/inputs/picard.jar CreateSequenceDictionary R=/home/yigewu2012/genomestrip/inputs/GRCh37-lite_WUGSC_variant_4.fa O=/home/yigewu2012/genomestrip/inputs/GRCh37-lite_WUGSC_variant_4.dict
