#!/usr/bin/env python

import numpy as np
import pickle
import h5py


def big_corr(x): 

    # # read nparray, dimensions (102000, 60)
    # infile = open(r'file.dat', 'rb')
    # x = pickle.load(infile)
    # infile.close()     
    
    # z-normalize the data -- first compute means and standard deviations
    xave = np.average(x,axis=1)
    xstd = np.std(x,axis=1)

    # transpose for the sake of broadcasting (doesn't seem to work otherwise!)
    ztrans = x.T - xave
    ztrans /= xstd

    # transpose back
    z = ztrans.T

    # compute correlation matrix - shape = (102000, 102000)
    arr = np.matmul(z, z.T)   
    arr /= z.shape[0]

    return arr 

    # # output to HDF5 file
    # with h5py.File('correlation_matrix.h5', 'w') as hf:
    #         hf.create_dataset("correlation",  data=arr)

def big_corr2(x): 
    samples = x.shape[0]
    centered_x = x - np.sum(x, axis=0, keepdims=True) / samples 
    centered_y = y - np.sum(y, axis=0, keepdims=True) / samples 
    cov_xy = 1./(samples - 1) * np.dot(centered_x.T, centered_y)
    var_x = 1./(samples - 1) * np.sum(centered_x**2, axis=0)
    var_y = 1./(samples - 1) * np.sum(centered_y**2, axis=0)
    corrcoef_xy = cov_xy / np.sqrt(var_x[:, None] * var_y[None,:])
    return corrcoef_xy


def test(): 
    
    
    path_epi        = "/data/NIMH_scratch/kleinrl/shared/hierClust/data_VASO_maskSPC/VASO_grandmean_WITHOUT-ses-13_spc.nii"
    img_epi         = nib.load(path_epi)
    data_epi        = img_epi.get_fdata()
    
    path_layers     = "/data/NIMH_scratch/kleinrl/shared/hierClust/rois/sub-02_layers.nii"
    img_layers      = nib.load(path_layers)
    data_layers     = img_layers.get_fdata()
    
    data_rim        = data_epi[data_layers != 0 ]
    
    
    
    
    
    big_corr(data_rim)
    
    
    
    
    

if __name__ == "__main__":
    
    
    parser = argparse.ArgumentParser(description='build dataframe profile')
    parser.add_argument('--pickle', type=str, nargs='+')

    args = parser.parse_args()

    pkl = args.pickle
    
    
    # read nparray, dimensions (102000, 60)

    #infile = open(r'file.dat', 'rb')
    infile = open(pkl, 'rb')

    x = pickle.load(infile)
    infile.close()     
    
    arr = big_corr(x)
    
    
    # output to HDF5 file
    with h5py.File('correlation_matrix.h5', 'w') as hf:
            hf.create_dataset("correlation",  data=arr)
            