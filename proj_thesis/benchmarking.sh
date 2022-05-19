#!/usr/bin/bash
#PBS -W group_list=ku_10024 -A ku_10024
#PBS -N benchmarking_dists
###PBS -e benchmarking.err
###PBS -o benchmarking.log
###PBS -m n
#PBS -l nodes=1:ppn=8
#PBS -l mem=80gb
#PBS -l walltime=24:00:00

#contact:Zelin Li
#date:2022/03/09

# Go to the directory from where the job was submitted (initial directory is $HOME)
echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR

# Define number of processors
NPROCS=`wc -l < $PBS_NODEFILE`
echo This job has allocated $NPROCS nodes
 
# Load all required modules for the job
module load tools
module load perl/5.20.2
module load gcc
module load R/3.5.0

human() {
	in=$1
	cutoff_downrange=$2
	cutoff_uprange=$3
	awk -v label="$4" '{if($1==9606 && $3==9606) {print $2"\t"$4"\t"$5"\t"label}}' ${in}.tsv > ${in}_human-only.tsv
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

#for i in $(ls *normal_all_pairs.tsv | sed 's/_all_pairs.tsv//g'); do
#for i in $(ls all*_citation_all_pairs.tsv | awk -F '_' '{print $1"_"$2}'); do
#for i in $(ls *_all_pairs.tsv | awk -F '_' '{print $1}'); do
#	./new_create_pairs_orig.pl ${i}_all_pairs.tsv ${i}_database_pairs.tsv
#	label=$i
#	#label=`echo $i | awk -F '_' '{print $1"cite"}' | sed 's/all//g' | sed 's/lpha//g'`	
#	human ${i}_database_pairs 4 7 $label
#done

for cutoff in $(ls *_cumulative_counts_*.tsv | awk -F '_' '{print $NF}' | awk -F '.' '{print $1}' | sort | uniq); do
	cat *_database_pairs_cumulative_counts_${cutoff}.tsv | sed -e '/protein1/d' | sed -e "1iprotein1	protein2	score	tp	fp	tp_cum	fp_cum	precision	fn_cum	recall	label" > dists_cumulative_counts_${cutoff}.tsv # orig_database_pairs_cumulative_counts_${cutoff}.tsv
	./string_score_benchmark_plots.1.1.R dists_cumulative_counts_${cutoff}.tsv dists_cutoff${cutoff} score label
	#cat *_database_pairs_cumulative_counts_${cutoff}.tsv | sed -e '/protein1/d' | sed -e "1iprotein1	protein2	score	tp	fp	tp_cum	fp_cum	precision	fn_cum	recall	label" > comparecite_cumulative_counts_${cutoff}.tsv
	#./string_score_benchmark_plots.1.1.R comparecite_cumulative_counts_${cutoff}.tsv comparecite_cutoff${cutoff} score label
done

