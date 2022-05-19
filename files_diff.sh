#!/bin/bash
#author:Zelin Li
#date:2021/12/14

echo "Total $# files input, they are $@."
for i in $@; do
	printf "$i have `cat $i | sort | uniq | wc -l` unique rows.\n"
done

# uniq -d only print the duplicated rows. while uniq -u only print the unique rows (they are opposite to each other)
cat $@ | sort | uniq -d > filetmp # find the rows that at least occured in 2 files
printf "Do you want to store the differences into a file? [yes|no]\n"
printf "default:no >>> "
read -r ans
if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && [ "$ans" != "y" ]   && [ "$ans" != "Y" ]; then
	printf "Not saving the comparasion results.\n"
	for i in $@; do
		printf "$i differ to others is:\n"
		cat $i filetmp | sort | uniq -u
	done
else
	printf "Saving the comparasion results, please specify the output dictionary name:\n"
	printf "default:diff >>> "
	read -r output_dict
	if [ -z "${output_dict// }" ]; then
		output_dict="diff"
	fi
	if [ -d $output_dict ]; then
		rm -rf $output_dict
		mkdir $output_dict
	else
		mkdir $output_dict
	fi
	for i in $@; do
		# find the rows in this file that differ from filetmp (rows that at least occured in 2 files)
		cat $i filetmp | sort | uniq -u > ./$output_dict/${i}_diff.txt
		printf "$i differ to others is stored in $(pwd)/$output_dict/${i}_diff.txt\n"
	done
fi
rm -rf filetmp

