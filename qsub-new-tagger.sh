#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=ku_10024 -A ku_10024
### Job name (comment out the next line to get the name of the script used as the job name)
#PBS -N distbiobert
### Output files (comment out the next 2 lines to get the job name used instead)
#PBS -e logs/reanalysis_distbiobert.err
#PBS -o logs/reanalysis_distbiobert.log
### Only send mail when job is aborted or terminates abnormally
###PBS -m n
### Number of nodes
#PBS -l nodes=1:ppn=40
### Memory
#PBS -l mem=120gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 12 hours)
#PBS -l walltime=24:00:00
### Forward X11 connection (comment out if not needed)
###PBS -X

# Go to the directory from where the job was submitted (initial directory is $HOME)
echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR

#exec 1 > logs/reanalysis_${PBS_JOBNAME}.out
#exec 2 > logs/reanalysis_${PBS_JOBNAME}.err
 
### Here follows the user commands:
# Define number of processors
NPROCS=`wc -l < $PBS_NODEFILE`
echo This job has allocated $NPROCS nodes
 
# Load all required modules for the job
#module load tools
#module load perl/5.20.2
#module load <other stuff>

# This is where the work is done
# Make sure that this script is not bigger than 64kb ~ 150 lines, otherwise put in seperat script and execute from here

weightfile=/home/projects/ku_10024/people/zelili/tagger_test/weights_${PBS_JOBNAME}.tsv
gzip -cd `ls -1 /home/projects/ku_10024/data/databases/pmc/*.en.merged.filtered.tsv.gz` `ls -1r /home/projects/ku_10024/data/databases/pubmed/*.tsv.gz` | cat /home/projects/ku_10024/people/zelili/tagger_test/excluded_documents2.txt - | /home/projects/ku_10024/people/zelili/tagger/tagcorpus --threads=40 \
	--autodetect \
	--types=/home/projects/ku_10024/data/dictionary/curated_types.tsv \
	--entities=/home/projects/ku_10024/data/dictionary/all_entities.tsv \
	--names=/home/projects/ku_10024/data/dictionary/all_names_textmining.tsv \
	--groups=/home/projects/ku_10024/data/dictionary/all_groups.tsv \
	--stopwords=/home/projects/ku_10024/data/dictionary/all_global.tsv \
	--local-stopwords=/home/projects/ku_10024/data/dictionary/all_local.tsv \
	--corpus-weights=${weightfile} \
	--type-pairs=/home/projects/ku_10024/data/dictionary/all_type_pairs.tsv \
	--out-matches=/home/projects/ku_10024/people/zelili/tagger_test/proj_thesis_reanalysis/${PBS_JOBNAME}_all_matches.tsv \
	--out-segments=/home/projects/ku_10024/people/zelili/tagger_test/proj_thesis_reanalysis/${PBS_JOBNAME}_all_segments.tsv \
	--out-pairs=/home/projects/ku_10024/people/zelili/tagger_test/proj_thesis_reanalysis/${PBS_JOBNAME}_all_pairs.tsv

cd /home/projects/ku_10024/people/zelili/tagger_test/proj_thesis_reanalysis/
gzip -9 ${PBS_JOBNAME}_all_matches.tsv
gzip -9 ${PBS_JOBNAME}_all_segments.tsv

