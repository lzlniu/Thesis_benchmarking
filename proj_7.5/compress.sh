#!/bin/bash
#PBS -l nodes=1:ppn=4
#PBS -l mem=40gb
#PBS -l walltime=16:00:00

cd /home/projects/ku_10024/people/zelili/tagger_test/proj_7.5

#for i in $(ls *_all_matches.tsv); do
#	tar -zcf ${i}.tar.gz ${i}
#done

#for i in $(ls *_all_segments.tsv); do
#	tar -zcf ${i}.tar.gz ${i}
#done

#for i in $(ls *_all_pairs.tsv); do
#	tar -zcf ${i}.tar.gz ${i}
#done

tar -zcf newtsv.tar.gz new*.tsv
tar -zcf oldtsv.tar.gz old*.tsv
tar -zcf orig_cumulative_counts.tar.gz orig_cumulative*.tsv
tar -zcf cumulative_counts.tar.gz cumulative_counts*.tsv
