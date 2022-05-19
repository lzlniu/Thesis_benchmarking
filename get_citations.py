import sys
import csv
import requests
from bs4 import BeautifulSoup

#pubmed_page = BeautifulSoup(requests.get('https://pubmed.ncbi.nlm.nih.gov/'+sys.argv[1]).text, 'html.parser')

infilename = sys.argv[1]
row_counts = int(sys.argv[2])

with open(infilename) as all_articles_pmid:
	for row in all_articles_pmid:
		pmid = row.split('\t')[0]
		print(pmid, end='\t')
		pubmed_page = BeautifulSoup(requests.get('https://pubmed.ncbi.nlm.nih.gov/'+pmid).text, 'html.parser')
		try:
			#citations_num = pubmed_page.body.find(class_="article-page").main.find(class_="citedby-articles").h2.em.text
			citations_num = pubmed_page.find(class_="citedby-articles").h2.em.text
			print(citations_num, end='\t')
		except:
			print('null', end='\t')

		try:
			pub_time = pubmed_page.find(class_="cit").text
			print(pub_time)
		except:
			print('null')
