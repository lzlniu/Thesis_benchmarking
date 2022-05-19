#!/bin/bash
#author:Zelin Li
#date:2022/01/11

xml_dict='/home/projects/ku_10024/data/databases/pubmed'
#work_dict='/home/projects/ku_10024/scratch/zelin'
work_dict='/home/projects/ku_10024/people/zelili/tagger_test'
out_dict_name='xmlout'

if [ ! -d ${work_dict}/$out_dict_name ]; then
	mkdir ${work_dict}/$out_dict_name
fi

for file in $(ls ${xml_dict}/*.xml.gz | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}'); do
echo "#!/bin/bash
#PBS -N ${file}_xml
#PBS -l walltime=240:00:00
#PBS -e extract_xml.err
#PBS -o extract_xml.log
python ${work_dict}/read_xml.py ${xml_dict}/${file}.xml.gz ${work_dict}/${out_dict_name}/${file}.tsv
" > ${work_dict}/extract_xml.sh
qsub < ${work_dict}/extract_xml.sh
done
