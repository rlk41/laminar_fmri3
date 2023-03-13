#!/bin/bash 

local epi=$1
local seed=$2
local out_dir=$3

mkdir -p $out_dir 


local epi_base=$(basename $(basename $epi .nii.gz) .nii) 
local seed_base=$(basename $seed)

local out_file_corr=$out_dir/$epi_base-$seed_base-CORR.nii.gz
local out_file_DECONV=$out_dir/$epi_base-$seed_base-DECONV.nii.gz

# rim, parc_hcp_kenshu layers 

echo $rim 
echo $parc_hcp_kenshu 
echo $layers
echo $epi $seed 
echo $out_file_corr
echo $out_file_DECONV

mkdir -p $out_dir
cd  $out_dir

rm $out_dir/*


3dTcorr1D -prefix $out_file_corr -mask $rim $epi $seed -overwrite

3dDeconvolve -input $epi -mask $rim  \
-num_stimts 1 -stim_file 1 $seed -stim_label 1 "seed_tc" \
-rout -fout -tout -bucket deconv_TR0

3dDeconvolve  -force_TR 5 -input $epi -mask $rim \
-num_stimts 1 -stim_file 1 $seed -stim_label 1 "seed_tc" \
-rout -fout -tout -bucket deconv_TR5
#-fitts full_model.fit -errts residual_error.fit \

3dDeconvolve -force_TR 5.1 -input $epi -mask $rim \
-num_stimts 1 -stim_file 1 $seed -stim_label 1 "seed_tc" \
-rout -fout -tout -bucket deconv_TR51

# 3dREMLfit -matrix deconv_TR51.xmat.1D -input /data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//data/sub-02_ses-04_task-movie_run-04_VASO.nii \
#  -mask /data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//data/sub-02_layers_bin.nii.gz \
#  -fout -tout -rout -Rbuck deconv_TR51_REML -Rvar deconv_TR51_REMLvar -verb

3dresample -orient RPI -inset deconv_TR0+orig.HEAD[0] -prefix deconv_TR0_FULLR2.nii 
3dresample -orient RPI -inset deconv_TR0+orig.HEAD[1] -prefix deconv_TR0_Fstat.nii 
3dresample -orient RPI -inset deconv_TR0+orig.HEAD[2] -prefix deconv_TR0_Coef.nii 

3dresample -orient RPI -inset deconv_TR5+orig.HEAD[0] -prefix deconv_TR5_FULLR2.nii 
3dresample -orient RPI -inset deconv_TR5+orig.HEAD[1] -prefix deconv_TR5_Fstat.nii 
3dresample -orient RPI -inset deconv_TR5+orig.HEAD[2] -prefix deconv_TR5_Coef.nii 

3dresample -orient RPI -inset deconv_TR51+orig.HEAD[0] -prefix deconv_TR51_FULLR2.nii 
3dresample -orient RPI -inset deconv_TR51+orig.HEAD[1] -prefix deconv_TR51_Fstat.nii 
3dresample -orient RPI -inset deconv_TR51+orig.HEAD[2] -prefix deconv_TR51_Coef.nii 

#'Full_R^2'
#'Full_Fstat'
#'seed_tc#0_Coef'


LN2_todataframe.py --input $out_file_corr  --columns  $parc_hcp_kenshu --layers  $layers 

LN2_todataframe.py --input deconv_TR0_FULLR2.nii  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input deconv_TR0_Fstat.nii  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input deconv_TR0_Coef.nii  --columns  $parc_hcp_kenshu --layers  $layers 

LN2_todataframe.py --input deconv_TR5_FULLR2.nii  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input deconv_TR5_Fstat.nii  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input deconv_TR5_Coef.nii  --columns  $parc_hcp_kenshu --layers  $layers 

LN2_todataframe.py --input deconv_TR51_FULLR2.nii  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input deconv_TR51_Fstat.nii  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input deconv_TR51_Coef.nii  --columns  $parc_hcp_kenshu --layers  $layers 

