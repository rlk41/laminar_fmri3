

# TODO 
# correct DAY and L2D.job.sh 3 params 

"""

"""



source_wholebrain2.0

pca_num="5"
epi_num="1"



analysis_dir="$my_scratch/analyses/wb3/FEF_aim1/all_auto_iterNULL_backup_wb2_"
roi_dir="$analysis_dir/rois"

mkdir -p $analysis_dir

cd $analysis_dir


parc=$warped_columns_30k


base=$(basename $parc .nii )

# ls $rois_hcp | grep TE
rois=(
$rois_hcp/*.L_FEF.nii
)

echo ${rois[@]}
echo ${#rois[@]}

for r in ${rois[@]}; do 3dinfo $r; done 



mkdir -p $analysis_dir 
mkdir -p $roi_dir 

swarm_submit=$analysis_dir/swarm.submit
touch $swarm_submit

size=${#rois[@]}

#for imp_type in 'ave' 'perm' ; do 
for pca_num in 5; do 
for start in `seq 0 1 $(( $size - 1 ))`; do
for epi_num in 1 5 10 14 ; do 

    roi_path=${rois[$start]} 
    cp $roi_path $roi_dir 

    c=$(basename $roi_path .nii)
    c=$(basename $c .nii.gz)

    echo $c

    out_dir=$analysis_dir/fsl_feat_${c}_pca${pca_num}_epi_num${epi_num} #_${imp_type}
    out_dir_null=$analysis_dir/fsl_feat_${c}_pca${pca_num}_epi_num${epi_num} #_${imp_type}_NULL


    mkdir -p $out_dir
    mkdir -p $out_dir_null

    #cp $roi_path  $out_dir/roi 
    echo "pca $pca_num perm $epi_num roi $roi_path fsl_feat" > $out_dir/config.txt
    echo "pca $pca_num perm $epi_num roi $roi_path fsl_feat" > $out_dir_null/config.txt

    #echo "run_swarm_wb3_permute.sh -r $roi_path -p $pca_num -s $epi_num -o $out_dir -A -X" | tee -a $swarm_submit
    echo "run_swarm_wb3_permute_backup_wb2.sh -r $roi_path -p $pca_num -s $epi_num -o $out_dir -A -X" | tee -a $swarm_submit
    echo "run_swarm_wb3_permute_backup_wb2.sh -r $roi_path -p $pca_num -s $epi_num -o $out_dir_null  -N -A -X" | tee -a $swarm_submit


done 
done 
done

swarm_merged_dir="$analysis_dir/swarm_merged"
swarm_merge_and_run="$swarm_merged_dir/swarm.merge_and_run"
post_merge_L2D_job="$swarm_merged_dir/swarm.post_merge_L2D_job"

mkdir -p $swarm_merged_dir

echo "merge_feats_and_run.sh $analysis_dir -B" > $swarm_merge_and_run
echo "create_post_merge_and_L2D_jobs.sh $analysis_dir " > $post_merge_L2D_job 




dep_setup=$(swarm -b 10 -f $swarm_submit -g 10 --job-name 01setup )


dep_merge_feat_and_run=$( swarm -f $swarm_merge_and_run -g 10 --job-name 02merge-run  \
--dependency=afterok:$dep_setup)


dep_create_postmerge_L2D=$( swarm -f $post_merge_L2D_job  -g 15 --job-name 03postRun \
--dependency=afterok:$dep_merge_feat_and_run )





# dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name 04postmerge_ave --logdir $swarm_merged_dir \
# --dependency=afterok:$dep_create_postmerge_L2D --time 02:00:00)


# dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 25  --job-name 05_L2D --logdir $swarm_merged_dir \
# --dependency=afterok:$dep_merged_post --time 48:00:00 )







# swarm_merged_dir=$analysis_dir/swarm_merged
# swarm_merged_feat=$swarm_merged_dir/swarm_mearged.feat
# mkdir -p $swarm_merged_dir
# touch $swarm_merged_feat
# feats_to_merge=($(find $analysis_dir  -name swarm.feat ))
# echo ${#feats_to_merge[@]}
# size=${#feats_to_merge[@]}
# cat ${feats_to_merge[@]} | tee -a $swarm_merged_feat
# cat $swarm_merged_feat | wc 
# dep_merged_feat=$(swarm -f $swarm_merged_feat -g 25 -t 1 --job-name feat_merged --logdir $swarm_merged_dir --time 10:00:00 )



# if [ -f $swarm_merged_dir/swarm_merged.post  ]; 
# then 
# rm $swarm_merged_dir/swarm_merged.post 
# touch $swarm_merged_dir/swarm_merged.post 
# else 
# touch $swarm_merged_dir/swarm_merged.post 
# fi 



# if [ -f $swarm_merged_dir/swarm_merged.L2D ]; 
# then 
# rm $swarm_merged_dir/swarm_merged.L2D
# touch $swarm_merged_dir/swarm_merged.L2D
# else 
# touch $swarm_merged_dir/swarm_merged.L2D
# fi 




# for out_dir in $analysis_dir/fsl_feat_*; do 

#     # if [ -d $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat ]; 
#     # then 
#     # echo "EXISTS RUNNING -- $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat "


#     #echo "run_laminar_permute_post.sh -d $out_dir" | tee -a $swarm_merged_dir/swarm_merged.post 
#     echo "run_laminar_permute_post.zstat.wb3.sh -d $out_dir" | tee -a $swarm_merged_dir/swarm_merged.post 

#     s=( 1 3 5 7 8 )
#     dir="$out_dir/mean"
#     mkdir -p $dir 
#     mkdir -p $dir/logs

#     for smoothing in ${s[@]};do 
#     #echo "L2D.job.sh $dir $smoothing" | tee -a $swarm_merged_dir/swarm_merged.L2D 
#     #echo "L2D.job.sh $dir $smoothing inv_thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 
#     #echo "L2D.job.sh $dir $smoothing thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 
#     # L2D.job.wb2.sh /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/mean 1 thresh_zstat1.nii
#     echo "L2D.job.wb2.sh $dir $smoothing thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 

#     done 


#     #fi 
# done 

# post_merge_L2D_job="$analysis_dir/swarm.post_merge_L2D_job"
# echo "create_post_merge_and_L2D_jobs.sh $analsysis_dir " | tee -a $post_merge_L2D_job 
# dep_create_postmerge_L2D=$( swarm -f $post_merge_L2D_job  -g 15 --dependency=afterok:$dep_merge_feat_and_run --job-name post_merge-L2D )




# freeview thresh_zstat1.nii.gz /data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii $warp_parc_hcp 




# dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name post_merged --logdir $swarm_merged_dir \
# --time 02:00:00)

# out_dir="/data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/gdown_sub-02_VASO_across_days.2D.pca_000"

# run_laminar_permute_post.sh -d /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10
# run_laminar_permute_post.zstat.sh -d /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/gdown_sub-02_VASO_across_days.2D.pca_000

# dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name swarm_merged_post --logdir $swarm_merged_dir \
# --dependency=afterok:$dep_merged_feat --time 02:00:00)


# # dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 20  --job-name L2D_merged --logdir $swarm_merged_dir \
# # --time 48:00:00 )

# dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 25  --job-name L2D_merged --logdir $swarm_merged_dir \
# --dependency=afterok:$dep_merged_post --time 48:00:00 )















# this will generate the pcas and file stricture but not run 
# if -X included 
swarm -b 10 -f $swarm_submit -g 10


#merge the swarm.feat files together and submit 

#find $analysis_dir -name swarm.feat

swarm_merged_dir=$analysis_dir/swarm_merged
swarm_merged_feat=$swarm_merged_dir/swarm_mearged.feat


mkdir -p $swarm_merged_dir


touch $swarm_merged_feat

feats_to_merge=($(find . -name swarm.feat ))
echo ${#feats_to_merge[@]}

size=${#feats_to_merge[@]}


cat ${feats_to_merge[@]} | tee -a $swarm_merged_feat

cat $swarm_merged_feat | wc 




dep_merged_feat=$(swarm -f $swarm_merged_feat -g 25 -t 1 --job-name feat_merged --logdir $swarm_merged_dir --time 10:00:00 )

# 34096619


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

    s=( 1 3 5 7 8 )
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



# freeview thresh_zstat1.nii.gz /data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii $warp_parc_hcp 




# dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name post_merged --logdir $swarm_merged_dir \
# --time 02:00:00)

# out_dir="/data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/gdown_sub-02_VASO_across_days.2D.pca_000"

# run_laminar_permute_post.sh -d /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10
# run_laminar_permute_post.zstat.sh -d /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/gdown_sub-02_VASO_across_days.2D.pca_000

dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name swarm_merged_post --logdir $swarm_merged_dir \
--dependency=afterok:$dep_merged_feat --time 02:00:00)


# dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 20  --job-name L2D_merged --logdir $swarm_merged_dir \
# --time 48:00:00 )

dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 25  --job-name L2D_merged --logdir $swarm_merged_dir \
--dependency=afterok:$dep_merged_post --time 48:00:00 )










# 34096619





# run_laminar_permute_post.sh -d $out_dir corr.nii.gz 







# s=( 1 3 5 7 8 )
# dir="$out_dir/mean"
# mkdir -p $dir 
# mkdir -p $dir/logs

# for smoothing in ${s[@]};do 
# #echo "L2D.job.sh $dir $smoothing" | tee -a $swarm_merged_dir/swarm_merged.L2D 
# #echo "L2D.job.sh $dir $smoothing inv_thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 
# #echo "L2D.job.sh $dir $smoothing thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 
# # L2D.job.wb2.sh /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/mean 1 thresh_zstat1.nii
# echo "L2D.job.wb2.sh $dir $smoothing thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 




# if [ -f $swarm_merged_dir/swarm_merged.post  ]; 
# then 
# rm $swarm_merged_dir/swarm_merged.post 
# touch $swarm_merged_dir/swarm_merged.post 
# else 
# touch $swarm_merged_dir/swarm_merged.post 
# fi 



# if [ -f $swarm_merged_dir/swarm_merged.L2D ]; 
# then 
# rm $swarm_merged_dir/swarm_merged.L2D
# touch $swarm_merged_dir/swarm_merged.L2D
# else 
# touch $swarm_merged_dir/swarm_merged.L2D
# fi 




# for out_dir in $analysis_dir/fsl_feat_*; do 

#     # if [ -d $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat ]; 
#     # then 
#     # echo "EXISTS RUNNING -- $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat "


#     #echo "run_laminar_permute_post.sh -d $out_dir" | tee -a $swarm_merged_dir/swarm_merged.post 
#     echo "run_laminar_permute_post.zstat.wb3.sh -d $out_dir" | tee -a $swarm_merged_dir/swarm_merged.post 

#     s=( 1 3 5 7 8 )
#     dir="$out_dir/mean"
#     mkdir -p $dir 
#     mkdir -p $dir/logs

#     for smoothing in ${s[@]};do 
#     #echo "L2D.job.sh $dir $smoothing" | tee -a $swarm_merged_dir/swarm_merged.L2D 
#     #echo "L2D.job.sh $dir $smoothing inv_thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 
#     #echo "L2D.job.sh $dir $smoothing thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 
#     # L2D.job.wb2.sh /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/mean 1 thresh_zstat1.nii
#     echo "L2D.job.wb2.sh $dir $smoothing thresh_zstat1.nii" | tee -a $swarm_merged_dir/swarm_merged.L2D 

#     done 


#     #fi 
# done 



# freeview thresh_zstat1.nii.gz /data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii $warp_parc_hcp 




# dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name post_merged --logdir $swarm_merged_dir \
# --time 02:00:00)

# out_dir="/data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/gdown_sub-02_VASO_across_days.2D.pca_000"

# run_laminar_permute_post.sh -d /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10
# run_laminar_permute_post.zstat.sh -d /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/gdown_sub-02_VASO_across_days.2D.pca_000

dep_merged_post=$(swarm -f $swarm_merged_dir/swarm_merged.post -g 10 --job-name swarm_merged_post --logdir $swarm_merged_dir \
--dependency=afterok:$dep_merged_feat --time 02:00:00)


# dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 20  --job-name L2D_merged --logdir $swarm_merged_dir \
# --time 48:00:00 )

dep_merged_L2D=$(swarm -f $swarm_merged_dir/swarm_merged.L2D -g 25  --job-name L2D_merged --logdir $swarm_merged_dir \
--dependency=afterok:$dep_merged_post --time 48:00:00 )



# 

'''
layer_dir="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/"
layers="${layer_dir}/grow_leaky_loituma/equi_volume_layers_n10.nii"

freeview \
/data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_pca5_hcp_across/fsl_feat_1010.L_FEF_pca10/mean/thresh_zstat1.nii.gz \
/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii \
$layers \
$warp_parc_hcp 



'''




echo "python /home/kleinrl/projects/laminar_fmri/analyses/analysis_nulldist_FEF.py" >> swarm.plots 
swarm -f swarm.plots -g 10 --job-name swarm_plots --time 01:00:00


rois=(L_FEF L_LIPv L_VIP L_V4t L_V4 L_V2 L_V3 L_V1 L_MST L_MT
    L_TF L_TE1a L_TE1p L_TE2a L_TE2p L_FST L_7PL )


analysis_dir="$my_scratch/analyses/nullDist_pca10_FEF"
swarm_plots="$analysis_dir/swarm_merged/swarm.plots"

rm $swarm_plots
touch $swarm_plots
for r in ${rois[@]}; do 
    echo "python /home/kleinrl/projects/laminar_fmri/analyses/analysis_nulldist_FEF.py --k $r " >> $swarm_plots
done 
swarm -f $swarm_plots -g 10 --job-name swarm_plots --time 01:00:00 --logdir $analysis_dir/swarm_merged


rm $swarm_plots
touch $swarm_plots
for r in ${rois[@]}; do 
for s in `seq 1 7 `; do 
    echo "python /home/kleinrl/projects/laminar_fmri/analyses/analysis_nulldist_FEF_boxplot3.py --k $r --fwhm $s " | tee -a $swarm_plots
done 
done 
cat $swarm_plots | wc 


swarm -f $swarm_plots -g 20 --job-name boxplots6 --time 12:00:00 --logdir $analysis_dir/swarm_merged



scp -r cn2458:/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF/plots . 







rois=(L_FEF L_LIPv L_VIP L_V4t L_V4 L_V2 L_V3 L_V1 L_MST L_MT
    L_TF L_TE1a L_TE1p L_TE2a L_TE2p L_FST L_7PL )


analysis_dir="$my_scratch/analyses/nullDist_pca10_single"
swarm_plots="$analysis_dir/swarm_merged/swarm.plots"



rm $swarm_plots
touch $swarm_plots
for r in ${rois[@]}; do 
for s in `seq 1 7 `; do 
    echo "python /home/kleinrl/projects/laminar_fmri/analyses/analysis_nulldist_FEF_boxplot3_seedNull.py --k $r --fwhm $s " | tee -a $swarm_plots
done 
done 
cat $swarm_plots | wc 


swarm -f $swarm_plots -g 20 --job-name bp_singleNULL --time 12:00:00 --logdir $analysis_dir/swarm_merged







export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
layer_dir="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/"
layers="${layer_dir}/grow_leaky_loituma/equi_volume_layers_n10.nii"


analysis_dir="$my_scratch/analyses/nullDist_pca10_FEF"
swarm_merged_dir="$analysis_dir/swarm_merged"
file="inv_pe1.mean.nii.gz"

swarmpost=$swarm_merged_dir/swarm_merged.post 
swarmL2D=$swarm_merged_dir/swarm_merged.L2D 
swarmwarp=$swarm_merged_dir/swarm_merged.warp
logdir=$analysis_dir/swarm_merged

rm $swarmpost & touch $swarmpost 
rm $swarmL2D & touch $swarmL2D
rm $swarmwarp & touch $swarmwarp


for out_dir in $analysis_dir/fsl_feat_*pca10/DAY*/mean ; do 

    # if [ -d $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat ]; 
    # then 
    # echo "EXISTS RUNNING -- $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat "

    #echo $out_dir
    #warp_ANTS_resampleCu_inverse.sh pei.mean.nii.gz $layers
    #warp_ANTS_resampleCu_inverse.sh mean_func.mean.nii.gz $layers

    #echo "cd $out_dir; warp_ANTS_resampleCu_inverse.sh pe1.mean.nii.gz $layers" | tee -a $swarmwarp
    # arp_ANTS_resampleCu_inverse.sh mean_func.mean.nii.gz $layers
    #echo "run_laminar_permute_post.sh -d $out_dir -f $file" | tee -a $swarmpost

    s=(5 7 8 ) # ( 1 3) #

    for smoothing in ${s[@]};do 
    echo "L2D.job.sh $out_dir $smoothing $file" | tee -a $swarmL2D
    done 


    #fi 
done 

for out_dir in $analysis_dir/fsl_feat_*pca10/DAY*/mean ; do 

    # if [ -d $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat ]; 
    # then 
    # echo "EXISTS RUNNING -- $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat "

    #echo $out_dir
    #warp_ANTS_resampleCu_inverse.sh pei.mean.nii.gz $layers
    #warp_ANTS_resampleCu_inverse.sh mean_func.mean.nii.gz $layers

    #echo "cd $out_dir; warp_ANTS_resampleCu_inverse.sh pe1.mean.nii.gz $layers" | tee -a $swarmwarp
    # arp_ANTS_resampleCu_inverse.sh mean_func.mean.nii.gz $layers
    #echo "run_laminar_permute_post.sh -d $out_dir -f $file" | tee -a $swarmpost

    s=(5 7 8 ) # ( 1 3) #

    for smoothing in ${s[@]};do 
    echo "L2D.job.sh $out_dir $smoothing $file" | tee -a $swarmL2D
    done 


    #fi 
done 







swarm -f $swarmwarp -g 5 --job-name warp --time 1:00:00 --logdir $logdir

swarm -f $swarmL2D -g 10 --job-name swarmL2D --time 24:00:00 --logdir $logdir






# # ###############
# # # build null 
# # #################

# # # create dir 
# # null_dir=$analysis_dir/null_1000
# # mkdir -p $null_dir

# # pes=($(find $analysis_dir/fsl_feat* -name inv_pe1.nii))
# # size=${#pes[@]}

# # echo $size ${pes[1]}

# # null_pes=()

# # for s in `seq 1 1000`; do 
# #     num=$((0 + $RANDOM % $(( $size - 1 )) ))
# #     num_pe=${pes[$num]}
# #     echo $num $num_pe

# #     null_pes+=($num_pe)

# # done 

# # 3dMean -prefix $null_dir/inv_pe1.nii ${null_pes[@]} 
# # 3dinfo $null_dir/inv_pe1.nii


# # # get inv_mean_func.nii in dir 
# # null_means=($(find $analysis_dir -name inv_mean_func.nii ))
# # cp ${null_means[0]} $null_dir/inv_mean_func.nii 





# # if [ -f $swarm_merged_dir/swarm_merged.L2D_null ]; 
# # then 
# # rm $swarm_merged_dir/swarm_merged.L2D_null
# # touch $swarm_merged_dir/swarm_merged.L2D_null
# # else 
# # touch $swarm_merged_dir/swarm_merged.L2D_null
# # fi 


# # s=( 1 3 5 7 8 )

# # mkdir -p $null_dir 
# # mkdir -p $null_dir/logs

# # for smoothing in ${s[@]};do 
# # echo "L2D.job.sh $null_dir $smoothing" | tee -a $swarm_merged_dir/swarm_merged.L2D_null 
# # done 


    

# # swarm -f $swarm_merged_dir/swarm_merged.L2D_null -g 20  --job-name L2DNULL_merged --logdir $null_dir/logs \
# # --time 48:00:00 









# LN2_LAYERDIMENSION.py \
# --input "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.nii.gz" \
# --columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii" \
# --layers "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" 

# cd /data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000

# downsample_2x_NN.sh "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.mean.nii.gz" 
# downsample_2x_NN.sh "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.se.nii.gz" 
# downsample_2x_NN.sh "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.sd.nii.gz" 


# for f in fsl_feat_*; do 
# if [ -f $f/mean/inv_pe1.fwhm7.nii.gz ]; then 
# echo  "LN2_LAYERDIMENSION.py --input $analysis_dir/$f/mean/inv_pe1.fwhm7.nii.gz --columns  /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii --layers /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" >> swarm.getDist


# fi
# done 

# cat $analysis_dir/swarm.getDist  | wc -l 


# swarm -f $analysis_dir/swarm.getDist_test -g 10  --job-name getDist --time 00:30:00 

# 34000087

# 34000621



# # swarm -f swarm.post -g 10 --job-name feat_post --time 00:30:00





# #pes=($(find $analysis_dir -name inv_pe1.fwhm7.nii.gz))

# pes=($(ls $analysis_dir/fsl_feat_*/mean/inv_pe1.fwhm?.nii.gz))
# echo ${#pes[@]}
# echo ${pes[@]}


# swarm_todataframe=$analysis_dir/swarm_merged/swarm.dataframe 

# rm $swarm_todataframe
# touch $swarm_todataframe 

# for p in ${pes[@]}; do 
# #echo "LN2_todataframe.py --input $p --columns  /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii --layers /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" >> $swarm_todataframe 
# echo "LN2_todataframe.py --input $p --columns  /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b_rmap.scaled2x.nii.gz --layers /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" >> $swarm_todataframe 
# done 

# swarm -f $swarm_todataframe -g 10 --job-name todataframe --time 00:30:00

