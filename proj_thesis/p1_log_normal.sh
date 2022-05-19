#!/bin/sh
#PBS -W group_list=ku_10024 -A ku_10024
#PBS -N p1_log_normal
#PBS -e p1_log_normal.err
#PBS -o p1_log_normal.log
#PBS -l nodes=1:ppn=40
#PBS -l mem=120gb
#PBS -l walltime=24:00:00
  
echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR
NPROCS=`wc -l < $PBS_NODEFILE`
echo This job has allocated $NPROCS nodes
 
#gzip -cd `ls -1 /home/projects/ku_10024/data/databases/pmc/*.en.merged.filtered.tsv.gz` `ls -1r /home/projects/ku_10024/data/databases/pubmed/*.tsv.gz` | cat /home/projects/ku_10024/people/zelili/tagger_test/excluded_documents2.txt - | /home/projects/ku_10024/people/zelili/tagger/tagcorpus --threads=40 --autodetect --types=/home/projects/ku_10024/data/dictionary/curated_types.tsv --entities=/home/projects/ku_10024/data/dictionary/all_entities.tsv --names=/home/projects/ku_10024/data/dictionary/all_names_textmining.tsv --groups=/home/projects/ku_10024/data/dictionary/all_groups.tsv --stopwords=/home/projects/ku_10024/data/dictionary/all_global.tsv --local-stopwords=/home/projects/ku_10024/data/dictionary/all_local.tsv --corpus-weights=/home/projects/ku_10024/people/zelili/xmler/sorted_p1_log_normal_counts.tsv --type-pairs=/home/projects/ku_10024/data/dictionary/all_type_pairs.tsv --out-matches=/home/projects/ku_10024/people/zelili/tagger_test/proj_thesis/p1_log_normal_all_matches.tsv --out-segments=/home/projects/ku_10024/people/zelili/tagger_test/proj_thesis/p1_log_normal_all_segments.tsv --out-pairs=/home/projects/ku_10024/people/zelili/tagger_test/proj_thesis/p1_log_normal_all_pairs.tsv

gzip -cd `ls -1 /home/projects/ku_10024/data/databases/pmc/*.en.merged.filtered.tsv.gz` `ls -1r /home/projects/ku_10024/data/databases/pubmed/*.tsv.gz` | cat /home/projects/ku_10024/people/zelili/tagger_test/excluded_documents2.txt - | /home/projects/ku_10024/people/zelili/tagger/tagcorpus --threads=40 --autodetect --types=/home/projects/ku_10024/data/dictionary/curated_types.tsv --entities=/home/projects/ku_10024/data/dictionary/all_entities.tsv --names=/home/projects/ku_10024/data/dictionary/all_names_textmining.tsv --groups=/home/projects/ku_10024/data/dictionary/all_groups.tsv --stopwords=/home/projects/ku_10024/data/dictionary/all_global.tsv --local-stopwords=/home/projects/ku_10024/data/dictionary/all_local.tsv --corpus-weights=/home/projects/ku_10024/people/zelili/xmler/p1_log_normalized_citation_counts.tsv --type-pairs=/home/projects/ku_10024/data/dictionary/all_type_pairs.tsv --out-matches=/home/projects/ku_10024/people/zelili/tagger_test/proj_thesis/p1_log_normal_all_matches.tsv --out-segments=/home/projects/ku_10024/people/zelili/tagger_test/proj_thesis/p1_log_normal_all_segments.tsv --out-pairs=/home/projects/ku_10024/people/zelili/tagger_test/proj_thesis/p1_log_normal_all_pairs.tsv

