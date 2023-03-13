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


def build_batch(data_layers, path_epi, base_dir, out_path): 
    img_layers      = nib.load(path_layers)

    data_layers     = img_layers.get_fdata()
    
    
    inds_layers = np.where(data_layers != 0 )
    
    base_dir="/data/NIMH_scratch/kleinrl/shared/hierClust/analysis_hubness/voxels"
    
    
    batches = [] 
    for i in range(len(inds_layers[0])): 
        
        x = inds_layers[0][i]
        y = inds_layers[1][i]
        z = inds_layers[2][i]

        batches.append("get_hubbiness_vector.sh {} {} {} {} {}".format(x,y,z,path_epi,base_dir))
        
    
    
    with open(out_path, 'w') as fp:
        for item in batches:
            fp.write("%s\n" % item)
        print('Done')
        
    
    return 
    
    
    
def run_corr(path_corr, path_layers):
        
        img_corr            = nib.load(path_corr) 
        img_layers          = nib.load(path_layers)

        data_layers         = img_layers.get_fdata()
        data_epi            = img_corr.get_fdata()

        data_epi_tanh            = np.tanh(data_epi)

        unq_layer_ids       = np.unique(data_layers).astype(int)[1:]


        data_list = [] 

        for unq_layer_id in unq_layer_ids: 
            #inds             = np.where(data_layers == unq_layer_id)
            #inds_data        = data_epi[inds]
            
            data        = data_epi_tanh[data_layers == unq_layer_id]
            
            data_mean   = np.mean(data,0)
            
            data_atanh  = np.arctanh(data_mean)

            data_list.append(data_atanh)



        out_path = ('/').join(path_corr.split('/')[0:-1])+"/arctanh.txt"
        out_path2 = ('/').join(path_corr.split('/')[0:-1])+"/layers.txt"

        
        #np.save(out_path, np.array(data_list))
        #np.save(out_path, np.array(data_list))
        
        with open(out_path, 'w') as fp:
            for item in data_list:
                fp.write("%s\n" % item)
            print('Done')
            
            
def reassemble(vox_dir, path_layers):

    dirs                = glob.glob(vox_dir+"/*")
    dirs_vox            = [ d.split('/')[-1].split('_') for d in dirs ]

    img_data            = nib.load(path_layers)
    
    out_data = np.zeros(shape=(img_data.shape[0],img_data.shape[1],img_data.shape[2],7))



    for i in range(len(dirs_vox)):
        x,y,z = dirs_vox[i]
        x,y,z = int(x), int(y),int(z)
        
        l = np.loadtxt(dirs[i]+"/arctanh.txt")
        
        out_data[x,y,z] =  l
            

    clipped_img = nib.Nifti1Image(out_data, img_data.affine, img_data.header)


    save_file = vox_dir+"/reassembled.nii.gz"
    nib.save(clipped_img, save_file)
        
        
    
    return 
    
if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--corr', type=str)
    parser.add_argument('--layers', type=str)
    parser.add_argument('--create_batch_jobs', type=str)
    parser.add_argument('--reassemble', type=str)

    args = parser.parse_args()


    path_corr           = args.corr
    path_layers         = args.layers
    path_batch          = args.create_batch_jobs
    path_reassemble     = args.reassemble

    path_epi="/data/NIMH_scratch/kleinrl/shared/hierClust/data_VASO_maskSPC/VASO_grandmean_WITHOUT-ses-13_spc.nii"
    
    path_layers="/data/NIMH_scratch/kleinrl/shared/hierClust/rois/sub-02_layers.nii"
    
    base_path="/data/NIMH_scratch/kleinrl/shared/hierClust/analysis_hubness/"

    out_path=base_path+"/batches.sjobs"
    vox_dir=base_path+"/voxels"
    
    '''
    path_corr="/data/NIMH_scratch/kleinrl/shared/hierClust/analysis_hubness/120_171_84/120_171_84_CORR_atan.nii.gz"
    '''

    if path_corr: 
        print("running corr")
        run_corr(path_corr, path_layers)
            
    elif path_batch:
        print("building batch")
        build_batch(path_layers, path_epi, base_path, out_path)
        
    elif path_reassemble: 
        print("reasembling")
        reassemble(vox_dir)
        
    else: 
        print("none")
        
        
        
    # epi="/data/NIMH_scratch/kleinrl/shared/hierClust/data_VASO_maskSPC/VASO_grandmean_WITHOUT-ses-13_spc.nii"
    # build_batch(data_layers, epi)
    
