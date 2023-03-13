#!/bin/bash 



x=$1
y=$2
z=$3 
epi=$4
base_dir=$5

nullNum=10



# base_dir="/data/NIMH_scratch/kleinrl/shared/laminar_connectivity/data//voxels"
# epi="/data/NIMH_scratch/kleinrl/shared/hierClust/data_VASO_maskSPC/sub-02_ses-04_task-movie_run-02_VASO_spc.nii"
# x=120
# y=171
# z=84

set -e 

epi_base=$(basename $(basename $epi .nii) .nii.gz) 

out_dir=$base_dir/${x}/${y}/${z}/${epi_base}


#rm -rf $out_dir 

mkdir -p $out_dir



roi_dir="/data/NIMH_scratch/kleinrl/shared/hierClust/rois"

#layers=$roi_dir"/sub-02_layers.nii"
layers_bin=$roi_dir"/sub-02_layers_bin.nii"


# l1=$roi_dir"/l01.nii"
# l2=$roi_dir"/l02.nii"
# l3=$roi_dir"/l03.nii"
# l4=$roi_dir"/l04.nii"
# l5=$roi_dir"/l05.nii"
# l6=$roi_dir"/l06.nii"

timecourse=$out_dir/${x}_${y}_${z}.1D
timecourse_coords=$out_dir/${x}_${y}_${z}.coords

corr_map=$out_dir/${x}_${y}_${z}_CORR.nii.gz
#corr_map_atan=$out_dir/${x}_${y}_${z}_CORR_atan.nii.gz
#vector=$out_dir/arctanh.txt

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




null=($(find $out_dir -name '*rotate*_CORR.nii.gz'))
#null=($(ls $out_dir/*rotate*_CORR.nii.gz))


if [  "${#null[@]}" -ge "$nullNum" ]; then 
    echo 'NULLS exist not rerunning'
    echo "found ${#null[@]} NULLS "
else
    echo "NULL DO NOT EXIST RUNNING!"; 
    echo "found ${#null[@]} NULLS "

     



    rm -rf *rotate* 


    # # rotate timecourse 
    # rotated_timecourses=(ls $out_dir/*rotate*.1D)
    # num_rt=${#rotated_timecourses[@]}


    # if [[ $num_rt -eq 0 ]]; then 
    #     echo "creating rotates timecoruses"
    #     rotate_timecourse.py --ts $timecourse --num 10
    # else
    #     echo "rotated timecourses exist"
    # # fi 


    echo "rotating TCs"
    rotate_timecourse.py --ts $timecourse --num $nullNum

    rotated_timecourses=($(find $out_dir -name '*rotate*.1D'))

    echo "        "
    echo "Getting TCs and running 3dTCorr"
    echo "        "

    for rt in ${rotated_timecourses[@]}; do 

    rt_base=$(basename $rt .1D)

    prefix=$out_dir/${rt_base}_CORR.nii.gz

    echo "     "
    echo "rt $rt "
    echo "epi $epi "
    echo "prefix $prefix"
    echo "layers_bin $layers_bin"
    echo "   "


    3dTcorr1D -mask $layers_bin  -prefix $prefix $epi $rt

    done 

fi 





#3dcalc -a $corr_map -expr 'atan(a)' -prefix  $corr_map_atan

# if [ ! -f $vector ]; then 
#     extract_layer_and_atanh.py --corr $corr_map --layers $layers 
# else
#     echo "arctanh.txt exists"
# fi 



