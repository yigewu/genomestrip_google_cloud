#!/bin/bash

# path to the BAM
p=$1

## the path to picard jar file
pp="/opt/svtoolkit/lib/gatk/picard-2.7.2.jar"

## the path to the output directory
outDir="/home/yigewu2012/bams8/"

## check bam file integrity
samtools quickcheck -v ${outDir}${p}.reheadered > ${outDir}${p}.quickcheck

## check if the complete reheadered bam file exist
if [ "$(cat ${outDir}${p}.quickcheck)" == "${outDir}${p}.reheadered" ]
then
	## extract header
	samtools view -H ${p} > $p"-header.sam"
	echo ${p}" header extracted!"

	## replace header
	sed "s/PL:Illumina_HiSeq2000/PL:ILLUMINA/" ${p}"-header.sam" | sed "s/PL:454/PL:LS454/" | sed "s/PL:illumina/PL:ILLUMINA/" | sed "s/PL:Illumina/PL:ILLUMINA/" | sed "s/PL:SOLiD/PL:SOLID/" > ${p}"-header_corrected.sam"
	echo ${p}" header corrected!"
	
	## reheader bam file
	samtools reheader ${p}"-header_corrected.sam" ${p} > ${outDir}${p}.reheadered
	
	## check bam file integrity
	samtools quickcheck -v ${outDir}${p}.reheadered > ${outDir}${p}.quickcheck
fi	

## if the bam file is normal, preceed to replace the original bam file
if [ "$(cat ${outDir}${p}.quickcheck)" != "${outDir}${p}.reheadered" ]
then
	yes | cp ${outDir}${p}.reheadered ${p}
fi

samtools view -H ${p} | grep PL: | awk -F 'PL:' '{print $2}' | awk -F '\t' '{print $1}' | sort | uniq > PL.tmp
PL=$(cat PL.tmp)
if [ "${PL}" == "ILLUMINA" ] || [ "${PL}" == "LS454" ] || [ "${PL}" == "SOLID" ]
then
	rm ${outDir}${p}".reheadered"
	echo ${p}" reheadered and moved!"
	samtools index -b ${p} ${p}".bai"
	echo "reheadered "${p}" indexed!"
fi	







#rm ${p}
#mv ${p}.reheadered ${p}
echo ${p}" reheadered and moved!"
samtools index -b ${p} $p".bai"
echo "reheadered "${p}" indexed!"
