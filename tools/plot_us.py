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


def plot_me(path_input, roi, layers): 
    
    
    
    
    
    
    
    
    
    return 
    


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--l1', type=str, default=None)
    parser.add_argument('--l2', type=str)
    parser.add_argument('--l3', type=str)
    parser.add_argument('--l4', type=str)
    parser.add_argument('--l5', type=str)
    parser.add_argument('--l6', type=str)

    parser.add_argument('--n1', type=str)
    parser.add_argument('--n2', type=str)
    parser.add_argument('--n3', type=str)
    parser.add_argument('--n4', type=str)
    parser.add_argument('--n5', type=str)
    parser.add_argument('--n6', type=str)

    parser.add_argument('--parc', type=str)
    parser.add_argument('--roi', type=str)
    parser.add_argument('--layers', type=str)
    parser.add_argument('--columns', type=str)
    parser.add_argument('--roiXlayers', type=str)
    
    parser.add_argument('--id', type=int)
    parser.add_argument('--prefix', type=str)
    parser.add_argument('--title', type=str)
    


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
    title                  = args.title 
    

    

    # deal with list of epis 
    epis    = [ l1, l2, l3, l4, l5, l6]    
    epis    = [ e for e in epis if e != None ]
    
    labels  = [ n1, n2, n3, n4, n5, n6]
    labels  = [ n for n in labels if n != None ]
    
    print("path_parc: {}".format(path_parc))
    print("epis: {}".format(epis))
    print("ind: {}".format(ind))
    print("   ")
    




    img_parc            = nib.load(path_parc)
    data_parc           = img_parc.get_fdata() 
    
    unique_parcs        = [ u for u in np.unique(data_parc) if u != 0]
    len_unique_parcs    = len(unique_parcs)
    
    
    ind_parc            = data_parc == ind
    
    img_layers          = nib.load(path_layers)
    data_layers         = img_layers.get_fdata() 
    
    unique_layers       = [ u for u in np.unique(data_layers) if u != 0]
    len_unique_layers    = len(unique_layers)
    
    #ind_layers          = [ u == data_layers for u in unique_layers ]

    #ind_roi_by_layer = [ ind_parc == i for i in ind_layers ]



    epis.sort()
    
    data_epis = [] 
    for e in epis: 
        img_epi             = nib.load(e)
        data_epi            = img_epi.get_fdata() 
        data_epis.append(data_epi)
        
        
    
    

    to_plot = [] 
    
    ind_epi1 = np.where(data_epis[0] != 0 )
    involved_columns = data_parc[ind_epi1[0], ind_epi1[1], ind_epi1[2]]
    unique_involved_columns = np.unique(involved_columns)
    
    data_out_values = [] 
    data_out = np.zeros(shape=(data_layers.shape))


    print("unq_inv_col: {}".format(unique_involved_columns))
    
    
    for unq_col in unique_involved_columns: 
        ind_col = data_parc == unq_col 
        #print("sum ind_col: {}".format(np.sum(ind_col)))
            
        inds_layers = [] 
        for u in unique_layers: 
            inds_layers.append(np.where( (data_layers == u) & (ind_col )))
            
        to_plot = []
        for e in data_epis: 
            #layer = []
            layer = np.zeros(shape=(len_unique_layers))
            
            for i in range(len(inds_layers)): 
                roi                 = inds_layers[i]
                voxs                = e[roi[0], roi[1], roi[2]]
                m                   = np.mean(voxs) 
                layer[i]            = m 
                
            to_plot.append(layer)
            #print(layer)
            
        to_plot_np = np.stack(to_plot)
        
        
        # plot figure     
        #print(to_plot_np)
        plt.figure() 
        for i in range(to_plot_np.shape[0]): 
            p = to_plot_np[i,:]
            plt.plot(range(0,len(p)), p, label=labels[i])
        plt.legend()
        plt.xticks([0, (len(p)-1)/2, len(p)-1], ['WM','<-->','CSF'])
        plt.title("unq_col: {}".format(unq_col))
        prefix_plot=prefix.rstrip('corrVals.nii')+"{}_corrVals_plot.png".format(int(unq_col))
        plt.savefig(prefix_plot)
        plt.close() 
        
    
        
        
        

        #len_to_plot = len(to_plot) 
        len_to_plot = to_plot_np.shape[0]
        o = np.zeros(shape=(len_to_plot, len_to_plot))
        for x in range(len_to_plot):
            for y in range(len_to_plot):
                o[x,y] = np.corrcoef(to_plot_np[x,:], to_plot_np[y,:])[0,1]
                
    
        mean = np.mean(o[np.triu_indices(len_to_plot, k=1)])
        slope = (o[0,-1] - o[0,1])/2 
        
        print("mean: {}".format(mean))
        print("corrs: {}".format(o[0,1:]))
        print("slope: {}".format(slope))
        print("o2, o1: {} {}".format(o[0,-1],  o[0,1]))
        
        data_out[ind_col] = slope
        data_out_values.append(mean)
        
        
        
            
    clipped_img = nib.Nifti1Image(data_out, img_layers.affine, img_layers.header)
    
    outfile = prefix.rstrip("plot.png")+"corrVals_slope.nii"
    nib.save(clipped_img, outfile)
    
    print("outfile: {}".format(outfile) )
        
        
        
        
        
        
    
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