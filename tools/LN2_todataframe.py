#!/usr/bin/env python3

import os
from numpy.lib.function_base import corrcoef
import argparse
import numpy as np
import matplotlib.pyplot as plt
import pylab
import scipy.cluster.hierarchy as sch
import nibabel as nib 
from nilearn.input_data import NiftiLabelsMasker
import pickle 

import time




if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--input', type=str)

    parser.add_argument('--columns', type=str)
    parser.add_argument('--layers', type=str)

    parser.add_argument('--output', type=str)
    args = parser.parse_args()

    path_input      = args.input

    path_columns    = args.columns
    path_layers     = args.layers

    path_output     = args.output 

    '''
    path_input      = "/data/NIMH_scratch/kleinrl/analyses/FEF/1010.L_FEF_pca10/mean/inv_thresh_zstat1.fwhm8.nii.gz"
    path_input      = "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.nii.gz"

    path_columns    = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii"
    path_layers     = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii"

    path_input="/data/NIMH_scratch/kleinrl/analyses/wb3/LANG_pca5_fslmask_AVE/fsl_feat_1140.L_TPOJ2_pca10/mean/thresh_zstat1.fwhm5.nii.gz" 
    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/warped_hcp-mmp-b_rmap.nii" 
    path_layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"


    path_input="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5//corrs/8109.lh.LGN.2D.mean.perm/8109.lh.LGN.2D.mean.perm-batch20_iter8.nii.gz"
    path_columns="/data/NIMH_scratch/kleinrl/gdown/parc_hcp_kenshu_uthr.nii.gz"
    path_layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"
    path_output="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5//dataframes"
    
    
    
    
    path_layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"
    path_columns="/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/rois/rois/parc_hcp_kenshu.nii.gz"
    path_input="/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc/121/158/85/sub-02_ses-07_task-movie_run-01_VASO_spc/121_158_85_CORR.nii.gz"


    '''

    print("path_input:   "    + path_input)
    print("path_columns: "  + path_columns)
    print("path_layers:  "   + path_layers)
    print()

    start = time.time()
    print(start)


    img_input           = nib.load(path_input)
    data_input          = img_input.get_fdata()

    img_columns         = nib.load(path_columns)
    data_columns        = img_columns.get_fdata().astype(int)

    img_layers          = nib.load(path_layers)
    data_layers         = img_layers.get_fdata().astype(int)


    unq_cols    = np.unique(data_columns)[1:]
    unq_layers  = np.unique(data_layers)[1:]

    out_shape = data_input.shape

    unq_layers_flip = np.flip(unq_layers)

    dimx, dimy, dimz = data_input.shape

    sums    = np.zeros(shape=(unq_cols[-1]+1, unq_layers[-1]+1))
    #means   = np.zeros(shape=(unq_cols[-1]+1, unq_layers[-1]+1))
    counts  = np.zeros(shape=(unq_cols[-1]+1, unq_layers[-1]+1))



    for x in range(dimx): 
        for y in range(dimy): 
            for z in range(dimz): 
                vox_data    = data_input[x,y,z]
                vox_lay     = data_layers[x,y,z]
                vox_col     = data_columns[x,y,z]
                if (vox_lay != 0) and (vox_col != 0 ) and (vox_data != 0 ): 
                    sums[vox_col, vox_lay] += vox_data
                    counts[vox_col, vox_lay] += 1

    #means = sums/counts
    #means = np.divide(sums, counts)
    means = np.divide(sums, counts, out=np.zeros_like(sums), where=counts!=0)


    base_path   = path_input.rstrip(".nii.gz")
    base_col    = path_columns.rstrip(".nii.gz").split('/')[-1]
    base_layers = path_layers.rstrip(".nii.gz").split('/')[-1]

    if path_output:
        base = path_input.rstrip(".nii.gz").split('/')[-1]
        base_path = path_output + '/'+ base 

    out_file="{}-{}-{}-means.npy".format(base_path, base_layers, base_col)
    np.save(out_file, means, 
                allow_pickle=True, fix_imports=True)





"""
LN2_todataframe.py \
--input "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/fsl_feat_2170.R_p10p_pca10_ALL/mean/inv_pe1.fwhm3.nii.gz" \
--columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii" \
--layers "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" 

LN2_todataframe.py \
--input "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/fsl_feat_2170.R_p10p_pca10_ALL/mean/inv_pe1.fwhm3.nii.gz" \
--columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b.nii.gz" \
--layers "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" 




"""

