#!/usr/bin/env python

import os
import argparse
import numpy as np
from random import randint 


def rotate_1D(path_1D, num):

    d = np.loadtxt(path_1D)
    o = np.zeros(shape=d.shape)

    dimx = d.shape[0]


    for i in range(num): 
        r = randint(0, dimx)
        o = np.concatenate((d[r:], d[:r]), axis=0)

        filename="{}-rotate{}.1D".format(path_1D.rstrip('.1D'), str(r).zfill(4))
        print(filename, o.shape ) 
        
        
        np.savetxt(filename, o, fmt='%.6f')




if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--ts', type=str)
    parser.add_argument('--num', type=int)

    args = parser.parse_args()


    path_1D         = args.ts
    num             = args.num 

    """
    path_1D="/data/NIMH_scratch/kleinrl/shared/laminar_connectivity/data/timecourses/120_151_70.1D"
    num=10
    
    """
    
    rotate_1D(path_1D, num)