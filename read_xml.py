import sys
import gzip
import xml.etree.ElementTree as ET
import csv

#first argv is input gz file
tree = ET.parse(gzip.open(sys.argv[1], 'r'))
root = tree.getroot()

#print(root[0].find("MedlineCitation").find("PMID").text)
#print(root[0].find("MedlineCitation").find("Article").find("Journal").find("ISSN").text)
#print(root[0].find("MedlineCitation").find("MedlineJournalInfo").find("ISSNLinking").text)

#second argv is output tsv file
with open(sys.argv[2], 'w') as out_file:
	tsv_writer = csv.writer(out_file, delimiter='\t')
	for child in root:
		try: 
			medcite = child.find("MedlineCitation")
			try: pmid = medcite.find("PMID").text
                	except: pmid = " "
                	try:
				journal = medcite.find("Article").find("Journal")
				try: issn = journal.find("ISSN").text
				except: issn = " "
				try: jname = journal.find("Title").text
				except: jname = " "
			except: pass
			try:
				medlinej = medcite.find("MedlineJournalInfo")
				try : issnlin = medlinej.find("ISSNLinking").text
				except: issnlin = " "
				try : sjname = medlinej.find("MedlineTA").text
				except: sjname = " "
			except: pass
		except: pass
		tsv_writer.writerow([pmid, issn, jname, issnlin, sjname])

