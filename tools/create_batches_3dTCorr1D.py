#!/usr/bin/env python

import os
from glob import glob
import pandas as pd
import argparse
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity, cosine_distances, paired_cosine_distances
from scipy.special import betainc
import matplotlib.pyplot as plt
import scipy
import pylab
import scipy.cluster.hierarchy as sch
import nibabel as nib 
from multiprocessing import Pool 
from shutil import copyfile


def build_batch(path_epi, path_ts, swarm_dir): 
    
    
    
    batches = [] 

    batches.append(    "3dTCorr1D {} {} --prefix {}".format(path_epi, path_ts, swarm_dir))
        
    
    
    with open(swarm_dir, 'w') as fp:
        for item in batches:
            fp.write("%s\n" % item)
        print('Done')
        
    
    return 
    
    
    
if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--epi', type=str)
    parser.add_argument('--ts', type=str)
    parser.add_argument('--swarm_dir', type=str)

    args = parser.parse_args()

    path_epi                = args.epi
    path_ts                 = args.ts
    path_swarm_dir          = args.swarm_dir


    # path_epi="/data/NIMH_scratch/kleinrl/shared/hierClust/data_VASO_maskSPC/VASO_grandmean_WITHOUT-ses-13_spc.nii"
    
    # path_layers="/data/NIMH_scratch/kleinrl/shared/hierClust/rois/sub-02_layers.nii"
    
    # base_path="/data/NIMH_scratch/kleinrl/shared/hierClust/analysis_hubness/"

    # out_path=base_path+"/batches.sjobs"
    # vox_dir=base_path+"/voxels"
    
    '''
    path_corr="/data/NIMH_scratch/kleinrl/shared/hierClust/analysis_hubness/120_171_84/120_171_84_CORR_atan.nii.gz"
    '''


            

    build_batch(path_epi, path_ts, path_swarm_dir)
        


