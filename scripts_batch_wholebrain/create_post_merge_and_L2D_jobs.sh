#!/bin/bash 

set -e 


analysis_dir=$1


swarm_merged_dir="$analysis_dir/swarm_merged"




if [ -f $swarm_merged_dir/swarm_merged.post  ]; 
then 
rm $swarm_merged_dir/swarm_merged.post 
touch $swarm_merged_dir/swarm_merged.post 
else 
touch $swarm_merged_dir/swarm_merged.post 
fi 



if [ -f $swarm_merged_dir/swarm_merged.L2D ]; 
then 
rm $swarm_merged_dir/swarm_merged.L2D
touch $swarm_merged_dir/swarm_merged.L2D
else 
touch $swarm_merged_dir/swarm_merged.L2D
fi 




for out_dir in $analysis_dir/fsl_feat_*; do 

    # if [ -d $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat ]; 
    # then 
    # echo "EXISTS RUNNING -- $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat "


    #echo "run_laminar_permute_post.sh -d $out_dir" | tee -a $swarm_merged_dir/swarm_merged.post 
    echo "run_laminar_permute_post.zstat.wb3.sh -d $out_dir" | tee -a $swarm_merged_dir/swarm_merged.post 

    s=( 1 3 5 ) #7 8 )
    dir="$out_dir/mean"
    mkdir -p $dir 
    mkdir -p $dir/logs

    for smoothing in ${s[@]};do 
    #echo "L2D.job.sh $dir $smoothing" | tee -a $swarm_merged_dir/swarm_merged.L2D 
    #echo "L2D.job.sh $dir $smoothing inv_thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 
    #echo "L2D.job.sh $dir $smoothing thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 
    # L2D.job.wb2.sh /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/mean 1 thresh_zstat1.nii
    echo "L2D.job.wb2.sh $dir $smoothing thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 

    done 


    #fi 
done 


dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name 04postmerge_ave --logdir $swarm_merged_dir \
--time 02:00:00)


dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 25  --job-name 05_L2D --logdir $swarm_merged_dir \
--dependency=afterok:$dep_merged_post --time 24:00:00 )
