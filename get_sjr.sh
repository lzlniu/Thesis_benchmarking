#!/bin/bash
#how many rows of each column

echo "Start counting element number of each column"

if [ ! -f journalrank.txt ]; then
	awk -F '"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(";", ",", $i) } 1' journalrank.xls | sed -e 's/"-"//g' | sed -e 's/;-;/;;/g' | sed -e 's/"//g'  > journalrank.txt
fi

for col in `seq 1 21`; do
	printf "$col "
	head -1 journalrank.xls | awk -F ';' -v column="$col" '{print $column" "}'
	awk -F ';' -v column="$col" '{print $column}' journalrank.txt | grep -v '^$' | wc -l
done

echo "Finish counting element number of each column."
