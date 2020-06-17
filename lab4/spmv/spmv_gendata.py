#!/usr/bin/env python

import sys
import random

m = int(sys.argv[1])
n = int(sys.argv[2])
approx_nnz = int(sys.argv[3])

pnnz = float(approx_nnz)/(m*n)
idx = list()
p = [0]

for i in range(m):
  for j in range(n):
    if random.random() < pnnz:
      idx.append(j)
  p.append(len(idx))

nnz = len(idx)
v = [random.randint(1, 1000) for i in range(n)]
d = [random.randint(1, 1000) for i in range(nnz)]

def print_arr(t, name, data):
    print "const {} {}[{}] = ".format(t, name, len(data))
    print "{"
    print ", ".join(map(str, data))
    print "};"

def spmv(p, d, idx, v):
    y = list()
    for i in range(len(p)-1):
      yi = 0
      for k in range(p[i], p[i+1]):
        yi += d[k] * v[idx[k]]
      y.append(yi)
    return y

print "#define R ", m
print "#define C ", n
print "#define NNZ ", nnz
print_arr("double", "val", d)
print_arr("int", "idx", idx)
print_arr("double", "x", v)
print_arr("int", "ptr", p)
print_arr("double", "verify_data", spmv(p, d, idx, v))
