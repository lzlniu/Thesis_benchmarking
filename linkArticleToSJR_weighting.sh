#!/bin/bash
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=ku_10024 -A ku_10024
### Job name (comment out the next line to get the name of the script used as the job name)
#PBS -N Wc_new_pubmed21n0001
### Output files (comment out the next 2 lines to get the job name used instead)
#PBS -e Wc_new_pubmed21n0001.e
#PBS -o Wc_new_pubmed21n0001.o
### Only send mail when job is aborted or terminates abnormally
###PBS -m n
### Number of nodes
#PBS -l nodes=1:ppn=40
### Memory
#PBS -l mem=120gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds>
#PBS -l walltime=24:00:00
###PBS -X

sjr="/home/projects/ku_10024/people/zelili/tagger_test/journalrank567.txt"
input="new_pubmed21n0001.tsv"
Wc=Wc_$input

cd /home/projects/ku_10024/people/zelili/tagger_test/xmlout
for PMIDandISSNs in $(awk -F '\t' '{print $1","$2","$4}' $input | sed s/[[:space:]]//g); do # tr -s [:space:], remove more than one space
	IFS=, read PMID ISSN1 ISSN2 <<< $PMIDandISSNs
	if [ -n "$PMID" ]; then
		if [ -n "$ISSN1" ] && [ ! -n "$ISSN2" ]; then
			SJR=`grep $ISSN1 $sjr | awk -F '\t' '{print $2}' | sed s/[[:space:]]//g`
			if [ -n "$SJR" ]; then
				echo "$PMID $ISSN1 NoISSN2 ISSN1_SJR_IsFound"
				printf "${PMID}\t${SJR}\n" >> $Wc
			else
				echo "$PMID $ISSN1 NoISSN2 ISSN1_SJR_NotFound"
			fi
		elif [ ! -n "$ISSN1" ] && [ -n "$ISSN2" ]; then
			SJR=`grep $ISSN2 $sjr | awk -F '\t' '{print $2}' | sed s/[[:space:]]//g`
			if [ -n "$SJR" ]; then
				echo "$PMID NoISSN1 $ISSN2 ISSN2_SJR_IsFound"
				printf "${PMID}\t${SJR}\n" >> $Wc
			else
				echo "$PMID NoISSN1 $ISSN2 ISSN2_SJR_NotFound"
			fi
		elif [ -n "$ISSN1" ] && [ -n "$ISSN2" ]; then
			SJR=`grep $ISSN1 $sjr | awk -F '\t' '{print $2}' | sed s/[[:space:]]//g`
			if [ -n "$SJR" ]; then
				echo "$PMID $ISSN1 $ISSN2 ISSN1_SJR_IsFound"
				printf "${PMID}\t${SJR}\n" >> $Wc
			else
				SJR=`grep $ISSN2 $sjr | awk -F '\t' '{print $2}' | sed s/[[:space:]]//g`
				if [ -n "$SJR" ]; then
					echo "$PMID ISSN1_NoSJR $ISSN2 ISSN2_SJR_IsFound"
					printf "${PMID}\t${SJR}\n" >> $Wc
				else
					echo "$PMID $ISSN1 $ISSN2 Both_SJR_NotFound"
				fi
			fi
		else
			echo "$PMID Both_ISSN_NotFound"
		fi
	else
		echo "$ISSN1 $ISSN2 PMID_NotFound"
	fi
done
sed -i 's/,/./g' $Wc
cat $Wc | sort | uniq -u > weight_$input
#rm -rf $Wc
