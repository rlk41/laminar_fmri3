#!/usr/bin/env python

from ctypes import c_char
import os
from numpy.lib.function_base import corrcoef
import argparse
import numpy as np
import matplotlib.pyplot as plt
import pylab
import nibabel as nib 
import pickle 

from nilearn import plotting


"""




"""

def plot_me(path_input, roi, layers): 
    
    
    
    
    
    
    
    
    
    return 
    


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    # parser.add_argument('--l1', type=str, default=None)
    # parser.add_argument('--l2', type=str)
    # parser.add_argument('--l3', type=str)
    # parser.add_argument('--l4', type=str)
    # parser.add_argument('--l5', type=str)
    # parser.add_argument('--l6', type=str)

    # parser.add_argument('--n1', type=str)
    # parser.add_argument('--n2', type=str)
    # parser.add_argument('--n3', type=str)
    # parser.add_argument('--n4', type=str)
    # parser.add_argument('--n5', type=str)
    # parser.add_argument('--n6', type=str)
    parser.add_argument('--l1', nargs='+')
    parser.add_argument('--l2', nargs='+')
    parser.add_argument('--l3', nargs='+')
    parser.add_argument('--l4', nargs='+')
    parser.add_argument('--l5', nargs='+')
    parser.add_argument('--l6', nargs='+')

    parser.add_argument('--n1', nargs='+')
    parser.add_argument('--n2', nargs='+')
    parser.add_argument('--n3', nargs='+')
    parser.add_argument('--n4', nargs='+')
    parser.add_argument('--n5', nargs='+')
    parser.add_argument('--n6', nargs='+')
    
    
    parser.add_argument('--parc', type=str)
    parser.add_argument('--roi', type=str)
    parser.add_argument('--layers', type=str)
    parser.add_argument('--columns', type=str)
    parser.add_argument('--roiXlayers', type=str)
    
    parser.add_argument('--id', type=int)
    parser.add_argument('--prefix', type=str)
    parser.add_argument('--title', type=str)
    parser.add_argument('--zstat', type=float, default=None)



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

    l1=[
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//120/172/84/sub-02_ses-07_task-movie_run-01_VASO_spc/120_172_84_CORR.nii.gz",
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/168/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_168_84_CORR.nii.gz", 
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/169/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_169_84_CORR.nii.gz", 
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/170/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_170_84_CORR.nii.gz", 
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/171/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_171_84_CORR.nii.gz", 
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/172/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_172_84_CORR.nii.gz"
    ]
    n1=[
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/172/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_172_84-rotate0063_CORR.nii.gz",
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/172/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_172_84-rotate0077_CORR.nii.gz", 
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/172/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_172_84-rotate0116_CORR.nii.gz", 
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/172/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_172_84-rotate0143_CORR.nii.gz", 
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/172/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_172_84-rotate0145_CORR.nii.gz", 
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/172/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_172_84-rotate0161_CORR.nii.gz", 
        "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/sub-02_ses-07_task-movie_run-01_VASO_spc//121/172/84/sub-02_ses-07_task-movie_run-01_VASO_spc/121_172_84-rotate0179_CORR.nii.gz",
        
    ]
    path_roiXlayers="/data/NIMH_scratch/kleinrl/shared/hierClust/rois/1047.L_7PC_layers.nii.gz"
    
    prefix="/data/NIMH_scratch/kleinrl/shared/characterize_VASO/voxwise_ANTDLPFC-to-L_7PC.png"
    title="L_46 (AntDLPFC) to L_7PL (PostParietal) \n(voxelwise, circShuffle Nulls)"
    zstat=2.0
    """


    args = parser.parse_args()

    l1 = args.l1 
    l2 = args.l2
    l3 = args.l3 
    l4 = args.l4 
    l5 = args.l5 
    l6 = args.l6 
    
    n1 = args.n1 
    n2 = args.n2
    n3 = args.n3 
    n4 = args.n4 
    n5 = args.n5 
    n6 = args.n6 
    
    
    path_roi                = args.roi
    path_layers             = args.layers 
    path_columns            = args.columns
    path_roiXlayers         = args.roiXlayers 
    
    path_parc               = args.parc
    ind                     = args.id

    prefix                  = args.prefix 
    title                   = args.title 
    
    zstat                   = args.zstat 

    print(l1)
    
    print(n1)
    

    
    def extract_vals(l1, roi_inds, zstat=None): 

        l1_vals = np.zeros(shape=(len(l1), len(roi_inds)))
        
        for i_l in range(len(l1)): 
            for i_ind in range(len(roi_inds)):
                
                epi = l1[i_l]
                epi_img = nib.load(epi) 
                epi_data = epi_img.get_fdata() 
                
                if zstat != None: 
                    
                    mu = np.mean(epi_data)
                    sd = np.std(epi_data)
                    
                    zstat_data = (epi_data - mu)/sd
                    
                    if zstat > 0: 
                        zstat_data[zstat_data < zstat] = np.nan
                    
                    elif zstat < 0: 
                        zstat_data[zstat_data > zstat] = np.nan 
                        
                    
                    #print("get better way to get zstat")

                ind = roi_inds[i_ind]
                
                vals = epi_data[ind]
                
                l1_vals[i_l, i_ind] = np.nanmean(vals)
        
        return l1_vals




    
    def plot_layer(l1_vals, color='red', a1=0.3, a2=0.2, label=""):
        
        mean    = np.mean(l1_vals, axis=0)
        sd      = np.std(l1_vals, axis=0)
        
        plt.plot(range(l1_vals.shape[1]), mean, color=color, alpha=a1, label=label)
        plt.fill_between(range(l1_vals.shape[1]), mean+sd, mean-sd, color=color, alpha=a2)
    
    
    
    
    
    
    roi_img = nib.load(path_roiXlayers)
    roi_data = roi_img.get_fdata() 
    
    unq = [ u for u in np.unique(roi_data) if u != 0 ]
    
    roi_inds = [ roi_data == u for u in unq ]
    
    l1_vals = extract_vals(l1, roi_inds, zstat=zstat) 
    
    n1_vals = extract_vals(n1, roi_inds, zstat=zstat) 

    plot_layer(l1_vals, color='red', label="EMPs ({})".format(len(l1)))
    
    plot_layer(n1_vals, color='blue', label="NULLs ({})".format(len(n1)))

    plt.legend()
    
    plt.ylabel( "r")

    plt.xticks([0, (l1_vals.shape[1]-1)/2, l1_vals.shape[1]-1], ['WM','<-->','CSF'])
    
    if title: 
        plt.title(title)
        
    plt.savefig(prefix)

    plt.close() 
    
    







    # to_plot = [] 
    
    # for e in epis: 
    #     layer = []
    #     layer = np.empty(shape=(len_unique_layers))
        
    #     for i in range(len(inds_layers)): 
    #         roi = inds_layers[i]
            
    #         #print(e)

    #         img_epi             = nib.load(e)
    #         data_epi            = img_epi.get_fdata() 
    #         vals                = data_epi[roi[0], roi[1], roi[2]]
    #         vals                = np.mean(vals) 
    
    #         #layer.append(vals)
    #         layer[i] = vals 
            
    #     to_plot.append(layer)
    
    
    # to_plot = np.stack(to_plot)
    
    # print(to_plot)
    
    # plt.figure() 
    # for i in range(to_plot.shape[0]): 
    #     p = to_plot[i,:]
        
    #     plt.plot(range(0,len(p)), p, label=labels[i])
    
    # #plt.show()    
    
    # plt.legend()
    
    # plt.xticks([0, (len(p)-1)/2, len(p)-1], ['WM','<-->','CSF'])
    # plt.title(title)
    
    
    # plt.savefig(prefix)
    # plt.close() 
    
    
    
    # # to_plot_ corr mat 
    
    
    # len_to_plot = len(to_plot) 
    # o = np.empty(shape=(len_to_plot, len_to_plot))
    # for x in range(len_to_plot):
    #     for y in range(len_to_plot):
    #         o[x,y] = np.corrcoef(to_plot[x], to_plot[y])[0,1]
            
    
    # plt.figure() 
    # plt.imshow(o)
    
    # mean = np.mean(o[np.triu_indices(len_to_plot, k=1)])
    

    
    # title_corrMat = title+" (mean_corrs={})".format(mean)
    # prefix_corrMat = prefix.rstrip('plot.png')+"corrMat.png"
    
    
    # plt.title(title_corrMat)

    # plt.savefig(prefix_corrMat)
    # plt.close() 
        
        
        
        
    
        
    # #plot_me()
    
    
    
    
        # # deal with list of epis 
    # epis    = [ l1, l2, l3, l4, l5, l6]    
    # epis    = [ e for e in epis if e != None ]
    
    # labels  = [ n1, n2, n3, n4, n5, n6]
    # labels  = [ n for n in labels if n != None ]
    
    # print("path_parc: {}".format(path_parc))
    # print("epis: {}".format(epis))
    # print("ind: {}".format(ind))
    # print("   ")
    



    # if parc_path
    # img_parc            = nib.load(path_parc)
    # data_parc           = img_parc.get_fdata() 
    

    
    # ind_parc            = data_parc == ind
    
    # img_layers          = nib.load(path_layers)
    # data_layers         = img_layers.get_fdata() 
    
    # unique_layers       = [ u for u in np.unique(data_layers) if u != 0]
    # len_unique_layers    = len(unique_layers)
    
    # #ind_layers          = [ u == data_layers for u in unique_layers ]

    # #ind_roi_by_layer = [ ind_parc == i for i in ind_layers ]


    # inds_layers = [] 
    # for u in unique_layers: 
    #     inds_layers.append(np.where( (data_layers == u) & (data_parc == ind )))