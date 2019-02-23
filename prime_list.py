#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
args = sys.argv
num = int(args[1])

for n in range(2, num):
    for x in range(2, n):
        if n % x == 0:
            print(n, 'equals', x, '*', n//x)
            break
    else:
        # loop fell through without finding a factor
        print(n, 'is a prime number')
