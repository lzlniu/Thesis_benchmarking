#!/usr/bin/bash
#PBS -W group_list=ku_10024 -A ku_10024
###PBS -m n
#PBS -l nodes=1:ppn=4
#PBS -l mem=32gb
#PBS -l walltime=12:00:00
###PBS -X

# Go to the directory from where the job was submitted (initial directory is $HOME)
echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR

#exec 1>${PBS_JOBID}_only_hum.out
#exec 2>${PBS_JOBID}_only_hum.err
 
### Here follows the user commands:
# Define number of processors
NPROCS=`wc -l < $PBS_NODEFILE`
echo This job has allocated $NPROCS nodes

module load tools
module load gcc
module load R/3.5.0

human() {
	in=$1
	cutoff_downrange=$2
	cutoff_uprange=$3
	awk -v sjr="$4" '{if($1==9606 && $3==9606) {print $2"\t"$4"\t"$5"\t"sjr}}' ${in}.tsv > ${in}_human-only.tsv
	cat ${in}_human-only.tsv | sort -g -k3,3rn > ${in}_4_columns_input.tsv
	max=`wc -l ${in}_4_columns_input.tsv | awk '{print $1}'`
	for range in all `seq $cutoff_downrange $cutoff_uprange`; do
		if [ "$range" == "all" ]; then
			cutoff=$range
			cp ${in}_4_columns_input.tsv ${in}_4_columns_input_${cutoff}.tsv
		else
			let cutoff=10**$range
			if [ $cutoff -ge $max ]; then let cutoff=$max; fi
			head -$cutoff ${in}_4_columns_input.tsv > ${in}_4_columns_input_${cutoff}.tsv
		fi
		python3 string_score_benchmark.1.1.py -i ${in}_4_columns_input_${cutoff}.tsv -g benchmark_kegg_2col.tsv -o ${in}_cumulative_counts_${cutoff}.tsv
	done
}
human old_database_pairs_orig 4 7 no_SJR
human new_database_pairs_orig 4 7 with_SJR

for cutoff in $(ls *_cumulative_counts_*.tsv | awk -F '_' '{print $NF}' | awk -F '.' '{print $1}' | sort | uniq); do
	cat old_database_pairs_orig_cumulative_counts_${cutoff}.tsv new_database_pairs_orig_cumulative_counts_${cutoff}.tsv | sed -e '/protein1/d' | sed -e "1iprotein1	protein2	score	tp	fp	tp_cum	fp_cum	precision	fn_cum	recall	label" > orig_cumulative_counts_${cutoff}.tsv
	./string_score_benchmark_plots.1.1.R orig_cumulative_counts_${cutoff}.tsv orig_cutoff${cutoff} score label
done

