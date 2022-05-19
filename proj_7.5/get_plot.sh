#!/usr/bin/bash
#PBS -W group_list=ku_10024 -A ku_10024
#PBS -l nodes=1:ppn=4
#PBS -l mem=16gb
#PBS -l walltime=4:00:00

# Go to the directory from where the job was submitted (initial directory is $HOME)
echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR

NPROCS=`wc -l < $PBS_NODEFILE`
echo This job has allocated $NPROCS nodes

module load tools
module load gcc
module load R/3.5.0

for i in old new; do
	cat ${i}_database_pairs-human-only.tsv | sort -g -k3,3rn > ${i}_4_columns_input.tsv
	for cutoff in all 500000 50000 5000 500; do
		if [ cutoff == "all" ]; then
			cp ${i}_4_columns_input.tsv ${i}_4_columns_input_${cutoff}.tsv
		else
			head -$cutoff ${i}_4_columns_input.tsv > ${i}_4_columns_input_${cutoff}.tsv
		fi
		python3 string_score_benchmark.1.1.py -i ${i}_4_columns_input_${cutoff}.tsv -g benchmark_kegg_2col.tsv -o ${i}_cumulative_counts_${cutoff}.tsv
	done	
done

./string_score_benchmark_plots.1.1.R ${i}_cumulative_counts_${cutoff}.tsv ${i}_cutoff${cutoff} score label
