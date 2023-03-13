#!/bin/bash 



x=$1
y=$2
z=$3 
epi=$4
base_dir=$5



# base_dir="/data/NIMH_scratch/kleinrl/shared/hierClust/analysis_hubness/voxels"
# epi="/data/NIMH_scratch/kleinrl/shared/hierClust/data_VASO_maskSPC/VASO_grandmean_WITHOUT-ses-13_spc.nii"
# x=120
# y=171
# z=84

set -e 


out_dir=$base_dir/${x}/${y}/${z}


#rm -rf $out_dir 

mkdir -p $out_dir



roi_dir="/data/NIMH_scratch/kleinrl/shared/hierClust/rois"

layers=$roi_dir"/sub-02_layers.nii"
layers_bin=$roi_dir"/sub-02_layers_bin.nii"


l1=$roi_dir"/l01.nii"
l2=$roi_dir"/l02.nii"
l3=$roi_dir"/l03.nii"
l4=$roi_dir"/l04.nii"
l5=$roi_dir"/l05.nii"
l6=$roi_dir"/l06.nii"

timecourse=$out_dir/${x}_${y}_${z}.1D
timecourse_coords=$out_dir/${x}_${y}_${z}.coords

corr_map=$out_dir/${x}_${y}_${z}_CORR.nii.gz
corr_map_atan=$out_dir/${x}_${y}_${z}_CORR_atan.nii.gz
vector=$out_dir/arctanh.txt

if [ ! -f $timecourse ]; then 
    3dmaskave -mask $layers_bin -quiet  -ibox $x $y $z $epi > $timecourse 
    #3dmaskave -mask $layers_bin -ibox $x $y $z $epi > $timecourse_coords
else
    echo "timecourse exists"
fi 

if [ ! -f $corr_map ]; then 
    3dTcorr1D -mask $layers_bin  -prefix $corr_map $epi $timecourse
else
    echo "corr_map exists"
fi 


#3dcalc -a $corr_map -expr 'atan(a)' -prefix  $corr_map_atan

if [ ! -f $vector ]; then 
    extract_layer_and_atanh.py --corr $corr_map --layers $layers 
else
    echo "arctanh.txt exists"
fi 



