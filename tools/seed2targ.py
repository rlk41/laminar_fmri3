


#!/usr/bin/env python

import os
from glob import glob
import pandas as pd
import argparse
import numpy as np
import nibabel as nib 
import yaml 
from random import randint 
import sys
import subprocess 

import matplotlib.pyplot as plt
import scipy.cluster.hierarchy as sch
from scipy.cluster.hierarchy import cut_tree, fcluster, cophenet
import subprocess 



     
        
if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--config', type=str, default=None)
    
    parser.add_argument('--seed2targ_clust', type=str)
    parser.add_argument('--roi', type=str)
    parser.add_argument('--target', stype=str)
    parser.add_argument('--epi', stype=str)

    args = parser.parse_args()


    path_config         = args.config
    path_epi            = args.epi
    path_roi            = args.roi
    path_targ           = args.taregt 
    
    
    
    print("roi: {}".format(path_roi))
    
    
    epi='sub-02_ses-07_task-movie_run-01_VASO_spc'
    x, y, z = 121,158,85
    layers=""
    columns=""
    base_dir="/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/"
    path_epi=base_dir+os.sep+
    
    img_epi = nib.load(path_epi )
    img_data = img_epi.get_fdata() 
    
    