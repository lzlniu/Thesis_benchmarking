#!/bin/bash

module load tools
module load anaconda3/4.4.0

infile="/home/projects/ku_10024/people/zelili/tagger_test/all_pmid.txt"
outfile="/home/projects/ku_10024/people/zelili/tagger_test/all_cite_year2.tsv"
row_count=`wc -l $infile | awk '{print $1}'`
row_count_digits=${#row_count}-1
cpu_num=40
if [[ row_count_digits -lt 6 ]]; then
	((out_num=cpu_num))
else
	((out_num=cpu_num*10**(row_count_digits-5)))
fi
((seg_size=row_count/out_num))

tmpout="/home/projects/ku_10024/people/zelili/tagger_test/cite_calc_tmp"
if [[ ! -d "$tmpout" ]]; then mkdir $tmpout; fi

for i in $(seq 0 $out_num); do
	((line_s=$i*seg_size))
	((line_e=($i+1)*seg_size-1))
	((line_e_next=line_e+1))
	if [[ line_s -eq 0 ]]; then
		((line_s=1))
	fi
	if [[ line_e -ge row_count ]]; then
		((line_e=row_count))
	fi
	#if [[ i -gt 3998 ]]; then sed -n "${line_s},${line_e}p; ${line_e_next}q" $infile; fi
	echo "#!/bin/bash
#PBS -W group_list=ku_10024 -A ku_10024
#PBS -N cites${i}
#PBS -e cites${i}.err
#PBS -o cites${i}.log
#PBS -l nodes=1:ppn=1
#PBS -l mem=16gb
#PBS -l walltime=24:00:00

echo Working directory is \$PBS_O_WORKDIR
cd \$PBS_O_WORKDIR

for j in \$(sed -n \"${line_s},${line_e}p; ${line_e_next}q\" $infile); do
	wget https://pubmed.ncbi.nlm.nih.gov/\$j > $tmpout/\${j}.html
	cite=\`grep '<em class=\\\"amount\\\">[0-9]*</em>' $tmpout/\${j}.html | awk -F '>' '{print \$2}' | awk -F '<' '{print \$1}'\`
	year=\`grep 'class=\\\"cit\\\"' $tmpout/\${j}.html | sed -n 1p | awk -F '>' '{print \$(NF-1)}' | awk -F '<' '{print \$1}' | grep -o '\\b[0-9]\\{4\\}\\b'\`
	rm -rf $tmpout/\${j}.html
	printf \"\${j}\\t\${cite}\\t\${year}\\n\" >> $tmpout/cites${i}.tsv
done" > $tmpout/cites${i}.sh
	qsub < $tmpout/cites${i}.sh
done

