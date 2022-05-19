#!/usr/bin/bash
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=ku_10024 -A ku_10024
### Job name (comment out the next line to get the name of the script used as the job name)
#PBS -N old_create_pairs
### Output files (comment out the next 2 lines to get the job name used instead)
#PBS -e old_create_pairs.err
#PBS -o old_create_pairs.log
### Only send mail when job is aborted or terminates abnormally
###PBS -m n
### Number of nodes
#PBS -l nodes=1:ppn=8
### Memory
#PBS -l mem=120gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 12 hours)
#PBS -l walltime=24:00:00
### Forward X11 connection (comment out if not needed)
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
 
# Load all required modules for the job
module load tools
module load perl/5.20.2

perl old_create_pairs_orig.pl
