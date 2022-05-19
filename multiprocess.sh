#!/bin/bash
#PBS -W group_list=ku_10024 -A ku_10024
#PBS -N cites
#PBS -e cites.err
#PBS -o cites.log
#PBS -l nodes=1:ppn=40
#PBS -l mem=120gb
#PBS -l walltime=48:00:00

echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR

module load tools
module load anaconda3/4.4.0

infile="/home/projects/ku_10024/people/zelili/tagger_test/all_uniq_Wc_head200.tsv"
outfile="/home/projects/ku_10024/people/zelili/tagger_test/all_cite_year_head200.tsv"
#row_count=`wc -l $infile | awk '{print $1}'`

python /home/projects/ku_10024/people/zelili/tagger_test/multiprocess_test.py $infile $outfile
