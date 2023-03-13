

source_wholebrain2.0 

cd /data/NIMH_scratch/kleinrl/gdown/delete_testing_corrs

LUT="/data/NIMH_scratch/kleinrl/gdown/HCPMMP1_LUT_original_RS.txt"
#unpack_parc.sh -r $parc_hcp_kenshu -m $LUT -o $rois_hcp_kenshu



# filter
# whiten 
# corr 
# cluster 

epi="/data/NIMH_scratch/kleinrl/gdown/sub-02_VASO_across_days.nii"
mask=$rois_hcp_kenshu/1010.L_FEF.nii
layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"

mask_layers="/data/NIMH_scratch/kleinrl/gdown/delete_testing_corrs/FEF_layers.nii.gz"
mask=$rois_hcp_kenshu/1010.L_FEF.nii 

layer="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"
rim="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers_bin.nii"

# mask 
# fslmaths p3_norm_FEF_corr.nii.gz  -mas $rim p3_norm_FEF_corr_rim.nii.gz


3dDetrend -prefix p2_norm.nii.gz  -normalize -polort 2 $epi 
3dDetrend -prefix p3_norm.nii.gz  -normalize -polort 3 $epi 
3dDetrend -prefix p1_norm.nii.gz  -normalize -polort 1 $epi 


3dDetrend -prefix p2.nii.gz -polort 2 $epi 
3dDetrend -prefix p3.nii.gz -polort 3 $epi 
3dDetrend -prefix p1.nii.gz -polort 1 $epi 

fslmaths $layers -mas $mask $mask_layers

3dmaskave -quiet -mask $mask p1_norm.nii.gz   > p1_norm_FEF.1D
3dmaskave -quiet -mask $mask p2_norm.nii.gz   > p2_norm_FEF.1D
3dmaskave -quiet -mask $mask p3_norm.nii.gz   > p3_norm_FEF.1D


3dmaskdump -noijk -mask $mask -o p1_norm_FEF.2D -overwrite p1_norm.nii.gz 
get_pcas.py --file p1_norm_FEF.2D

3dmaskdump -noijk -mask $mask -o p2_norm_FEF.2D -overwrite p2_norm.nii.gz 
get_pcas.py --file p2_norm_FEF.2D

3dmaskdump -noijk -mask $mask -o p3_norm_FEF.2D -overwrite p3_norm.nii.gz 
get_pcas.py --file p3_norm_FEF.2D


3dmaskdump -noijk -mask $mask -o p1_FEF.2D -overwrite p1.nii.gz 
get_pcas.py --file p1_FEF.2D

3dmaskdump -noijk -mask $mask -o p2_FEF.2D -overwrite p2.nii.gz 
get_pcas.py --file p2_FEF.2D

3dmaskdump -noijk -mask $mask -o p3_FEF.2D -overwrite p3.nii.gz 
get_pcas.py --file p3_FEF.2D



3dmaskave -quiet -mask $mask p1.nii.gz   > p1_FEF.1D
3dmaskave -quiet -mask $mask p2.nii.gz   > p2_FEF.1D
3dmaskave -quiet -mask $mask p3.nii.gz   > p3_FEF.1D



3dTcorr1D -prefix p3_norm_FEF_corr.nii.gz  p3_norm.nii.gz  p3_norm_FEF.1D

fslmaths p3_norm_FEF_corr.nii.gz  -mas $rim p3_norm_FEF_corr_rim.nii.gz

 
#3dmaskave -quiet -mask $rim  p3_norm_FEF_corr_rim.nii.gz   > p3_norm_FEF_corr_rim.mean
# 3dmaskave -quiet -mask $rim  p3_norm_FEF_corr_rim.nii.gz   > p3_norm_FEF_corr_rim.mean


3dcalc -a $rim -b p3_norm_FEF_corr.nii.gz -expr '(b-mean(a*b))/stdev(a*b)' -prefix p3_norm_FEF_corr_zstat.nii.gz
3dcalc -a $rim -b p3_norm_FEF_corr.nii.gz -expr '(b-mean(step(a)*b))*step(a)' -prefix p3_norm_FEF_corr_zstat.nii.gz -overwrite 




LN2_LAYER_SMOOTH -layer_file $layers -input p3_norm_FEF_corr.nii.gz -FWHM 5 -output p3_norm_FEF_corr_fwhm5.nii.gz 




3dTcorr1D -prefix corrs/p1_norm_FEF_corr.nii.gz  p1_norm.nii.gz  pcs/p1_norm_FEF.2D.pca_000.1D
3dTcorr1D -prefix corrs/p2_norm_FEF_corr.nii.gz  p2_norm.nii.gz  pcs/p2_norm_FEF.2D.pca_000.1D
3dTcorr1D -prefix corrs/p3_norm_FEF_corr.nii.gz  p3_norm.nii.gz  pcs/p3_norm_FEF.2D.pca_000.1D

3dTcorr1D -prefix corrs/p1_norm_FEF_corr_pca001.nii.gz  p1_norm.nii.gz  pcs/p1_norm_FEF.2D.pca_001.1D &
3dTcorr1D -prefix corrs/p2_norm_FEF_corr_pca002.nii.gz  p2_norm.nii.gz  pcs/p2_norm_FEF.2D.pca_001.1D &
3dTcorr1D -prefix corrs/p3_norm_FEF_corr_pca003.nii.gz  p3_norm.nii.gz  pcs/p3_norm_FEF.2D.pca_001.1D &

#3dTcorr1D -prefix corrs/p1_norm_FEF_corr.nii.gz  p1_norm.nii.gz  pcs/p1_norm_FEF.2D.pca_002.1D &
#3dTcorr1D -prefix corrs/p2_norm_FEF_corr.nii.gz  p2_norm.nii.gz  pcs/p2_norm_FEF.2D.pca_002.1D &
3dTcorr1D -prefix corrs/p3_norm_FEF_corr_pca002.nii.gz  p3_norm.nii.gz  pcs/p3_norm_FEF.2D.pca_002.1D &


cluster 


fslmaths corr.nii.gz -thrp 80 corr_thr80.nii.gz 
fslmaths corr.nii.gz -mas corr_thr80.nii.gz corr_thr80_mas.nii.gz 
fslmaths corr_thr80_mas.nii.gz  -mas $rim corr_thr80_mas.nii.gz 

fslmaths corr.nii.gz -thrp 85 corr_thr.nii.gz 
fslmaths corr.nii.gz -mas corr_thr85.nii.gz corr_thr85_mas.nii.gz 
fslmaths corr_thr85_mas.nii.gz  -mas $rim corr_thr85_mas.nii.gz 

fslmaths corr.nii.gz -thrp 90 corr_thr90.nii.gz 
fslmaths corr.nii.gz -mas corr_thr90.nii.gz corr_thr90_mas.nii.gz 
fslmaths corr_thr90_mas.nii.gz  -mas $rim corr_thr90_mas.nii.gz 


LN2_LAYER_SMOOTH -layer_file $layer -input corr_thr80_mas.nii.gz \
-output corr_thr80_mas_fwhm1.nii.gz -FWHM 1 -NoKissing

LN2_LAYER_SMOOTH -layer_file $layer -input corr_thr80_mas.nii.gz  \
-output corr_thr80_mas_fwhm3.nii.gz -FWHM 3 -NoKissing

LN2_LAYER_SMOOTH -layer_file $layer -input corr_thr80_mas.nii.gz  \
-output corr_thr80_mas_fwhm5.nii.gz -FWHM 5 -NoKissing







3dTcorr1D -prefix p1_norm_FEF_corr.nii.gz  p1_norm.nii.gz  p1_norm_FEF.1D


3dTcorr1D -prefix p2_norm_FEF_corr.nii.gz  p2_norm.nii.gz  p2_norm_FEF.1D

3dTcorr1D -prefix p1_FEF_corr.nii.gz  p1.nii.gz  p1_FEF.1D
3dTcorr1D -prefix p2_FEF_corr.nii.gz  p2.nii.gz  p2_FEF.1D
3dTcorr1D -prefix p3_FEF_corr.nii.gz  p3.nii.gz  p3_FEF.1D








cluster 






3dcalc -a $layers -b -expr 'equals(a,1)' -overwrite -prefix l01.nii.gz 








# TODO 
# correct DAY and L2D.job.sh 3 params 

source_wholebrain2.0

analysis_dir="$my_scratch/analyses/wb3/semantics_PC5_diag"
roi_dir="$analysis_dir/rois"

mkdir -p $analysis_dir

cd $analysis_dir


parc=$warped_columns_30k


base=$(basename $parc .nii )

# ls $rois_hcp | grep TE
rois=(
$rois_hcp_kenshu/1010.L_FEF.nii
)

echo ${rois[@]}
echo ${#rois[@]}

mkdir -p $analysis_dir 
mkdir -p $roi_dir 

swarm_submit=$analysis_dir/swarm.submit
touch $swarm_submit

size=${#rois[@]}


for start in `seq 0 1 $(( $size - 1 ))`
do    

    roi_path=${rois[$start]} 

    c=$(basename $roi_path .nii)

    echo $c


    out_dir=$analysis_dir/fsl_feat_${c}_pca10

    mkdir -p $out_dir 


    # echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -A " | tee -a $swarm_submit
    #echo "run_swarm_wb3.sh -r $roi_path -p 10 -o $out_dir -X" | tee -a $swarm_submit
    echo "run_swarm_wb3_permute.sh -r $roi_path -p 5 -C -o $out_dir -X" | tee -a $swarm_submit


done 

swarm_merge_and_run=$analysis_dir/swarm.merge_and_run
echo "merge_feats_and_run.sh $analysis_dir" > $swarm_merge_and_run


post_merge_L2D_job="$analysis_dir/swarm.post_merge_L2D_job"
echo "create_post_merge_and_L2D_jobs.sh $analysis_dir " > $post_merge_L2D_job 


swarm_merged_dir="$analysis_dir/swarm_merged"


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




