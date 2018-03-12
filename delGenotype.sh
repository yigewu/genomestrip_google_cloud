#!/bin/bash

## SVDiscovery targeting deletion spanning 100 bp - 1M bp

## identifier
d=$1

## the name of the file containing the bam paths
bamList=$2

## the path to master directory containing genomestrip scripts, input dependencies and output directories
gsDir=$3

## the name of the file containing the gender map
genderFile=$4

# input BAM
inputDir=${gsDir}"/inputs"
inputFile=${inputDir}"/"${bamList}
inputType=bam

# input dependencies
export SV_DIR=/opt/svtoolkit
genderMap=${inputDir}"/"${genderFile}
## the dir name inside the input directory
refDir=Homo_sapiens_assembly19
refFile=${refDir}/Homo_sapiens_assembly19.fasta

# output
runDir=${gsDir}"/outputs/"${d}
outDir=${runDir}"/delGenotype"
sites=${runDir}"/svDiscovery/discovery_"${d}".vcf"
vcfFile=${outDir}"/del_genotype_"${d}".vcf"
mx="-Xmx6g"

# tempory dir
SV_TMPDIR=${runDir}/tmpdir

# For SVAltAlign, you must use the version of bwa compatible with Genome STRiP.
export PATH=${SV_DIR}/bwa:${PATH}
export LD_LIBRARY_PATH=${SV_DIR}/bwa:${LD_LIBRARY_PATH}

classpath="${SV_DIR}/lib/SVToolkit.jar:${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar:${SV_DIR}/lib/gatk/Queue.jar"

mkdir -p ${outDir} || exit 1

cp $0 ${outDir}/


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
	-runDirectory ${outDir} \
	-md ${runDir}/metadata \
	-jobLogDir ${runDir}/logs \
	-I ${inputFile} \
	-vcf ${sites} \
	-O ${vcfFile} \
	-P select.validateReadPairs:false \
	-run \
	|| exit 1
