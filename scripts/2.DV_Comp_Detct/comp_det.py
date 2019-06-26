#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import time
import random
import math
import scipy.stats as stats
import datatable as dt
import pandas as pd
import numpy as np
from numpy.linalg import inv
from scipy.stats import binom
from scipy.stats import chi2
from pip._internal import main

# Application 2 : Duplicate Detection
## Compare two distance vectors and Calculate our statistics

def dstvct_compare(data1, data2, refmaf, thresh=0):

	# data1 : your first distance vector file path and prefix
	# data2 : your second distance vector file path and prefix

	# Import Data (Reference / Your own parsed data)
	maf = dt.fread("{}".format(refmaf)).to_pandas() ## p is the population frequency of the non-reference allele from appl1. ".maf"
	df1 = dt.fread("{}".format(data1)).to_pandas()
	df2 = dt.fread("{}".format(data2)).to_pandas()

	print(" - Number of loci (snps) : {}".format(maf.shape[1]))
	print(" - Your First sample # x K dimension : {}".format(df1.shape)) # row : # of samples in study 1 | column : K(Satellite)
	print(" - Your Second sample # x K dimension : {}".format(df2.shape)) # row : # of samples in study 2 | column : K(Satellite)
	print("\n")

	if len(df1.columns) == len(df2.columns):
		print(" ------------------*******------------------ ")
		print(" Start Comparision and Detect Same Samples.")
		print("\n")

		n1 = len(df1.index)
		n2 = len(df2.index)
		k = len(df1.columns) # K(Satellite) ~Chisq degree of Freedom
		n = len(maf.columns)

		df1 = df1.values
		df2 = df2.values
		maf = maf.values.tolist()
		maf = maf[0]

		cov = np.zeros((k,k))

		print(" Covariance matrix is generating...")
		for i in range(k):
			for j in range(k):
				for l in range(n):
					if i != j:
						cov[i,j] += -8*math.pow(maf[l],4) + 16*math.pow(maf[l],3) - 12*math.pow(maf[l],2) + 4*maf[l] # non-diagonal
					else:
						cov[i,j] += 24*math.pow(maf[l],4) - 48*math.pow(maf[l],3) + 20*math.pow(maf[l],2) + 4*maf[l] # diagonal

		print(" Covariance matrix dimension : {}".format(cov.shape))
		pd.DataFrame(cov).to_csv("{}_{}comp_2data.sigma".format(data1.rsplit('.',1)[0],data2.rsplit('/', 1)[1]))

		stat_mt = np.zeros((n1,n2))
		pval_mt = np.zeros((n1,n2))
		cov = inv(cov)

		if thresh == 0:
			print("\n")
			print(" You didn't give the exact threshold.")
			print(" (Default) Threshold determining simulation is processing...")
			print("           It will take some times...")

			# (Default) Simultation for Multiple Testing Threshold
			def simul(n, k, B): # n : Nsnp ; k : Nsat ; B : NSimul
				sat = np.zeros((k, n)) # nrow=Nsat, ncol=Nsnp
				freq = np.random.uniform(0.05,0.95, n)
				for i in range(n):
					sat[:,i] = binom.rvs(2, freq[i], size=k)
				sigma = np.full((k, k), np.sum((-8*(freq)**4)+(16*(freq)**3)-(12*(freq)**2)+(4*freq)))
				np.fill_diagonal(sigma, np.sum((24*(freq)**4)-(48*(freq)**3)+(20*(freq)**2)+(4*freq)))
				sigma_inv = inv(sigma)

				null_stat = chi2.rvs(k, size=B)
				alt_stat = np.zeros(B)

				def statfunc(my,sat,sigma_inv):
					dist_vct1 = np.array([sum(sat[i]-my[0])**2 for i in range(k)])
					dist_vct2 = np.array([sum(sat[i]-my[1])**2 for i in range(k)])
					diff = (dist_vct1-dist_vct2)
					stat = np.dot(np.dot(diff, sigma_inv),diff)
					return(stat)

				def alt():
					my = np.zeros((2, n))
					for i in range(n):
						my[0,i]=binom.rvs(2, freq[i], size=1)
						my[1,i]=binom.rvs(2, freq[i], size=1)
						if np.random.uniform(0,1,1) > 0.01: # Genotyping error
							my[0,i] = my[1,i]
					alt_stat = statfunc(my,sat,sigma_inv)
					return(alt_stat)

				for i in range(B):
					alt_stat[i] = alt()

				startpoint = max([-log(1-chi2.sf(null_stat[i],k)) for i in range(B)])
				endpoint = min([-log(1-chi2.sf(alt_stat[i],k)) for i in range(B)])

				thres = 10**(-mean(startpoint,endpoint))

				return(thres)
			start = time. time()
			B = 10000 # You can change the number of simulations	
			thresh=simul(n,k,B)
			end = time. time()
			print(" * Your determined threshold : {}".format(thresh))
			print(" * Your Simulation for N, K, B, time : {}, {}, {}, {}".format(n, k, B, end-start))
			print("\n")

		start = time. time()
		# Generating statistics and p-value
		for i in range(n1):
			for j in range(n2):
				v1 = df1[i,:]
				v2 = df2[j,:]

				stat = np.dot(v1-v2,cov)
				stat = np.dot(stat,v1-v2)
				stat_mt[i,j] = stat
				
				pval = 1-chi2.sf(stat, k)
				pval_mt[i,j] = pval
		
				if pval < thresh :
					print("   - Indiv {} from data 1 ---- Indiv {} from data 2  | were collected from the same individual.".format(i,j))
		end = time. time()
		print("\n")
		print(" * Generating Statistics Processing Time : {}".format(end - start))

		print(" * Your statistic matrix : ")
		print(pd.DataFrame(stat_mt))

		print(" Your output is writing...\n")
		pd.DataFrame(stat_mt).to_csv("{}_{}comp_2data.stat".format(data1.rsplit('.',1)[0],data2.rsplit('/', 1)[1]))
		pd.DataFrame(pval_mt).to_csv("{}_{}comp_2data.pval".format(data1.rsplit('.',1)[0],data2.rsplit('/', 1)[1]))
	else:
		print(" Number of satellites(K) are different. Please check first before perform the comparision.")

# genom multilat module run as the main program.
if __name__ == '__main__':
	if len(sys.argv) == 4:
		dstvct_compare(sys.argv[1], sys.argv[2], sys.argv[3])
	else:
		dstvct_compare(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
