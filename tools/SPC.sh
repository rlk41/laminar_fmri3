#!/bin/bash 


f=$1 

base=$(basename $(basename $f .nii) .nii.gz) 


3dTstat -mean -prefix ${base}_mean.nii $f

3dDetrend -polort 3 -prefix ${base}_detrend.nii $f 

3dcalc -a ${base}_detrend.nii -b ${base}_mean.nii -expr 'a/b' -prefix ${base}_spc.nii



3dTstat -stdev -prefix ${base}_spc_stdev.nii ${base}_spc.nii

# 3dDespike -nomask -NEW25 -prefix ${base}_spc_despike.nii ${base}_spc.nii

# 3dDespike -NEW -prefix ${base}_spc_despike.nii ${base}_spc.nii

# 3dTstat -stdev -prefix ${base}_spc_despike_stdev.nii ${base}_spc_despike.nii

