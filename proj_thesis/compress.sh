#!/bin/bash
#PBS -l nodes=1:ppn=2
#PBS -l mem=32gb
#PBS -l walltime=48:00:00
#PBS -N compress_matches

cd /home/projects/ku_10024/people/zelili/tagger_test/proj_thesis

#for i in $(ls *_all_matches.tsv); do
#	tar -zcf ${i}.tar.gz ${i}
#done

#for i in $(ls *_all_segments.tsv); do
#	tar -zcf ${i}.tar.gz ${i}
#done

#for i in $(ls *_all_pairs.tsv); do
#	tar -zcf ${i}.tar.gz ${i}
#done

#for i in noSJR withSJR logSJR; do
#	tar -zcf ${i}_database_pairs.tar.gz ${i}_database_pairs*.tsv
#done

#tar -zcf cumlative_counts.tar.gz cumulative_counts_*

#tar -zxf noSJR_database_pairs.tar.gz

for i in $(ls *_all_matches.tsv); do
	gzip -9 $i
done

#for i in $(ls *_database_pairs*.tsv | sed 's/_database_pairs.*\.tsv//g' | sort | uniq); do
#	tar -zcf ${i}_database_pairs.tar.gz ${i}_database_pairs*.tsv
#done
