#!/usr/bin/env python

import os 
import argparse
from re import L
import numpy as np
import matplotlib.pyplot as plt
import nibabel as nib 
import matplotlib.pyplot as plt 
import pandas as pd 

import glob 
import scipy 
import scipy.stats 

from matplotlib.pylab import plot, boxplot, show, savefig, xlim, figure, \
                ylim, legend, setp, axes




def get_rois(k, out): 


    # k='L_FEF'
    
    LUT="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/HCPMMP1_LUT_ordered_RS.txt"

    lut = pd.read_csv(LUT, delimiter=' ')

    print('load lut')


    k_id = int(lut[lut['Lookup'] == k]['#'].values[0])

    print("K: {}, K_ID: {}".format(k, k_id))

    # columns             = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii"
    # parc                = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b_rmap.scaled2x.nii.gz"
    # layers              = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii"

    columns             = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/warped_columns_ev_30000_borders.nii"
    parc                = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/warped_hcp-mmp-b_rmap.nii"
    layers              = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/warped_equi_volume_layers_n10.nii"
    
    # if nulls == None: 
    #     nulls_3d            = glob.glob(base_dir+"/fsl_feat_*NULL*/mean/{}.fwhm{}.nii.gz".format(file_type, fwhm)) #fwhm7.L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz")
    # elif nulls != None: 
    #     nulls_3d            = nulls 
    # else: 
    #     print("something wrong with nulls ")


    # feat_3d             = glob.glob(base_dir+"/fsl_feat_1010.L_FEF_pca10/mean/{}.fwhm{}.nii.gz".format(file_type, fwhm)) #L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz")
    # feat_3d             = feat_3d[0]

    # seed                = feat_3d.split('/')[-3].split('.')[-1].rstrip('_pca10')
    target              = k 

    img_parc            = nib.load(parc)
    img_col             = nib.load(columns)
    img_lay             = nib.load(layers)

    data_parc           = img_parc.get_fdata()
    data_columns        = img_col.get_fdata()
    data_layers         = img_lay.get_fdata()

    ind_roi     = np.where(data_parc == k_id )

    unq_roi_col = np.unique(data_columns[ind_roi]) 
    unq_roi_col = [ uc for uc in unq_roi_col if uc != 0 ]

    unq_layers  = np.flip(np.unique(data_layers))[:-1]


    '''
    uc = unq_roi_col[0]
    lc = unq_layers[0]
    '''


    ind_boths = []

    for uc in unq_roi_col: 

        ind_col = data_columns == uc 

        for lg in [[2,3,4], [5,6],[7,8,9]]:

            ind_boths = [] 
            ind_lays = [] 

            for lc in lg: 
                ind_lay = data_layers == lc     #) or  (data_layers == lc) or (data_layers == lc)
                ind_lays.append(ind_lay)
            


            mask = [any(tup) for tup in zip(ind_lays)]



                ind_both = np.where( ind_lay & ind_col )

                ind_boths.append(ind_both)




if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--columns', type=str)
    parser.add_argument('--layers', type=str)
    parser.add_argument('--out', type=int)


    args = parser.parse_args()

    columns     = args.columns 
    layers      = args.layers
    out         = args.out



        

    get_rois(columns, layers, out)