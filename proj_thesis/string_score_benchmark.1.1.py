#!/usr/bin/python3

## Benchmark a list of protein pairs ranked by score using a gold standard dataset
## (e.g. KEGG for functional, Complex Portal for physical association score)
## Input 1:	List of pairs of presumably physically associated proteins ranked from highest to lowest score
##			(tab-separated: protein1, protein2, score, label)
## Input 2:	Gold standard dataset (tab-separated: group identifier, '|'-separated participants)
## Input 3:	Weighing scheme: Choose one of:
##			'none' (naive TP and FP count),
##			'maxsize' (complexes exceeding the maximum size are disregarded),
##			'size' (counts are normalized by the number of possible pairs a protein can be part of in that complex),
##			'degree' (counts are normalized by the product of the degree of both proteins in the pairs graph of the
##			benchmark dataset)
## Input depending on weighing scheme:
## If chosen weighing scheme is 'degree', provide a file containing protein degrees here.
## If chosen weighing scheme is 'maxsize', provide a maximum complex size here.
## For each protein pair in input 1, if both proteins are contained in gold standard, determines if the protein pair is a
## true or false positive (contained in at least one protein complex from input 2 together or not) and calculates the
## cumulative TP and FP count up to the current protein pair.
## Tab-separated output to stdout: protein1, protein2, protein pair score, TP (0/1, may be weighted), FP (0/1, may be weighted), cumulative TP count, cumulative FP count, label

## example call time python3 string_score_benchmark.1.1.py -i auto_blacklists_only/tagger-run-no-blacklist/database_pairs_no_blacklist_ggp_only_sorted.tsv -g benchmark_kegg_2col.tsv -o no_blacklist_ggp_only_out_benchmark_with_prec.tsv

from __future__ import division

import sys
import argparse
import gzip
import math
import warnings
import pprint

# Utilities #
#############

def debug(message):
	pass
#	print('DEBUG:', message)

def min_warn(message, category, filename, lineno, file=None, line=None):
	'''Format for less redundant custom warnings.'''
	return '%s: %s\n' % (category.__name__, message)

# apply minimal warnings format
warnings.formatwarning = min_warn

def open_gz_flex(filename):
	'''Determine if file is a gz file or not and open accordingly.'''
	if filename.endswith('.gz'):
		open_file = gzip.open(filename, 'rt')
	else:
		open_file = open(filename, 'r')
	return(open_file)

def convert_string_to_number(string):
	'''Convert string to integer if possible, otherwise to float. Pretty brute force, use with attention.'''
	try:
		return(int(string))
	except ValueError:
		return(float(string))

def setup_parser():
	parser = argparse.ArgumentParser(description = 'Benchmark a list of protein pairs ranked by score using a gold standard dataset.')
	parser.add_argument('-i', '--prot_pair_file', type = str, required = True, help = 'Tab-delimited file of protein pairs ranked from highest to lowest score (<taxid.STRING ID 1> <taxid.STRING ID 2> <score> <label>).')
	parser.add_argument('-g', '--gs_file', type = str, required = True, help = 'Gold standard dataset (tab-separated: group identifier, "|"-separated participants).')
	parser.add_argument('--header', action = 'store_true', help = 'Gold standard file has a header.')
	parser.add_argument('-w', '--weigh', choices = ['size', 'maxsize', 'degree', 'none'], default = 'none', help = 'Weighing scheme: Choose one of:\n"none" (naive TP and FP count),\n"maxsize" (complexes exceeding the maximum size are disregarded),\n"size" (counts are normalized by the number of possible pairs a protein can be part of in that complex),\n"degree" (counts are normalized by the product of the degree of both proteins in the pairs graph of the benchmark dataset).')
	parser.add_argument('-d', '--degree_file', type = str, required = False, help = 'File with protein degrees (tab-separated: <taxon.STRING_ID> <number of pairs involving taxon.STRING_ID>. Required if weigh = "degree".')
	parser.add_argument('-s', '--max_size', type = int, required = False, help = 'Maximum complex size. Required if weigh = "maxsize".')
	parser.add_argument('-o', '--output_file', nargs = '?', type = argparse.FileType('w'), default = sys.stdout, help = 'Optional output file name: Tab-delimited pairs file with cumulative TP and FP counts (<taxid.STRING ID 1> <taxid.STRING ID 2> <score> <TP (0/1, may be weighted)> <FP (0/1, may be weighted)> <cumulative TP count> <cumulative FP count> <label>).')
	return parser


# Dictionaries #
################

def fill_complex_protein_dict(cpx_id, string_ids, comp_prot_dict):
	'''Fill dictionary of the gold standard complexes and their protein participants, where key = Complex Portal ID and value = list of the STRING IDs of the contained proteins.'''
	comp_prot_dict[cpx_id] = string_ids
	return(comp_prot_dict)

def fill_protein_complex_dict(cpx_id, string_ids, prot_comp_dict):
	'''Fill dictionary of the individual proteins contained in the protein complex gold standard dataset and the complexes they are contained in.
	Output: gold standard dictionary where key = STRING ID, value = the set of complexes where this protein is contained.'''
	for string_id in string_ids:
		if string_id not in prot_comp_dict:
			# add STRING ID as key and initiate set of complex IDs
			prot_comp_dict[string_id] = set([cpx_id])
		else:
			# add complex ID to existing set
			prot_comp_dict[string_id].add(cpx_id)
	return(prot_comp_dict)

def build_gs_dicts(gs_file, delim = '\t', incol_delim = ' ', header = True, max_size = math.inf):
	'''Generate the dictionaries of the individual proteins contained in the protein complex gold standard dataset (Complex Portal) and the complexes they are contained in.
	If complex maximum size is applied, do not include complexes larger than <max_size>.
	Input: "delim"-delimited file with complex ids in 1st column and "incol_delim"-separated protein participants in 2nd column.
	Output: complex-proteins-dictionary, protein-complexes-dictionary.'''
	comp_prot_dict = {}
	prot_comp_dict = {}
	with open(gs_file, 'r') as gs_f:
		if header:
			# skip header
			next(gs_f)
		for line in gs_f:
			# extract complex ID and STRING IDs
			(cpx_id, string_id_string) = line.rstrip('\n').split(delim)
			string_ids = string_id_string.split(incol_delim)
			if len(string_ids) <= max_size:
				comp_prot_dict = fill_complex_protein_dict(cpx_id, string_ids, comp_prot_dict)
				prot_comp_dict = fill_protein_complex_dict(cpx_id, string_ids, prot_comp_dict)
	return(comp_prot_dict, prot_comp_dict)

def build_simple_key_val_dict(file, sep = '\t'):
	'''Generate a dictionary from a 2-column file with unique keys in the 1st and values in the second column.'''
	simple_dict = {}
	with open(degree_file, 'r') as deg_f:
		for line in deg_f:
			(key, value) = line.rstrip('\n').split(sep)
			simple_dict[key] = value
	return(simple_dict)

# TP and FP counts #
####################

def get_cum_counts(pair_vals):
	'''Retrieve state of tp and fp counters from 5th and 6th column of a matrix of protein pairs and their values (pair_vals).'''
	if len(pair_vals) > 0:
		tp_cum = pair_vals[-1][5]
		fp_cum = pair_vals[-1][6]
	else:
		tp_cum = 0
		fp_cum = 0
	return(tp_cum, fp_cum)

def find_complex_size_min(cpx_ids, comp_prot_dict):
	'''From a set of list of complex IDs, find the smallest complex and return its size.'''
	lengths = []
	for i in cpx_ids:
		proteins = comp_prot_dict[i]
		lengths += [len(proteins)]
		min_compl_size = min(lengths)
	return(min_compl_size)

def weigh_by_degree(tp, fp, p1, p2, degree_dict):
	'''Weigh a true or false positive protein pair count by the geometric mean of the degrees of the proteins in the graph of pairs.'''
	p1_degree = int(degree_dict[p1])
	p2_degree = int(degree_dict[p2])
	tp_weighted = tp / math.sqrt(p1_degree * p2_degree)
	fp_weighted = fp / math.sqrt(p1_degree * p2_degree)
	return(tp_weighted, fp_weighted)

def weigh_by_size(tp, fp, complexes, comp_prot_dict):
	'''Weigh a true or false positive protein pair count by (n-1), where n is the complex size.
	If a protein is part of multiple complexes, choose smallest complex size.
	Expects that complexes is a list of complex IDs for a TP pair and a list of two lists, one for each protein, for a FP pair.'''
	if tp == 1:
		# weigh TP by complex size - 1
		# if more than one complex, use smallest
		n = find_complex_size_min(complexes, comp_prot_dict)
		tp_weighted = tp / (n-1)
		fp_weighted = fp
	elif fp == 1:
		# weigh FP by squre root of product of both (smallest) complexes
		(p1_complexes, p2_complexes) = complexes
		n1 = find_complex_size_min(p1_complexes, comp_prot_dict)
		n2 = find_complex_size_min(p2_complexes, comp_prot_dict)
		fp_weighted = fp / math.sqrt( (n1-1) * (n2-1) )
		tp_weighted = tp
	return(tp_weighted, fp_weighted)

def determine_positives(p1, p2, prot_comp_dict, comp_prot_dict, weigh, degree_dict = None):
	'''Check if proteins p1 and p2 are together in at least one complex according to gold standard dictionary of protein complexes (prot_comp_dict).
	If so, count as true positive, otherwise as false positive, and return both (0/1).'''
	p1_complexes = prot_comp_dict[p1]
	p2_complexes = prot_comp_dict[p2]
	intersect = p1_complexes.intersection(p2_complexes)

	if len(intersect) > 0:
		tp = 1
		fp = 0
		complexes = intersect
	else:
		tp = 0
		fp = 1
		complexes = [p1_complexes, p2_complexes]

	if weigh == 'size':
		return(weigh_by_size(tp, fp, complexes, comp_prot_dict))
	elif weigh == 'degree':
		return(weigh_by_degree(tp, fp, p1, p2, degree_dict))
	elif weigh == 'none' or weigh == 'maxsize':
		return(tp, fp)


# MAIN #
########

if __name__ == '__main__':

	# handle parameters
	parser = setup_parser()
	args = parser.parse_args()
	gs_file = args.gs_file
	header = args.header
	weigh = args.weigh
	if weigh == 'degree':
		try:
			degree_file = args.degree_file
		except:
			sys.exit('Chosen weighing scheme "degree" requires a degrees file (-d file)! Exiting.')
		# generate dictionary of gold standard proteins and their degree in the pair-graph
		degree_dict = build_simple_key_val_dict(degree_file)
	else:
		degree_dict = None
	if weigh == 'maxsize':
		try:
			max_size = args.max_size
		except:
			sys.exit('Chosen weighing scheme "maxsize" requires a maximum complex size as 4th argument! Exiting.')
	else:
		max_size = math.inf
				
	output = []
	
	# build dict of gold standard complexes and their proteins (STRING IDs)
	(comp_prot_dict, prot_comp_dict) = build_gs_dicts(gs_file, max_size = max_size, header = header)
	all_positives=len(prot_comp_dict)
	# read file of protein pairs ranked according to their scores
	with open_gz_flex(args.prot_pair_file) as pair_f:	
		for pair_line in pair_f:
			(p1, p2, score, label) = pair_line.strip('\n').split()
			# check if both proteins are contained in the gold standard 
			if p1 in prot_comp_dict and p2 in prot_comp_dict:
				# determine if true or false positive, increase cumulative counts and construct output line
				(tp, fp) = determine_positives(p1, p2, prot_comp_dict, comp_prot_dict, weigh, degree_dict)
				tp_cum, fp_cum = get_cum_counts(output)
				tp_cum += tp
				fp_cum += fp
				fn_cum = all_positives-tp_cum
				score_num = convert_string_to_number(score)
				precision = tp_cum/(tp_cum+fp_cum)
				recall = tp_cum/(tp_cum+fn_cum)
				#f1_score = (2*float(precision)*float(recall))/(float(precision)+float(recall))
				output += [[p1, p2, score_num, tp, fp, tp_cum, fp_cum, precision, fn_cum, recall,  label]]
	# print data to stdout or file
	output = [['protein1', 'protein2', 'score', 'tp', 'fp', 'tp_cum', 'fp_cum', 'precision', 'fn_cum', 'recall',  'label']] + output
	with args.output_file as out_f:
		for line in output:
			#print(*line, sep = '\t')
			outline = '\t'.join(map(str, line)) + '\n'
			out_f.write(outline)
		
