from pytictoc import TicToc
t = TicToc()
t.tic()
from numpy.random import *
import numpy as np

n = 1000

dup = 10**5

def rint(n1):
	return randint(0,n1,size=(dup))

nm = np.zeros((dup,n),dtype=int)
row_idxs = np.arange(len(nm))

for i in range(n):
	si = rint(i+1)
	# for j in range(dup):
	# 	nm[j,i] = nm[j,si[j]]
	# 	nm[j,si[j]] = i+1
	nm[:,i] = nm[row_idxs,si]
	nm[row_idxs, si] = i+1	

t.toc()
print(nm)
a=np.sum(nm,axis=0)/10**5
print(a)

import seaborn as sns
import matplotlib.pyplot as plt
sns.distplot(a)
plt.show()