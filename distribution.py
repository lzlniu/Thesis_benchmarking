import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import colors
from matplotlib.ticker import PercentFormatter

my_input_filename=sys.argv[1]

def read_doc(infile):
	df=pd.read_csv(infile, header=None, sep='\t')
	return df.iloc[:,1] #.sort_values()

def get_dist(infile, dist_range=None):
	array=read_doc(infile)
	print(array)
	#for i in range(len(df)):
	#	if (df[i]>50.0):
	#		print(df[i])
		

get_dist(my_input_filename)
