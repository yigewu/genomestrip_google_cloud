#!/bin/bash

## group names, t for tumor/normal, c for cancer type
d=$1

## master directory with inputs, outputs and codes
gsDir=$2

# input BAM
inputDir=${gsDir}"/inputs"
inputFile=${inputDir}"/bams.list"
inputType=bam

# input dependencies
export SV_DIR=/opt/svtoolkit
genderMap=${inputDir}"/gender_map"
## the dir name inside the input directory
refDir=Homo_sapiens_assembly19
refFile=${refDir}/Homo_sapiens_assembly19.fasta

# output
runDir=${gsDir}"/outputs/"${d}
mx="-Xmx6g"

# tempory dir
SV_TMPDIR=${runDir}/tmpdir

# These executables must be on your path.
which java > /dev/null || exit 1
which Rscript > /dev/null || exit 1
which samtools > /dev/null || exit 1

# For SVAltAlign, you must use the version of bwa compatible with Genome STRiP.
export PATH=${SV_DIR}/bwa:${PATH}
export LD_LIBRARY_PATH=${SV_DIR}/bwa:${LD_LIBRARY_PATH}

classpath="${SV_DIR}/lib/SVToolkit.jar:${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar:${SV_DIR}/lib/gatk/Queue.jar"

mkdir -p ${runDir} || exit 1
mkdir -p ${runDir}/logs || exit 1
mkdir -p ${runDir}/metadata || exit 1

cp $0 ${runDir}/


# Display version information.
java -cp ${classpath} ${mx} -jar ${SV_DIR}/lib/SVToolkit.jar

# Run preprocessing.
java -cp ${classpath} ${mx} \
	org.broadinstitute.gatk.queue.QCommandLine \
	-S ${SV_DIR}/qscript/SVPreprocess.q \
	-S ${SV_DIR}/qscript/SVQScript.q \
	-gatk ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
	--disableJobReport \
	-jobRunner ParallelShell \
	-cp ${classpath} \
	-configFile ${SV_DIR}/conf/genstrip_parameters.txt \
	-tempDir ${SV_TMPDIR} \
	-R ${inputDir}/${refFile} \
	-genderMapFile ${genderMap} \
	-runDirectory ${runDir} \
	-md ${runDir}/metadata \
	-jobLogDir ${runDir}/logs \
	-I ${inputFile} \
	-run \
	|| exit 1
