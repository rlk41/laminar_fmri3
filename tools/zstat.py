#!/usr/bin/env python

import os
import argparse
import numpy as np
import nibabel as nib 




if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='zstat')
    parser.add_argument('--epi', type=str, default=None)
    parser.add_argument('--sd', type=int)
    parser.add_argument('--mask', type=str, default=None)

    

    


    """

    path_parc="/data/NIMH_scratch/kleinrl/shared/collay_ratio/rois/columns/dwscaled_columns10000.nii"
    path_layers="/data/NIMH_scratch/kleinrl/shared/collay_ratio/rois/layers/sub-02_layers.nii"
    l1="/data/NIMH_scratch/kleinrl/shared/collay_ratio/analyses/sess07-run01_slice84_clustNum9/clust6_FWHM1.nii"
    l2="/data/NIMH_scratch/kleinrl/shared/collay_ratio/analyses/sess07-run01_slice84_clustNum9/clust6_FWHM2.nii"
    l3="/data/NIMH_scratch/kleinrl/shared/collay_ratio/analyses/sess07-run01_slice84_clustNum9/clust6_FWHM3.nii"
    l4="/data/NIMH_scratch/kleinrl/shared/collay_ratio/analyses/sess07-run01_slice84_clustNum9/clust6_FWHM4.nii"
    l5="/data/NIMH_scratch/kleinrl/shared/collay_ratio/analyses/sess07-run01_slice84_clustNum9/clust6_FWHM5.nii"
    l6=None 
    
    n1="FWHM1"
    n2="FWHM2"
    n3="FWHM3"
    n4="FWHM4"
    n5="FWHM5"
    n6=None
    id = ind =559
    prefix="/data/NIMH_scratch/kleinrl/shared/collay_ratio/analyses/sess07-run01_slice84_clustNum9/clust6_plot.png"


    """


    args    = parser.parse_args()
    
    path_epi     = args.epi 
    path_mask    = args.mask 
    sd      = args.sd 

    

    img_epi  = nib.load(path_epi)
    data_epi = img_epi.get_fdata() 
    
    
    
    if path_mask != None: 
        img_mask  = nib.load(path_mask)
        data_mask = img_epi.get_fdata() 
        
        bool_mask = data_mask != 0 
        
        
    
    
    