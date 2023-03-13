#!/usr/bin/env python


import argparse
import numpy as np
from random import randint





if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--input', type=str)
    parser.add_argument('--mean', type=bool)

    args = parser.parse_args()

    path_input      = args.input
    #do_mean         = args.mean


    '''
    path_input      = "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/fsl_feat_1010.L_FEF_pca10_ALL/timeseries/DAY2_run3_VASO_LN.2D"
    path_input = "/data/NIMH_scratch/kleinrl/analyses/wb3/L_45_PERMUTE_FSLFEAT/fsl_feat_1075.L_45_pca10/timeseries/ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-09_task-movie_run-01_VASO.2D"
    do_mean = True 
    '''

    d = np.loadtxt(path_input)
    o = np.zeros(shape=d.shape)

    dimx, dimy = d.shape 

    for dx in range(dimx): 
        r = randint(0, dimy)
        o[dx,:] = np.concatenate((d[dx, r:], d[dx, :r]), axis=0)

    np.savetxt(path_input+".perm", o, fmt='%.6f')
    
    o_mean = o.mean(axis=0)

    np.savetxt(path_input+".mean.perm", o_mean, fmt='%.6f')



'''
2D_rotate_timeseries.py --input /data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/fsl_feat_1010.L_FEF_pca10_ALL/DAY2_run3_VASO_LN.2D

2D_rotate_timeseries.py --input /data/NIMH_scratch/kleinrl/analyses/wb3/L_45_PERMUTE_FSLFEAT/fsl_feat_1075.L_45_pca10/timeseries/ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-09_task-movie_run-01_VASO.2D
'''