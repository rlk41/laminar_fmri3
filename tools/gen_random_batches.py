#!/usr/bin/env python

import os
import argparse
import numpy as np

import nibabel as nib 
import glob 
import random


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--epis', nargs='+')
    parser.add_argument('--batchSize', type=int)
    


    args        = parser.parse_args()
    epis        = args.epis 
    batchSize   = args.batchSize
    
    """


    epis=($(find /data/NIMH_scratch/kleinrl/shared/data_RANDRUNS/ -name "sub*spc.nii" ))
    swarm="/data/NIMH_scratch/kleinrl/shared/data_RANDRUNS/random.swarm"
    
    rm -rf $swarm
    
    for i in 1 5 10 15 20 ; do 
    for b in $(seq 1 1 10); do 
    echo "gen_random_batches.py --epis ${epis[@]} --batchSize $i " >> $swarm

    done 
    done 
    
    
    """

    RANDOM_NUMBERS=[ r for r in range(len(epis)) ] 
    random.shuffle(RANDOM_NUMBERS)
    
    
    RANDOM_NUMBERS_SELECTED = RANDOM_NUMBERS[:batchSize]
    epis_to_average = [ epis[n] for n in RANDOM_NUMBERS_SELECTED ]
    
            
    print("batchSize: {}".format(batchSize))
    print("len selected epis: {}".format(len(RANDOM_NUMBERS_SELECTED)))
    print("selected epis: {}".format(RANDOM_NUMBERS_SELECTED))
    #print(epis_to_average)
    
    epi_datas = []
    
    for epi_path in epis_to_average:
        
        epi_img     = nib.load(epi_path)
        epi_data    = epi_img.get_fdata() 
        
        epi_datas.append(epi_data) 

    out = np.mean(epi_datas, axis=0) 


    
    filename = "RANDRUNS_batchSize{}_{}.nii".format(str(len(RANDOM_NUMBERS_SELECTED)).zfill(3), str(random.randint(1,9999)).zfill(4))
    outpath     = '/'.join(epi_path.split('/')[:-1]) + os.sep + filename 
    
    print("saving as: {}".format(outpath))
    
    clipped_img = nib.Nifti1Image(out, epi_img.affine, epi_img.header)
    nib.save(clipped_img, outpath)

    print("DONE")
    
        
    
    



