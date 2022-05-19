#!/usr/bin/bash
#PBS -W group_list=ku_10024 -A ku_10024
#PBS -N old_only_prot
#PBS -e old_only_prot.err
#PBS -o old_only_prot.log
###PBS -m n
#PBS -l nodes=1:ppn=8
#PBS -l mem=120gb
#PBS -l walltime=24:00:00
###PBS -X

# Go to the directory from where the job was submitted (initial directory is $HOME)
echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR

exec 1>${PBS_JOBID}.out
exec 2>${PBS_JOBID}.err
 
### Here follows the user commands:
# Define number of processors
NPROCS=`wc -l < $PBS_NODEFILE`
echo This job has allocated $NPROCS nodes

in="old_database_pairs"
awk '{if($1>0 && $3>0) {print $0}}' ${in}.tsv > ${in}-protein-only.tsv
