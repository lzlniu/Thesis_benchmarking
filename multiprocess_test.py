import sys
import re
#import math
#import requests
#import csv
#import multiprocessing as mp
#from bs4 import BeautifulSoup

#count_line = lambda filename: sum(1 for line in open(filename))
#print(count_line('all_uniq_Wc.tsv'))

#infilename = sys.argv[1]
#outfilename = sys.argv[2]
#row_count = int(sys.argv[2])
print("now inside script")
#infile = open('/home/projects/ku_10024/people/zelili/tagger_test/all_uniq_Wc_head10.tsv', 'r').readlines()
#print(infile[1],sys.argv[1],math.log10(100))

def read_lines(f, start, end):
	try:
		lines=[]
		if start<=1:
			for line in range(start-1, end, 1): lines.append(f[line])
		else:
			for line in range(start, end, 1): lines.append(f[line])
		return lines
	except:
		print("ERROR: Can't read the lines", start, "to", end)

def get_col1(text):
	match1 = text.split('\t')[0]
	if match1: return match1
	else: print("WARNING: Not found the first column of", text)
	#return re.split(r'[\s]+', text)[0]
	#return re.match('.+?(?=\\t)', text)

def get_col2(text):
	match2 = re.match('.+?(?=\\n)', text.split('\t')[1])
	if match2: return match2.group(0)
	else: print("WARNING: Not found the second column of", text)

def get_cite(f, start, end):
	cites=[]
	for i in read_lines(f, start, end):
		pmidtext = get_col1(i)
		pubmed_page = BeautifulSoup(requests.get('https://pubmed.ncbi.nlm.nih.gov/'+pmidtext).text, 'html.parser')
		pmid = int(pmidtext)
		try:
			#citations_num = pubmed_page.body.find(class_="article-page").main.find(class_="citedby-articles").h2.em.text
			citations_num = int(pubmed_page.find(class_="citedby-articles").h2.em.text)
		except:
			citations_num = -1
		try:
			#pub_year = pubmed_page.find(class_="cit").text
			match_year = re.match('\\b[0-9]{4}\\b', pubmed_page.find(class_="cit").text)
			if match_year: pub_year = int(match_year.group(0))
		except:
			pub_year = -1
		cites.append([pmid, citations_num, pub_year])
	return cites

def sep_lines(line_count, cpu_count):
	try:
		lines_set=[]
		line_count_digits = int(math.log10(line_count))
		if line_count_digits>=6:
			sep_chunksize = cpu_count*10**(line_count_digits-5)
		else:
			sep_chunksize = cpu_count
		line_span = line_count // sep_chunksize
		for i in range(sep_chunksize+1):
			if ((i+1)*line_span > line_count):
				lines_set.append([i*line_span+1, line_count])
			else:
				lines_set.append([i*line_span+1, (i+1)*line_span+1])
		return lines_set
	except:
		print("ERROR: Can't read the file's lines")

def parallel_read_lines(file_name):
	cpu_num = mp.cpu_count()
	#with open(file_name, 'r').readlines() as infile:
	infile = open(file_name, 'r').readlines()
	pool = mp.Pool(cpu_num)
	pool_all_cites = pool.starmap(get_cite, [(infile, line[0], line[1]) for line in sep_lines(len(infile), cpu_num)])
	pool.close()
	all_cites=[]
	# Combine all the cites in sublist ('pool_cites') into one list 'all_cites'
	for pool_cites in pool_all_cites:
		for cite in pool_cites:
			all_cites.append(cite)
	return all_cites

if __name__ == '__main__':
	#all_cites = parallel_read_lines('all_uniq_Wc.tsv')
	#with open(outfilename, 'w') as f_out:
	#	writer = csv.writer(f_out, delimiter='\t')
	#	writer.writerows(parallel_read_lines(infilename))
	infile = open('/home/projects/ku_10024/people/zelili/tagger_test/all_uniq_Wc_head10.tsv', 'r').readlines()
	print(get_cite(infile,1,2))

