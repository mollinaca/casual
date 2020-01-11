#!/usr/bin/env python3
# -*- coding: utf-8 -*-
n = int(input())

def kaijo(n:int):
    if n == 1:
        return 1
    else:
        return n*kaijo(n-1)

print (int(kaijo(n)))