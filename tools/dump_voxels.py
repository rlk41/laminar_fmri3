#!/usr/bin/env python

import os
from glob import glob
import pandas as pd
import argparse
import numpy as np
import nibabel as nib 


def dump_voxels_as_1D(path_epi, path_roi): 
    img_epi         = nib.load(path_epi) 
    img_roi         = nib.load(path_roi)

    data_roi        = img_roi.get_fdata()
    data_epi        = img_epi.get_fdata()

    inds = np.array(np.where(data_roi == 1 ))

    for i in range(inds.shape[1]):
        x, y, z = inds[:,i]
        ts = data_epi[x,y,z]
        
        filename = "{}_{}_{}.1D".format(x,y,z)
        np.savetxt(filename, ts)
        
        mean = ''
        var = ''
        #mean    = np.mean(ts)
        #var     = np.var(ts)
        
        print("shape: {} mean: {} var: {} saved: {}".format(ts.shape, mean, var, filename))
        
        
        
        
        
if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--epi', type=str)
    parser.add_argument('--roi', type=str)
    args = parser.parse_args()


    path_epi        = args.epi
    path_roi        = args.roi


    '''
    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/warped_columns_ev_10000_borders.nii"
    path_layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/layers/warped_rim_equidist_n3_layers_equidist.nii"

    path_epi="/data/NIMH_scratch/kleinrl/shared/hierClust/data_VASO_maskSPC/sub-02_ses-07_task-movie_run-01_VASO_spc.nii"
    path_roi="/data/NIMH_scratch/kleinrl/gdown/rois_hcp_kenshu/1084.L_46.nii"
           
    '''


    dump_voxels_as_1D(path_epi, path_roi)
    
    
        