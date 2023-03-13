
source_wholebrain2.0 


#export work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons/"
#export work_dir="./"
export work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_afni"
# "/data/NIMH_scratch/kleinrl/

export data_dir=$work_dir/data
export out_dir=$work_dir/out
export roi_dir=$work_dir/rois
export timeseries_maindir=$work_dir/timeseries 
export swarm_dir=$work_dir/swarms

mkdir -p $work_dir $data_dir $roi_dir $timeseries_maindir $swarm_dir

export layers=$roi_dir/sub-02_layers.nii
export rim=$roi_dir/sub-02_layers_bin.nii.gz
export parc_hcp_kenshu=$roi_dir/parc_hcp_kenshu.nii.gz

export VASO_grandmean=$data_dir/VASO_grandmean_spc.nii

cd $work_dir 



###############
# functions 
################

compare_metrics () {

  #set -e 

  local epi=$1
  local seed=$2
  local out_dir=$3

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



  # LN2_PROFILE -input $out_file_corr \
  # -layers $roi_dir/LIPd_layers.nii \
  # -plot -output $out_dir/$epi_base-$seed_base-LIPd-corr-profile.txt

  # LN2_PROFILE -input deconv_FULLR2.nii \
  # -layers $roi_dir/LIPd_layers.nii \
  # -plot -output $out_dir/$epi_base-$seed_base-LIPd-deconv0-profile.txt
  
  # LN2_PROFILE -input deconv_Fstat.nii \
  # -layers $roi_dir/LIPd_layers.nii \
  # -plot -output $out_dir/$epi_base-$seed_base-LIPd-deconv1-profile.txt
  
  # LN2_PROFILE -input deconv_Coef.nii \
  # -layers $roi_dir/LIPd_layers.nii \
  # -plot -output $out_dir/$epi_base-$seed_base-LIPd-deconv2-profile.txt



}

get_seeds () {

  roi=$1
  epi=$2
  timeseries_maindir=$3

  epi_base=$(basename $(basename $epi .nii.gz) .nii) 
  roi_base=$(basename $(basename $roi .nii.gz) .nii)

  local timeseries_dir="$timeseries_maindir/$epi_base"
  local timeseries_2D="$timeseries_dir/$epi_base-$roi_base.2D"
  local timeseries_2D_mean="$timeseries_dir/$epi_base-$roi_base.2D.mean"
  local timeseries_2D_null="${timeseries_2D}.perm"
  local timeseries_1D_mean_null="${timeseries_2D}.mean.perm"

  mkdir -p $timeseries_dir
  cd $timeseries_dir
  
  3dmaskdump -noijk -mask $roi -o $timeseries_2D -overwrite $epi 

  3dmaskave -quiet -mask $roi $epi > $timeseries_2D_mean

  2D_rotate_timeseries.py --input $timeseries_2D 

  get_pcas.py --file $timeseries_2D   #--var 0.50
  get_pcas.py --file $timeseries_2D_null   #--var 0.50

}





################################
# CALC SIGNAL PCT CHANGE 
################################
swarm_3dtstat=$swarm_dir/3dtstat.swarm
swarm_3ddetrend=$swarm_dir/3ddetrend.swarm
swarm_3dcalc=$swarm_dir/3dcalc.swarm
swarm_log=$swarm_dir/log.swarm 
swarm_timeseries=$swarm_dir/timeseries.swarm
swarm_stdev=$swarm_dir/stdev.swarm
swarm_despike=$swarm_dir/despike.swarm
swarm_stdev=$swarm_dir/stdev2.swarm



rm $swarm_3dcalc $swarm_3ddetrend $swarm_3dtstat $swarm_stdev $swarm_despike
touch $swarm_3dcalc $swarm_3ddetrend $swarm_3dtstat $swarm_stdev $swarm_despike

for f in $data_dir/sub*VASO.nii; do 
echo "3dTstat -mean -prefix $data_dir/$(basename $f .nii)_mean.nii $f" >> $swarm_3dtstat
echo "3dDetrend -polort 2 -prefix $data_dir/$(basename $f .nii)_detrend.nii $f " >> $swarm_3ddetrend
echo "3dcalc -a $data_dir/$(basename $f .nii)_detrend.nii -b $data_dir/$(basename $f .nii)_mean.nii \
-expr 'a/b' -prefix $data_dir/$(basename $f .nii)_spc.nii" >> $swarm_3dcalc

echo "3dTstat -stdev -prefix $data_dir/$(basename $f .nii)_spc_stdev.nii $data_dir/$(basename $f .nii)_spc.nii" >> $swarm_stdev
echo "3dDespike -nomask -NEW25 -prefix $data_dir/$(basename $f .nii)_spc_despike.nii $data_dir/$(basename $f .nii)_spc.nii" >> $swarm_despike
#echo "3dDespike -NEW -prefix $data_dir/$(basename $f .nii)_spc_despike.nii $data_dir/$(basename $f .nii)_spc.nii" >> $swarm_despike

echo "3dTstat -stdev -prefix $data_dir/$(basename $f .nii)_spc_stdev.nii $data_dir/$(basename $f .nii)_spc.nii" >> $swarm_stdev2


# 3dTstat -mean -prefix $data_dir/$(basename $f .nii)_mean.nii $f
# 3dDetrend -polort 3 -prefix $data_dir/$(basename $f .nii)_detrend.nii $f 
# 3dcalc -a $data_dir/$(basename $f .nii)_detrend.nii -a $data_dir/$(basename $f .nii)_mean.nii  \
# -expr 'a/b' -prefix $data_dir/$(basename $f .nii)_spc.nii

done 

cat $swarm_3dcalc | wc 
cat $swarm_3dtstat | wc 
cat $swarm_3ddetrend | wc 
cat $swarm_stdev | wc 
cat $swarm_despike | wc 
cat $swarm_stdev2 | wc 


dep_3ddetrend=$(swarm -f $swarm_3ddetrend   -g 5 -t 1 --job-name detrend --logdir $swarm_log --time 01:00:00 )
dep_3dtstat=$(swarm -f $swarm_3dtstat     -b 10  -g 5 -t 1 --job-name 3dtstat --logdir $swarm_log --time 01:00:00 )

ls $data_dir/*detrend.nii   | wc
ls $data_dir/*mean.nii      | wc 
ls $data_dir/*VASO.nii      | wc 

dep_3dcalc=$(swarm -f $swarm_3dcalc -b 5 -g 5 -t 1 --job-name 3dcalc --logdir $swarm_log --time 01:00:00 )
dep_3dtstat=$(swarm -f $swarm_stdev  -b 10  -g 5 -t 1 --job-name 3dtstat_stdev --logdir $swarm_log --time 01:00:00 )

dep_3ddespike=$(swarm -f $swarm_despike  -b 10  -g 20 -t 20 --job-name 3ddespike --logdir $swarm_log --time 01:00:00 )

dep_3dstdev2=$(swarm -f $swarm_stdev2  -b 10  -g 20 -t 20 --job-name stdev2 --logdir $swarm_log --time 01:00:00 )




"""
module load parallel
parallel --jobs 12 < $swarm_3dcalc
"""

to_mean=($data_dir/*spc.nii)
echo ${#to_mean[@]}
3dMean -prefix VASO_grandmean_spc.nii ${to_mean[@]}
3dTstat -mean -prefix VASO_grandmean_spc_mean.nii VASO_grandmean_spc.nii
# without ses13 
to_mean=($(find $data_dir -type f -name "sub*spc.nii" -not -name "*ses-13*"))
echo ${#to_mean[@]}
3dMean -prefix VASO_grandmean_WITHOUT-ses-13_spc.nii ${to_mean[@]}

###############
## DESPIKED 
###############
to_mean=($data_dir/*spc_despike.nii)
echo ${#to_mean[@]}
3dMean -prefix VASO_grandmean_spc_despike.nii ${to_mean[@]} &

3dTstat -mean -prefix VASO_grandmean_spc_despike_mean.nii VASO_grandmean_spc_despike.nii
# without ses13 
to_mean=($(find $data_dir -type f -name "sub*spc_despike.nii" -not -name "*ses-13*"))
echo ${#to_mean[@]}
3dMean -prefix VASO_grandmean_WITHOUT-ses-13_spc_despike.nii ${to_mean[@]} &















3dmaskave -mask $rim -quiet  $data_dir/VASO_grandmean_WITHOUT-ses-13_spc_despike.nii > $timeseries_maindir/rim_ave_despike.1D

3dDeconvolve -input  $data_dir/VASO_grandmean_WITHOUT-ses-13_spc_despike.nii  \
-mask $rim  \
-num_stimts 1 -stim_file 1 $timeseries_maindir/rim_ave_despike.1D \
-stim_label 1 "seed_tc" \
-rout -fout -tout -bucket deconv_TR0 \
-errts  residual_ts.nii.gz
# regress out global 




for f in $data_dir/sub*spc_despike.nii; do 

f_base=$(basename $f .nii)
GSR_dir=$data_dir/${f_base}_GSR

echo $GSR_dir
mkdir -p $GSR_dir 

cd $GSR_dir 

3dmaskave -mask $rim -quiet  $f > $GSR_dir/rim_ave_despike.1D



3dDeconvolve -input  $f  \
-mask $rim  \
-num_stimts 1 -stim_file 1 $GSR_dir/rim_ave_despike.1D \
-stim_label 1 "seed_tc" \
-rout -fout -tout -bucket deconv_TR0 \
-errts  $GSR_dir/residual_ts.nii.gz



done 


to_mean=($(find $data_dir/ -type f -name "residual_ts.nii.gz" -not -name "*ses-13*"))

to_mean2=()
for f in  ${to_mean[@]}; do 
#echo $f; 
if [[ $f != *ses-13* ]]; then 
echo $f
to_mean2+=($f)
fi
done 


echo ${to_mean2[@]}
echo ${#to_mean2[@]}

3dMean -prefix $data_dir/VASO_grandmean_wo13_spc_GSR.nii ${to_mean2[@]} &



3dinfo $data_dir/VASO_grandmean_wo13_spc_GSR.nii





# 3dmaskave -mask $rim -quiet  $f > $GSR_dir/rim_ave.1D


# 3dDeconvolve -input  $data_dir/VASO_grandmean_WITHOUT-ses-13_spc.nii  \
# -mask $rim  \
# -num_stimts 1 -stim_file 1 $timeseries_maindir/rim_ave.1D \
# -stim_label 1 "seed_tc" \
# -rout -fout -tout -bucket deconv_TR0 \
# -errts  residual_ts.nii.gz


#3dresample -orient RPI -inset deconv_TR51+orig.HEAD[0] -prefix deconv_TR51_FULLR2.nii 

done 



# smooth layers 

for i in $(seq 0 1 180); do 
echo $i

3dresample -orient RPI -inset $data_dir/VASO_grandmean_wo13_spc_GSR.nii[$i] -prefix $data_dir/smoothing/VASO_grandmean_wo13_spc_GSR_$i.nii 

done 


LN2_LAYER_SMOOTH \
    -layer_file $layers \
    -input $data_dir/VASO_grandmean_wo13_spc_GSR.nii \
    -FWHM 1 \
    -output $data_dir/VASO_grandmean_wo13_spc_GSR_FWHM1.nii &


LN2_LAYER_SMOOTH \
    -layer_file $layers \
    -input $data_dir/VASO_grandmean_wo13_spc_GSR.nii \
    -FWHM 3 \
    -output $data_dir/VASO_grandmean_wo13_spc_GSR_FWHM3.nii &


LN2_LAYER_SMOOTH \
    -layer_file $layers \
    -input $data_dir/VASO_grandmean_wo13_spc_GSR.nii \
    -FWHM 5 \
    -output $data_dir/VASO_grandmean_wo13_spc_GSR_FWHM5.nii &

LN2_LAYER_SMOOTH \
    -layer_file $layers \
    -input $data_dir/VASO_grandmean_wo13_spc_GSR.nii \
    -FWHM 7 \
    -output $data_dir/VASO_grandmean_wo13_spc_GSR_FWHM7.nii &






LN2_LAYER_SMOOTH \
    -layer_file $layers \
    -input $data_dir/VASO_grandmean_WITHOUT-ses-13_spc.nii \
    -FWHM 1 \
    -output $data_dir/VASO_grandmean_WITHOUT-ses-13_spc_FWHM1.nii &


LN2_LAYER_SMOOTH \
    -layer_file $layers \
    -input $data_dir/VASO_grandmean_WITHOUT-ses-13_spc.nii \
    -FWHM 3 \
    -output $data_dir/VASO_grandmean_WITHOUT-ses-13_spc_FWHM3.nii &


LN2_LAYER_SMOOTH \
    -layer_file $layers \
    -input $data_dir/VASO_grandmean_WITHOUT-ses-13_spc.nii \
    -FWHM 5 \
    -output $data_dir/VASO_grandmean_WITHOUT-ses-13_spc_FWHM5.nii &

LN2_LAYER_SMOOTH \
    -layer_file $layers \
    -input $data_dir/VASO_grandmean_WITHOUT-ses-13_spc.nii \
    -FWHM 7 \
    -output $data_dir/VASO_grandmean_WITHOUT-ses-13_spc_FWHM7.nii &














LN2_todataframe_byVox.py 




################################
# INSTACORR
#################################


################################
# GET SEED/TARGETS ROIS 
####################################

cd $roi_dir 
cp $layers $roi_dir 

# cp $rois_hcp_kenshu/1010.L_FEF.nii $roi_dir 
# fslmaths $layers -mas 1010.L_FEF.nii  FEF_layers.nii.gz 

# cp $rois_hcp_kenshu/1048.L_LIPv.nii $roi_dir 
# fslmaths $layers -mas $roi_dir/1048.L_LIPv.nii $roi_dir/LIPv_layers.nii.gz 

# cp $rois_hcp_kenshu/1095.L_LIPd.nii $roi_dir 
# fslmaths $layers -mas $roi_dir/1095.L_LIPd.nii $roi_dir/LIPd_layers.nii.gz 


get_seeds $roi_dir/1010.L_FEF.nii $VASO_grandmean $timeseries_maindir
get_seeds $roi_dir/1095.L_LIPd.nii $VASO_grandmean $timeseries_maindir
get_seeds $roi_dir/1048.L_LIPv.nii $VASO_grandmean $timeseries_maindir





# rois=($roi_dir/1010.L_FEF.nii 
#       $roi_dir/1095.L_LIPd.nii 
#       $roi_dir/1048.L_LIPv.nii )

# 3dcalc -a $layers -expr 'equals(a,1)' -overwrite -prefix $roi_dir/l01.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,2)' -overwrite -prefix $roi_dir/l02.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,3)' -overwrite -prefix $roi_dir/l03.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,4)' -overwrite -prefix $roi_dir/l04.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,5)' -overwrite -prefix $roi_dir/l05.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,6)' -overwrite -prefix $roi_dir/l06.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,7)' -overwrite -prefix $roi_dir/l07.nii.gz 


# l1=$roi_dir/l01.nii.gz 
# l2


rois=($rois_hcp_kenshu/*L_V1.nii
$rois_hcp_kenshu/*L_V2.nii
$rois_hcp_kenshu/*L_V3*.nii
$rois_hcp_kenshu/*L_V4.nii
$rois_hcp_kenshu/*L_FST.nii
$rois_hcp_kenshu/*L_PH.nii
$rois_hcp_kenshu/*L_MS.nii

$rois_hcp_kenshu/*L_LO3.nii
$rois_hcp_kenshu/*L_MT.nii
$rois_hcp_kenshu/*L_V4t.nii
$rois_hcp_kenshu/*L_MST.nii

$rois_hcp_kenshu/*L_VIP*.nii
$rois_hcp_kenshu/*L_LIP*.nii
$rois_hcp_kenshu/*L_7*.nii

$rois_hcp_kenshu/*L_FEF.nii)

rois=($rois_hcp_kenshu/*L_MIP.nii)


EPIs=($data_dir/VASO_grandmean_*spc_despike.nii)
EPIs=($data_dir/VASO_grandmean_WITHOUT-ses-13_spc_despike.nii)

EPIs=($data_dir/*spc_despike.nii)

rm -f $swarm_timeseries & touch $swarm_timeseries

echo ${#EPIs[@]}
for roi in ${rois[@]}; do
for epi in ${EPIs[@]}; do 
    echo "extract_and_build_timeseries_v3.sh $timeseries_maindir $epi $roi" >> $swarm_timeseries
done 
done 

cat $swarm_timeseries | wc 
echo ${#EPIs[@]}

dep_timeseries=$(swarm -f $swarm_timeseries -b 40 -g 5 -t 2 --job-name extract_ts --logdir $swarm_log --time 03:00:00 )















cat $seed_file_mean | wc 
cat $seed_file_pca000 | wc 
cat $seed_file_pca001 | wc 

cat $seed_file_mean_preproced_FSL | wc 
cat $seed_file_pca000_preproced_FSL | wc
cat $seed_file_pca001_preproced_FSL | wc 


compare_metrics $run                  $seed_file_pca000                  $out_dir/raw_pca000_v2


