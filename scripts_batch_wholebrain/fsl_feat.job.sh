#!/bin/bash 

#fsl_design_file=$1

# EPI=$EPI_4d
# timeseries=$t 
# feat_dir=$fsl_feat_out

set -e 


EPI=$1
timeseries=$2
feat_dir=$3

# addded mask option
mask=""
mask=$4


B=1 # B="False"


print_usage() {
  printf "Usage: ..."
}

while getopts 'B' flag; do
  case "${flag}" in
    B) B=1 ;;


    *) print_usage
       exit 1 ;;
  esac
done

echo "    "

echo "PARAMETERS:"
echo "    "
echo "B:        $B"





cd $feat_dir


#out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"
generated_fsl_design_file="$feat_dir/design.fsf"

log="$feat_dir/logs/fsl_feat.log"
log_dir="$feat_dir/logs"


echo "Running design.fsf ${1}"
echo "EPI:          $EPI"
echo "feat_dir:     $feat_dir "
echo "design_file:  $generated_fsl_design_file"
echo "log:          $log"


mkdir -p $feat_dir 
mkdir -p $log_dir


echo "mkdir feat_dir: $feat_dir  " | tee -a $log 



if [ -f $generated_fsl_design_file ]; then 
  rm $generated_fsl_design_file
fi 

echo "generating DESIGN.fsf   " | tee -a $log 
echo "     params $EPI $timeseries $feat_dir" | tee -a $log 

#generate_fslFeat_design.sh $EPI $timeseries $feat_dir > $generated_fsl_design_file

# added mask 
#generate_fslFeat_design.mask.sh $EPI $timeseries $feat_dir $mask > $generated_fsl_design_file
#generate_fslFeat_design_mask_quick.sh $EPI $timeseries $feat_dir $mask > $generated_fsl_design_file
#generate_fslFeat_design_quick.sh $EPI $timeseries $feat_dir > $generated_fsl_design_file
generate_FSLFeat_design.sh $EPI $timeseries $feat_dir > $generated_fsl_design_file

echo "running feat" | tee -a $log 


# intiail but cannot get job ids

if [[ $B -eq 0 ]]; then 
  export NOBATCH=true
  echo "NOBATCH=true"
elif [[ $B -eq 1 ]]; then 
  export NOBATCH=false
  echo "NOBATCH=false"

fi 
export FSL_MEM=20
export TMPDIR=${SLURM_JOB_ID}

run_feat=1
if [[ $run_feat -eq 1 ]]; then 
  export NOBATCH=false
  export FSL_MEM=20
  export TMPDIR=${SLURM_JOB_ID}

  feat $generated_fsl_design_file  #| tee -a $log 
else
  echo "export TMPDIR=${SLURM_JOB_ID}; export FSL_MEM=20; feat $generated_fsl_design_file " > $feat_dir/swarm.feat_v2
fi 

# export TMPDIR=${SLURM_JOB_ID}; export FSL_MEM=20; feat $generated_fsl_design_file


# /usr/local/apps/fsl/6.0.4/bin/feat_model design

# mkdir .files;cp /usr/local/apps/fsl/6.0.4/doc/fsl.css .files;cp -r /usr/local/apps/fsl/6.0.4/doc/images .files/images

# /usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 10 -l logs -N feat0_init   /usr/local/apps/fsl/6.0.4/bin/feat /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/design.fsf -D /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat -I 1 -init
# 31157049

# /usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 774 -l logs -N feat2_pre -j 31157049  /usr/local/apps/fsl/6.0.4/bin/feat /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/design.fsf -D /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat -I 1 -prestats
# 31157182

# /usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 109 -l logs -N feat3_film -j 31157182  /usr/local/apps/fsl/6.0.4/bin/feat /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/design.fsf -D /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat -I 1 -stats
# 31157349

# /usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 119 -l logs -N feat4_post -j 31157349  /usr/local/apps/fsl/6.0.4/bin/feat /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/design.fsf -D /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat -poststats 0 
# 31157467

# /usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 1 -l logs -N feat5_stop -j 31157182,31157349,31157467  /usr/local/apps/fsl/6.0.4/bin/feat /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat/design.fsf -D /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat -stop
# 31157667


# cd $feat_dir 

# # echo "Running FEAT - feat_model" | tee -a $log
# # /usr/local/apps/fsl/6.0.4/bin/feat_model design

# # mkdir .files;cp /usr/local/apps/fsl/6.0.4/doc/fsl.css .files;cp -r /usr/local/apps/fsl/6.0.4/doc/images .files/images


# echo "Running FEAT - INIT " | tee -a $log
# #/usr/local/apps/fsl/6.0.4/bin/feat $generated_fsl_design_file -D $feat_dir -I 1 -init 

# dep1=$(/usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 10 -l logs -N feat0_init   /usr/local/apps/fsl/6.0.4/bin/feat $feat_dir -I 1 -init )

# echo "Running FEAT - PRESTATS " | tee -a $log
# # #/usr/local/apps/fsl/6.0.4/bin/feat $generated_fsl_design_file -D $feat_dir -I 1 -prestats 

# dep2=$(/usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 774 -l logs -N feat2_pre -j $dep1  /usr/local/apps/fsl/6.0.4/bin/feat $feat_dir -I 1 -prestats )


# echo "Running FEAT - STATS " | tee -a $log
# # #/usr/local/apps/fsl/6.0.4/bin/feat $generated_fsl_design_file -D $feat_dir -I 1 -stats 

# dep3=$(/usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 109 -l logs -N feat3_film -j $dep2  /usr/local/apps/fsl/6.0.4/bin/feat $feat_dir -I 1 -stats )


# echo "Running FEAT - POSTSTATS " | tee -a $log
# # #/usr/local/apps/fsl/6.0.4/bin/feat $generated_fsl_design_file -D $feat_dir -poststats 0 

# # mkdir -p stats 
# dep4=$(/usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 119 -l logs -N feat4_post -j $dep3  /usr/local/apps/fsl/6.0.4/bin/feat $feat_dir -poststats 0 )

# echo "Running FEAT - STOP " | tee -a $log
# #/usr/local/apps/fsl/6.0.4/bin/feat $generated_fsl_design_file -D $feat_dir -stop

# dep5=$(/usr/local/apps/fsl/6.0.4/bin/fsl_sub -T 1 -l logs -N feat5_stop -j $dep2,$dep3,$dep4  /usr/local/apps/fsl/6.0.4/bin/feat $feat_dir -stop )

# echo "done -- fsl_feat.job.sh" | tee -a $log



# echo $dep5 | tee -a $log_dir/dep5




echo "running cleanup" | tee -a $log

# echo "removing filtered_finc_data.nii.gz" | tee -a $log

# if [ -f $feat_dir.feat/filtered_func_data.nii.gz ]; then 
#   rm -rf $feat_dir.feat/filtered_func_data.nii.gz
# fi 

# echo "removing stats dir" | tee -a $log
# rm -rf $feat_dir.feat/stats

# echo "removing stats dir" | tee -a $log
# if [ -f $feat_dir.feat/stats/res4d.nii.gz ]; then 
#   rm -rf $feat_dir.feat/stats/res4d.nii.gz
# fi 

# echo "removing design files" | tee -a $log
# if [ -f $feat_dir.feat/design* ]; then 
#   rm -rf $feat_dir.feat/design*
# fi 

# echo "removing report files" | tee -a $log
# if [ -f $feat_dir.feat/report* ]; then 
#   rm -rf $feat_dir.feat/report*
# fi 

cd $feat_dir.feat



# rm -rf 	absbrainthresh.txt
# rm -rf 	cluster_mask_zstat1.nii.gz
# rm -rf 	cluster_zstat1.html
# rm -rf 	cluster_zstat1.txt
# rm -rf 	custom_timing_files
# rm -rf 	design.con
# rm -rf 	design_cov.png
# rm -rf 	design_cov.ppm
# rm -rf 	design.frf
# rm -rf 	design.fsf
# rm -rf 	design.mat
# rm -rf 	design.min
# rm -rf 	design.png
# rm -rf 	design.ppm
# rm -rf 	design.trg
# rm -rf 	example_func.nii.gz
# rm -rf 	filtered_func_data.nii.gz
# rm -rf 	lmax_zstat1.txt
# #rm -rf 	logs
# rm -rf 	mask.nii.gz
# rm -rf 	mc
# rm -rf 	mean_func.nii.gz
# rm -rf 	rendered_thresh_zstat1.nii.gz
# rm -rf 	rendered_thresh_zstat1.png
# #rm -rf 	report.html
# #rm -rf 	report_log.html
# #rm -rf 	report_poststats.html
# #rm -rf 	report_prestats.html
# #rm -rf 	report_reg.html
# #rm -rf 	report_stats.html
# rm -rf 	stats
# #rm -rf 	thresh_zstat1.nii.gz
# rm -rf 	thresh_zstat1.vol
# #rm -rf 	tsplot




# rm -rf $feat_dir.feat 	absbrainthresh.txt
# rm -rf $feat_dir.feat 	cluster_mask_zstat1.nii.gz
# rm -rf $feat_dir.feat 	cluster_zstat1.html
# rm -rf $feat_dir.feat 	cluster_zstat1.txt
# rm -rf $feat_dir.feat 	custom_timing_files
# rm -rf $feat_dir.feat 	design.con
# rm -rf $feat_dir.feat 	design_cov.png
# rm -rf $feat_dir.feat 	design_cov.ppm
# rm -rf $feat_dir.feat 	design.frf
# rm -rf $feat_dir.feat 	design.fsf
# rm -rf $feat_dir.feat 	design.mat
# rm -rf $feat_dir.feat 	design.min
# rm -rf $feat_dir.feat 	design.png
# rm -rf $feat_dir.feat 	design.ppm
# rm -rf $feat_dir.feat 	design.trg
# rm -rf $feat_dir.feat 	example_func.nii.gz
# rm -rf $feat_dir.feat 	filtered_func_data.nii.gz
# rm -rf $feat_dir.feat 	lmax_zstat1.txt
# rm -rf $feat_dir.feat 	logs
# rm -rf $feat_dir.feat 	mask.nii.gz
# rm -rf $feat_dir.feat 	mc
# rm -rf $feat_dir.feat 	mean_func.nii.gz
# rm -rf $feat_dir.feat 	rendered_thresh_zstat1.nii.gz
# rm -rf $feat_dir.feat 	rendered_thresh_zstat1.png
# rm -rf $feat_dir.feat 	report.html
# rm -rf $feat_dir.feat 	report_log.html
# rm -rf $feat_dir.feat 	report_poststats.html
# rm -rf $feat_dir.feat 	report_prestats.html
# rm -rf $feat_dir.feat 	report_reg.html
# rm -rf $feat_dir.feat 	report_stats.html
# rm -rf $feat_dir.feat 	stats
# #rm -rf $feat_dir.feat 	thresh_zstat1.nii.gz
# rm -rf $feat_dir.feat 	thresh_zstat1.vol
# rm -rf $feat_dir.feat 	tsplot




# rm -rfv !("thresh_zstat1.nii.gz")

# end 