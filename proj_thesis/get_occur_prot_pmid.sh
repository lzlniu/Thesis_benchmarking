#!/bin/bash

cd /home/projects/ku_10024/people/zelili/tagger_test/proj_thesis/
awk -F '\t' '{if($7>0) print $0}' biobertR_all_matches.tsv > prots_matches.tsv
sort -u -t$'\t' -k 1,1n prots_matches.tsv > prots_least_one_matches.tsv
awk -F '\t' '{print $1}' prots_least_one_matches.tsv > prots_least_one_matches_pmid.tsv
