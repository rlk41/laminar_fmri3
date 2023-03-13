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
import glob 
import pickle

import numpy as np 
import scipy.cluster.hierarchy as sch
from scipy.cluster.hierarchy import cut_tree, fcluster, cophenet


def build_batch(path_roi, path_epi): 
    img_layers      = nib.load(path_roi)

    data_layers     = img_layers.get_fdata()
    
    
    inds_layers = np.where(data_layers != 0 )
    
    epi_base = path_epi.rstrip('.nii').split('/')[-1]
    base_dir    = "/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/{}".format(epi_base)
    
    base_roi=path_roi.split('/')[-1].rstrip('.nii') 
    
    os.makedirs(base_dir, exist_ok=True)
    
    batches = [] 
    for i in range(len(inds_layers[0])): 
        
        x = inds_layers[0][i]
        y = inds_layers[1][i]
        z = inds_layers[2][i]

        batches.append("get_laminar_connectivity.sh {} {} {} {} {}".format(x,y,z,path_epi,base_dir))
        if y == 85: 
            print([x,y,z])
    
    path_swarm="{}/get_lc_{}.swarm".format(base_dir, base_roi)
    
    with open(path_swarm, 'w') as fp:
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
    
    
def seed2targ(epi, nullslayers, roi): 
    
    base_dir="/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/"
    epi1="sub-02_ses-07_task-movie_run-01_VASO_spc"
    x,y,z = 121, 160, 77
    epi2="sub-02_ses-07_task-movie_run-01_VASO_spc"
    
    
    path="{}/{}/{}/{}/{}/{}".format(base_dir, epi1, x, y, z, epi2) 
    
    rotated = glob.glob(path="*rotate*CORR.nii.gz")
    emp     = path+"/{}_{}_{}_CORR.nii.gz".format(x,y,z)
    
    
    
    
    
    return 

def seeds2targs(base_dir, epi1, epi2, path_roi_seed, path_roi_targ, path_layers): 
    
    img_roi_seed        = nib.load(path_roi_seed)
    data_roi_seed       = img_roi_seed.get_fdata()
    
    img_roi_targ        = nib.load(path_roi_targ)
    data_roi_targ       = img_roi_targ.get_fdata()
    
    img_layers          = nib.load(path_layers)
    data_layers         = img_layers.get_fdata()
    

    inds_layers = np.where(data_layers != 0 )
    unq_layers = [ u for u in np.unique(data_layers) if u != 0 ] 
    
    bool_layers = [u == data_layers for u in unq_layers ]
    bool_roi_seed = data_roi_seed == 1 
    bool_roi_targ = data_roi_targ == 1 

    for b in bool_layers: 
        print(np.sum(b))
        
    print(np.sum(bool_roi_seed))
    
    
    
    inds_roi_seed = np.where(data_roi_seed != 0 )
    
    # inds_layer_roi = [ np.where(ind == inds_roi )  for ind in inds_layers ]

    # inds_layer_roi = [ (inds_layer == ind) == inds_roi )  for ind in inds_layers ]


    bool_layer_roi_targ = [ (b == 1) & (bool_roi_targ == 1) for b in bool_layers ]
    for b in bool_layer_roi_targ: 
        print(np.sum(b))
        
    

    
    nulls = []
    emps = [] 
    
    for i in range(len(inds_roi_seed[0])):
            
        x = inds_roi_seed[0][i]
        y = inds_roi_seed[1][i]
        z = inds_roi_seed[2][i]
        
        # x,y,z=121,158,85
        
        path_nulls="{}/{}/{}/{}/{}/{}/{}_{}_{}-rotate*CORR.nii.gz".format(base_dir, epi1, x, y, z, epi2, x, y, z)
        path_emps="{}/{}/{}/{}/{}/{}/{}_{}_{}_CORR.nii.gz".format(base_dir, epi1, x, y, z, epi2, x, y, z)
        
        #print(path_nulls)
        #print(path_emps)
        
        glob_nulls  = glob.glob(path_nulls)
        glob_emps   = glob.glob(path_emps)

        emps    += glob_emps
        nulls   += glob_nulls 
        
    
    
    emp_layers = np.zeros(shape=(len(emps), len(unq_layers)))
    
    for i in range(len(emps)):
        img_emp = nib.load(emps[i])
        data_emp = img_emp.get_fdata() 
        
        for j in range(len(bool_layer_roi_targ)):
            ind = bool_layer_roi_targ[j]
            
            emp_layers[i,j] = np.nanmean(data_emp[ind])
            
            

            
    null_layers = np.zeros(shape=(len(nulls), len(unq_layers)))
    for i in range(len(nulls)):
        img_null = nib.load(nulls[i])
        data_null = img_null.get_fdata() 
        
        for j in range(len(bool_layer_roi_targ)):
            ind = bool_layer_roi_targ[j]
            
            null_layers[i,j] = np.nanmean(data_null[ind])
            
            

    
    d = {"emp_layers": emp_layers, "null_layers":null_layers, "inds_roi_seed":inds_roi_seed, 'nulls':nulls,'emps':emps}
    return d


def get_layer(inds, data):
    
    
    
    
    
    return 




if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--corr', type=str)
    parser.add_argument('--layers', type=str)
    parser.add_argument('--create_batch_jobs', type=str)
    
    
    
    parser.add_argument('--roi', type=str)
    parser.add_argument('--epi', type=str)

    parser.add_argument('--reassemble', type=str)

    parser.add_argument('--seed2targ', action='store_true')
    #parser.add_argument('--emps', action='store_true')
    #parser.add_argument('--mulls', action='store_true')




    args = parser.parse_args()


    path_corr           = args.corr
    path_layers         = args.layers
    
    
    path_swarm          = args.create_batch_jobs
    path_roi            = args.roi
    path_epi            = args.epi 
    
    path_reassemble     = args.reassemble


    flag_seed2targ      = args.seed2targ
    # emps                = args.emps 
    # nulls               = args.nulls 
    
    
    """
    path_roi=""
    path_epi=""
    path_swarm=""
    
    """

    #path_epi="/data/NIMH_scratch/kleinrl/shared/hierClust/data_VASO_maskSPC/VASO_grandmean_WITHOUT-ses-13_spc.nii"
    
    #path_layers="/data/NIMH_scratch/kleinrl/shared/hierClust/rois/sub-02_layers.nii"
    
    #base_path="/data/NIMH_scratch/kleinrl/shared/hierClust/analysis_hubness/"

    #out_path=base_path+"/batches.sjobs"
    #vox_dir=base_path+"/voxels"
    
    
    '''
    path_epi="/data/NIMH_scratch/kleinrl/shared/LAYNII_searchlight/data/sub-02_ses-07_task-movie_run-01_VASO_spc.nii"
    path_roi="/data/NIMH_scratch/kleinrl/gdown/rois_hcp_kenshu/1086.L_46d.nii"
    
    path_layers="/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/rois/layers"
    path_roi="/data/NIMH_scratch/kleinrl/gdown/rois_hcp_kenshu/1084.L_46.nii"
    
    voxels=[]
    
    
    emps=[]
    nulls=[]
    
    
    path_epi="/data/NIMH_scratch/kleinrl/shared/LAYNII_searchlight/data/sub-02_ses-07_task-movie_run-01_VASO_spc.nii"


    path_corr="/data/NIMH_scratch/kleinrl/shared/hierClust/analysis_hubness/120_171_84/120_171_84_CORR_atan.nii.gz"
    '''

    if path_corr: 
        print("running corr")
        run_corr(path_corr, path_layers)
            
    elif path_swarm:
        print("building batch")
        build_batch(path_roi, path_epi)
        
        
    elif path_reassemble: 
        print("reasembling")
        #reassemble(vox_dir)
        
        
    elif flag_seed2targ: 
        print("extracting layers")    
        
        """

        """
        
        path_layers="/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/rois/layers/sub-02_layers.nii"
        path_roi_seed="/data/NIMH_scratch/kleinrl/gdown/rois_hcp_kenshu/1084.L_46.nii"
        path_roi_targ="/data/NIMH_scratch/kleinrl/gdown/rois_hcp_kenshu/1047.L_7PC.nii"
        base_dir="/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/voxels/"
        epi1="sub-02_ses-07_task-movie_run-01_VASO_spc"
        epi2="sub-02_ses-07_task-movie_run-01_VASO_spc"
        
        fpath=base_dir+"/emp_andnulls.pkl"

        d = seeds2targs(base_dir, epi1, epi2, path_roi_seed, path_roi_targ, path_layers)
        f = open(fpath,"wb")
        pickle.dump(d,f)
        f.close()

        
        f = open(fpath,"rb")
        d = pickle.load(f)
        
        emp_layers  = d['emp_layers']
        null_layers = d['null_layers']
        inds_roi_seed = d['inds_roi_seed']
        nulls       = d['nulls']
        emps        = d['emps']

        def cluster(ts, clustNum): 
            D = np.corrcoef(ts)
            Z = sch.linkage(D, method='ward')
            clustOwnership = fcluster(Z, criterion='maxclust', t=clustNum)
            return clustOwnership 
        
        

        import matplotlib.pyplot as plt 
        
        for clustNum in range(2, 10):
            #clustNum=2
            own = cluster(emp_layers, clustNum) 
            
            for i in range(1,clustNum+1):
                ind_bool = own == i 
                
                lay         = np.mean(emp_layers[ind_bool], axis=0)
                lay_std     = np.std(emp_layers[ind_bool], axis=0)
                
                plt.plot(range(7), lay, color='red')
                plt.fill_between(range(7),lay-lay_std, lay+lay_std, color='red', alpha=.1)


            null_layers2 = null_layers[:20000]
            
            own = cluster(null_layers2, clustNum) 
            
            for i in range(1,clustNum+1):
                ind_bool = own == i 
                
                lay         = np.mean(null_layers2[ind_bool], axis=0)
                lay_std     = np.std(null_layers2[ind_bool], axis=0)
                
                plt.plot(range(7), lay, color='blue')
                plt.fill_between(range(7), lay-lay_std, lay+lay_std, color='blue', alpha=.1)
                
            plot_path="/data/NIMH_scratch/kleinrl/shared/laminar_connectivity2/DLPFC_to_PP_layers_clustNum{}.png".format(clustNum)
            plt.savefig(plot_path)
            print(plot_path)
                
            plt.close()



        #out = np.zeros(shape=)






    else: 
        print("none")
        
        
        
    # epi="/data/NIMH_scratch/kleinrl/shared/hierClust/data_VASO_maskSPC/VASO_grandmean_WITHOUT-ses-13_spc.nii"
    # build_batch(data_layers, epi)
    
