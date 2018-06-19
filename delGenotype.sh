#!/bin/bash

## SVDiscovery targeting deletion spanning 100 bp - 1M bp

## Genome interval to process for SV discovery
chr=$7

## identifier
d=$1

## the name of the file containing the bam paths
bamList=$3

## the path to master directory containing genomestrip scripts, input dependencies and output directories
mainRunDir=$2

## the name of the file containing the gender map
genderFile=$4

# input BAM
inputDir=${mainRunDir}"inputs"
inputFile=${inputDir}"/"${bamList}
inputType=bam

# input dependencies
export SV_DIR=/opt/svtoolkit
genderMap=${inputDir}"/"${genderFile}
## the dir name inside the input directory
refDir=Homo_sapiens_assembly19
refFile=${refDir}/Homo_sapiens_assembly19.fasta

# output
runDir=${mainRunDir}"outputs/"${d}"/"
outDir=${runDir}"delGenotype/"
sites=${runDir}"svDiscovery/discovery_"${d}"_chr"${chr}".vcf"
suboutDir=${outDir}${chr}"/"
mainjobLogDir=${runDir}"logs/"
subjobLogDir=${mainjobLogDir}${chr}"/"
vcfFile=${outDir}"delGenotype_"${d}"_chr"${chr}".vcf"
mx="-Xmx6g"

# tempory dir
SV_TMPDIR=${runDir}/tmpdir

# For SVAltAlign, you must use the version of bwa compatible with Genome STRiP.
export PATH=${SV_DIR}/bwa:${PATH}
export LD_LIBRARY_PATH=${SV_DIR}/bwa:${LD_LIBRARY_PATH}

classpath="${SV_DIR}/lib/SVToolkit.jar:${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar:${SV_DIR}/lib/gatk/Queue.jar"

mkdir -p ${outDir} || exit 1
mkdir -p ${suboutDir}
mkdir -p ${mainjobLogDir}
mkdir -p ${subjobLogDir}

cp $0 ${suboutDir}/


# Run genotyping on the discovered sites.
java -cp ${classpath} ${mx} \
	org.broadinstitute.gatk.queue.QCommandLine \
	-S ${SV_DIR}/qscript/SVGenotyper.q \
	-S ${SV_DIR}/qscript/SVQScript.q \
	-gatk ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
	--disableJobReport \
	-jobRunner ParallelShell \
	-cp ${classpath} \
	-configFile ${SV_DIR}/conf/genstrip_parameters.txt \
	-tempDir ${SV_TMPDIR} \
	-R ${inputDir}/${refFile} \
	-genderMapFile ${genderMap} \
	-runDirectory ${suboutDir} \
	-md ${runDir}/metadata \
	-jobLogDir ${subjobLogDir} \
	-I ${inputFile} \
	-vcf ${sites} \
	-O ${vcfFile} \
	-P select.validateReadPairs:false \
	--maximumNumberOfJobsToRunConcurrently 1 \
	-resMemLimit 6 \
	-run \
	|| exit 1
