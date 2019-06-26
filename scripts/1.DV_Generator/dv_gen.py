#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import time
import random
import datatable as dt
import pandas as pd
import numpy as np

def genom_multilat(n=2000, k=50, urdata="../../sample_data/mydata", refdata="", refmaf=""):
	# Import Data (Reference / Your own parsed data)
	print(" Import Reference Data.")

	if len(refdata) == 0:
		DT = dt.fread("../../Reference/1000G_Phase3.ref").to_pandas()

	else:
		DT = dt.fread(refdata).to_pandas()
	
	print(" ------------ Complete.")

	print(" Import Your Data.")
	DT2 = dt.fread("{}.input".format(urdata)).to_pandas()
	print(" ------------ Complete.")

	print(" Import reference p vector.")
	
	if len(refdata) == 0:
		maf = dt.fread("../../Reference/1000G_Phase3.ref.p").to_pandas()
	else:
		maf = dt.fread(refmaf).to_pandas()
	print(" ------------ Complete.")

	print("\n")
	print(" - Reference matrix dimension : {}".format(DT.shape))
	print(" - Your data dimension : {}".format(DT2.shape))
	#print(maf.shape)

	concat = pd.concat([DT, DT2], join='inner')
	concat = pd.concat([concat, maf], join = 'inner')

	#print(concat)
	#print(concat.shape)

	print("  - Reference and your data intersection variants count : {}".format(len(concat.columns)))

	if len(refdata) == 0:
		concat = concat[concat.columns.to_series().sample(n)]	# loci sampling by # of n
	
	ref = concat.iloc[:len(DT)]
	my = concat.iloc[len(DT):-1]
	maf = concat.iloc[-1]


	# K Reference Sampling
	if len(refdata) == 0:
		ref = ref.sample(k)					# references sampling by # of k
	ref.reset_index(drop=True, inplace=True)
	my.reset_index(drop=True, inplace=True)
	my = my.fillna(random.randrange(0,2))

	print(" - After K x N filtering Reference dimension : {}".format(ref.shape))
	print(" - After N filtering your data dimension : {}".format(my.shape))

	# my.to_csv("{}.gen".format(urdata), sep=" ", header = True, index = False) # You can get the genotype file from sampled your data
	
	# Convert Numpy
	col_val = list(ref.columns.values)
	ref = ref.values
	my = my.values

	# Euclidean Distance
	result_array = np.empty((0, len(ref)))
	start = time. time()
	for i in range(len(my)):
		ind = my[i]
		result = np.sum(np.square(ref-ind),axis=1)

		result_array = np.append(result_array,[result], axis=0)
	end = time. time()

	print("\n")
	print(" * Your Distance vector matrix : ")
	print(pd.DataFrame(result_array))
	print(" * Processing Time : {}".format(end - start))

	if len(refdata) == 0:
		print(" Your reference is writing...\n")
		ref = pd.DataFrame(ref, dtype = int)
		ref.columns = col_val
		maf = pd.DataFrame(maf).T
		ref.to_csv("{}.ref".format(urdata), sep=" ", header = True, index = False)
		maf.to_csv("{}.ref.p".format(urdata), sep=" ", header = True, index = False)

	return(pd.DataFrame(result_array))

# genom multilat module run as the main program.
if __name__ == '__main__':
	if 1 < len(sys.argv) < 5:
		result = genom_multilat(n=int(sys.argv[1]), k=int(sys.argv[2]), urdata=sys.argv[3])
		print(" Your output is writing...\n")
		result.to_csv("{}.out".format(sys.argv[3]), sep=" ",header = False , index = False)
		print(" Done.")

	elif len(sys.argv) > 4:
		result = genom_multilat(n=int(sys.argv[1]), k=int(sys.argv[2]), urdata=sys.argv[3], refdata=sys.argv[4], refmaf=sys.argv[5])
		print(" Your output is writing...\n")
		result.to_csv("{}.out".format(sys.argv[3]), sep=" ",header = False , index = False)
		print(" Done.")

	else:
		print(" You didn't pass the argument. We will use sample data")
		result = genom_multilat()
		print(" Your output is writing...\n")
		result.to_csv("../../sample_data/mydata1.out", sep=" ",header = False, index = False)
		print(" Done.")
