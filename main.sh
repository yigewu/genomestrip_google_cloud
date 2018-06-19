#!/bin/bash

group1="HighPass"
group2="OV"
mainRunDir="/home/yigewu2012/genomestrip/"
inputDir=${mainRunDir}"inputs/"
outputDir=${mainRunDir}"outputs/"${group1}"_"${group2}"/"
logDir=${mainRunDir}"logs/"
cmdFile=${logDir}"cmd.txt"
docker_ps=${logDir}"docker_ps.log"

## start a file containing the docker commands
touch ${cmdFile} > ${cmdFile}

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
cm="bash docker_run_by_script.sh ${group1} ${group2} reheader_bam_platform4GNU.sh"
echo $cm

## create the file containing the path to the new BAMs
cm="yes | bash create_bam_paths.sh"
echo $cm

## create the gender info file for all the BAMs
## ?
cm="bash docker_run_by_script.sh "${group1}" "${group2}" create_gender_map.sh"
echo $cm

## preprocess the BAMS
## 10 hrs
cm="bash docker_run_by_script.sh "${group1}" "${group2}" svPreprocess.sh"
echo $cm

## get the current docker container information
docker ps > ${docker_ps}
num_cpu=8

## start generate the bash script to launch by chromosome jobs for following steps
echo "#!/bin/bash" > ${cmdFile}.sh

## discover deletions
step="svDiscovery"
while read chr;do
	cm="bash docker_run_by_script.sh "${group1}" "${group2}" svDiscovery.sh "${chr}
	## get the latest log file for this step
	ls ${logDir}${step}"CHR"${chr}"_"${group1}"_"${group2}* | tail -1 1>${logDir}"tmp" 2>/dev/null
	## if in the lastest log file it's done and the output file exist then mark it as done
	if [ ! -s ${logDir}"tmp" ]
	then
		echo ${step}" for chr"${chr}" hasn't been run yet!"
		${cm} >> ${cmdFile}
	else
		if [ -s ${outputDir}${step}"/discovery_"${group1}"_"${group2}"_chr"${chr}".vcf" ] &&  grep -Fq "Script completed successfully" $(cat ${logDir}"tmp")
		then
			echo ${step}" for chr"${chr}" done!"
		else
			if grep -Fq ${step}"CHR"${chr} ${mainRunDir}"logs/docker_ps.log"
			then
				echo ${step}" for chr"${chr}" is already running!"
			else
				echo ${step}" for chr"${chr}" just continued running!"
				${cm} >> ${cmdFile}
			fi
		fi
	fi
	echo ""
done<${inputDir}"chromosome2process.txt"


## genotype deletions
step="delGenotype"
cpu_per_step=1
num_step_inps=$(cat ${docker_ps} | grep ${step} | wc | awk -F ' ' '{print $1}')
tmp=$(expr ${num_cpu} - ${num_step_inps})
num_cpu=${tmp}
if [ "${num_cpu}" -gt 0 ]
then
	while read chr;do
		cm="bash docker_run_by_script.sh "${group1}" "${group2}" "${step}".sh "${chr}
		## get the latest log file for this step
		ls ${logDir}${step}"CHR"${chr}"_"${group1}"_"${group2}* 1>${logDir}"tmp" 2>/dev/null
		## if in the lastest log file it's done and the output file exist then mark it as done
		if [ ! -s ${logDir}"tmp" ]
		then
			echo ${step}" for chr"${chr}" hasn't been run yet!"
			${cm} >> ${cmdFile}
		else
			if [ -s ${outputDir}${step}"/"${step}"_"${group1}"_"${group2}"_chr"${chr}".vcf" ] &&  grep -Fq "Script completed successfully" $(cat ${logDir}"tmp" | tail -1)
			then
				echo ${step}" for chr"${chr}" done!"
			else
				if grep -Fq ${step}"CHR"${chr} ${mainRunDir}"logs/docker_ps.log"
				then
					echo ${step}" for chr"${chr}" is already running!"
				else
					echo ${step}" for chr"${chr}" just continued running!"
					${cm} >> ${cmdFile}
				fi
			fi
		fi
		echo ""
	done<${inputDir}"chromosome2process.txt"
	num_step_2ps=$(cat ${cmdFile} | grep ${step} | wc | awk -F ' ' '{print $1}')
	max_step_ps=$(expr ${num_cpu} / ${cpu_per_step})
	if [ "${max_step_ps}" -lt "${num_step_2ps}" ]
	then
		num_step_2ps=${max_step_ps}
	fi
	new_cmd=$(expr ${num_step_2ps} \* 2)
	cat ${cmdFile} | head -n ${new_cmd} >> ${cmdFile}.sh
	tail -n "+"$(expr ${new_cmd} + 1) ${cmdFile} > ${logDir}"tmp"
	cat ${logDir}"tmp" > ${cmdFile}
fi

## discover CNVs (deletions and amplifciations) 
step="cnvDiscovery"
cpu_per_step=4
num_step_inps=$(cat ${docker_ps} | grep ${step} | wc | awk -F ' ' '{print $1}')
tmp=$(expr ${num_cpu} - ${num_step_inps})
num_cpu=${tmp}
if [ "${num_cpu}" -gt 0 ]
then
	while read chr;do
		cm="bash docker_run_by_script.sh "${group1}" "${group2}" "${step}".sh "${chr}
		## get the latest log file for this step
		ls ${logDir}${step}"CHR"${chr}"_"${group1}"_"${group2}* 1>${logDir}"tmp" 2>/dev/null
		## if in the lastest log file it's done and the output file exist then mark it as done
		if [ ! -s ${logDir}"tmp" ]
		then
			echo ${step}" for chr"${chr}" hasn't been run yet!"
			${cm} >> ${cmdFile}
		else
			if [ -s ${outputDir}${step}"/"${step}"_"${group1}"_"${group2}"_chr"${chr}".vcf" ] &&  grep -Fq "Script completed successfully" $(cat ${logDir}"tmp" | tail -1)
			then
				echo ${step}" for chr"${chr}" done!"
			else
				if grep -Fq ${step}"CHR"${chr} ${mainRunDir}"logs/docker_ps.log"
				then
					echo ${step}" for chr"${chr}" is already running!"
				else
					echo ${step}" for chr"${chr}" just continued running!"
					${cm} >> ${cmdFile}
				fi
			fi
		fi
		echo ""
	done<${inputDir}"chromosome2process.txt"
	num_step_2ps=$(cat ${cmdFile} | grep ${step} | wc | awk -F ' ' '{print $1}')
	max_step_ps=$(expr ${num_cpu} / ${cpu_per_step})
	if [ "${max_step_ps}" -lt "${num_step_2ps}" ]
	then
		num_step_2ps=${max_step_ps}
	fi
	new_cmd=$(expr ${num_step_2ps} \* 2)
	cat ${cmdFile} | head -n ${new_cmd} >> ${cmdFile}.sh
	tail -n "+"$(expr ${new_cmd} + 1) ${cmdFile} > ${logDir}"tmp"
	cat ${logDir}"tmp" > ${cmdFile}
fi


## genotype CNVs
## 10 mins, CPU: 25%
cm="bash docker_run_by_script.sh "${group1}" "${group2}" cnvGenotype.sh"
echo $cm

## copy outputs to buckets
