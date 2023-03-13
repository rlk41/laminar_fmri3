#!/usr/bin/env python

import os
import argparse
import numpy as np
import nibabel as nib 



     
        
if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--roi', type=str, default=None)

    args = parser.parse_args()

    path_roi            = args.roi

    img_roi = nib.load(path_roi)
    data_roi = img_roi.get_fdata() 
    
    
    x,y,z = np.where(data_roi == 1)
    
    base = path_roi.split('/')[-1].rstrip('.nii')
    
    base_xyz = "./" + base + ".xyz"
    
    base_x = "./" + base + ".x"
    base_y = "./" + base + ".y"
    base_z = "./" + base + ".z"
    
    with open(base_xyz, 'w') as f: 
        for i in range(len(x)):
            f.write("{} {} {}\n".format(x[i],y[i],z[i]))
            
    f.close() 
    
    
    with open(base_x, 'w') as f: 
        for i in range(len(x)):
            f.write("{}\n".format(x[i]))
    f.close() 
    
    with open(base_y, 'w') as f: 
        for i in range(len(x)):
            f.write("{}\n".format(y[i]))
    f.close() 
    
    with open(base_z, 'w') as f: 
        for i in range(len(x)):
            f.write("{}\n".format(z[i]))
    f.close() 
    
    