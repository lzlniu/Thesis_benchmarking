#!/bin/bash

outpath="/home/projects/ku_10024/people/zelili/tagger_test/proj_thesis"
weightpath="/home/projects/ku_10024/people/zelili/xmler"

cd $outpath
#for outname in $(ls ${weightpath}/sorted_*_counts.tsv | awk -F '/' '{print $NF}' | awk -F '_' '{print $2"_"$3}'); do
for outname in $(ls ${weightpath}/p1*normalized_citation_counts.tsv | awk -F '/' '{print $NF}' | sed 's/ized_citation_counts.tsv//g'); do
echo "#!/bin/sh
#PBS -W group_list=ku_10024 -A ku_10024
#PBS -N ${outname}
#PBS -e ${outname}.err
#PBS -o ${outname}.log
#PBS -l nodes=1:ppn=40
#PBS -l mem=120gb
#PBS -l walltime=24:00:00
  
echo Working directory is \$PBS_O_WORKDIR
cd \$PBS_O_WORKDIR
NPROCS=\`wc -l < \$PBS_NODEFILE\`
echo This job has allocated \$NPROCS nodes
 
#gzip -cd \`ls -1 /home/projects/ku_10024/data/databases/pmc/*.en.merged.filtered.tsv.gz\` \`ls -1r /home/projects/ku_10024/data/databases/pubmed/*.tsv.gz\` | cat /home/projects/ku_10024/people/zelili/tagger_test/excluded_documents2.txt - | /home/projects/ku_10024/people/zelili/tagger/tagcorpus --threads=40 --autodetect --types=/home/projects/ku_10024/data/dictionary/curated_types.tsv --entities=/home/projects/ku_10024/data/dictionary/all_entities.tsv --names=/home/projects/ku_10024/data/dictionary/all_names_textmining.tsv --groups=/home/projects/ku_10024/data/dictionary/all_groups.tsv --stopwords=/home/projects/ku_10024/data/dictionary/all_global.tsv --local-stopwords=/home/projects/ku_10024/data/dictionary/all_local.tsv --corpus-weights=${weightpath}/sorted_${outname}_counts.tsv --type-pairs=/home/projects/ku_10024/data/dictionary/all_type_pairs.tsv --out-matches=${outpath}/${outname}_all_matches.tsv --out-segments=${outpath}/${outname}_all_segments.tsv --out-pairs=${outpath}/${outname}_all_pairs.tsv

gzip -cd \`ls -1 /home/projects/ku_10024/data/databases/pmc/*.en.merged.filtered.tsv.gz\` \`ls -1r /home/projects/ku_10024/data/databases/pubmed/*.tsv.gz\` | cat /home/projects/ku_10024/people/zelili/tagger_test/excluded_documents2.txt - | /home/projects/ku_10024/people/zelili/tagger/tagcorpus --threads=40 --autodetect --types=/home/projects/ku_10024/data/dictionary/curated_types.tsv --entities=/home/projects/ku_10024/data/dictionary/all_entities.tsv --names=/home/projects/ku_10024/data/dictionary/all_names_textmining.tsv --groups=/home/projects/ku_10024/data/dictionary/all_groups.tsv --stopwords=/home/projects/ku_10024/data/dictionary/all_global.tsv --local-stopwords=/home/projects/ku_10024/data/dictionary/all_local.tsv --corpus-weights=${weightpath}/${outname}ized_citation_counts.tsv --type-pairs=/home/projects/ku_10024/data/dictionary/all_type_pairs.tsv --out-matches=${outpath}/${outname}_all_matches.tsv --out-segments=${outpath}/${outname}_all_segments.tsv --out-pairs=${outpath}/${outname}_all_pairs.tsv
" > ${outpath}/${outname}.sh
qsub < ${outpath}/${outname}.sh
done
