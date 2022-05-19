#!/bin/bash
cd /home/projects/ku_10024/people/zelili/tagger_test/xmlout
ls *.tsv | awk -F '.' '{print $1}' > /home/projects/ku_10024/people/zelili/tagger_test/extracted_tsv

cd /home/projects/ku_10024/data/databases/pubmed
ls *.xml.gz | awk -F '.' '{print $1}' > /home/projects/ku_10024/people/zelili/tagger_test/original_xml

cd /home/projects/ku_10024/people/zelili/tagger_test
./files_diff.sh extracted_tsv original_xml
rm -rf extracted_tsv original_xml
