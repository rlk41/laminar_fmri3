#!/bin/bash




basedir=""
data_dir=""




timeseries="/data/NIMH_scratch/kleinrl/analyses/wb3/aim1_v3.0-FEF_averages/FEF_ave_pc0_rand36_6/fsl_feat_FEF.l06.nii.gz_pca0/timeseries/analyses_wb3_aim1_v3.0-FEF_averages_FEF_ave_pc0_rand36_6_fsl_feat_FEF.l06.nii.gz_pca0_rand_sample.nii.gz.1D"

out_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_prewhitten_TR5/"

EPIs=(/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_Preproc/*.nii)

swarm_file="$out_dir/prewhiten.swarm"
swarm_log="$out_dir/prewhiten.log"

rm $swarm_file

for epi in ${EPIs[@]}; do 

    epi_base=$(basename $epi .nii )
    feat_dir="$out_dir/$epi_base"

    mkdir -p $feat_dir

    echo "/home/kleinrl/projects/laminar_fmri/scripts_batch_wholebrain/fsl_feat_job_prewhitten.sh $epi $timeseries $feat_dir" >> $swarm_file
done 

cat $swarm_file
cat $swarm_file | wc 

dep_feat_prewhiten=$(swarm -f $swarm_file -g 30 -t 1 --job-name feat_prewhiten --logdir $swarm_log --time 05:00:00 )



work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5/"
orig=$work_dir"/orig"

batches=$work_dir"/batches"




mkdir -p $work_dir 

mkdir -p $batch5 
mkdir -p $batch10 
mkdir -p $batch15 
mkdir -p $batch20 


 for f in $out_dir/*.feat; do 
 echo $(basename $f .feat); 
 echo $f/stats*/prewhitened_data.nii.gz; 
 cp $f/stats*/prewhitened_data.nii.gz $work_dir/orig/prewhitened_$(basename $f .feat).nii.gz; 
 done 



EPIs=($orig/pre*.nii.gz)
EPIs_size=${#EPIs[@]}

#echo ${EPI_total[@]}
#size=${#EPI_total[@]}

rand_nums=$(seq 0 $(($EPIs_size-1)))

log_dir="$work_dir/logs"
mkdir -p $log_dir

for j in $(seq 1 1 5); do 
for i in $(seq 5 5 20); do 

  echo "Selecting $i  random EPIs " | tee -a $log 
  selected_EPIs=()
  indexes=""
  log="$log_dir/batch${i}_iter${j}.log"
  rm -f $log & touch $log

  for i in $(seq 1 $i ); do 
    index=$(($RANDOM % $EPIs_size))
    EPI_to_add=${EPIs[$index]}
    selected_EPIs+=($EPI_to_add)

    echo $EPI_to_add >> $log 

  done 

  echo $i $j 
  echo $indexes 

  3dMean -prefix "$batches/batch${i}_iter${j}.nii.gz" ${selected_EPIs[@]}
  echo "$indexes" > batch${i}_iter${j}.log 

done 
done 

## Generate Seeds 
timeseries_maindir=$work_dir/timeseries
roi_dir=$work_dir/rois
mkdir -p $roi_dir 
mkdir -p $timeseries_dir 



layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"
rim="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers_bin.nii"

cd $roi_dir 
cp $layers $roi_dir
#cp $columns $roi_dir
cp $parc_hcp_kenshu $roi_dir


3dcalc -a $layers -expr 'equals(a,1)' -overwrite -prefix l01.nii.gz 
3dcalc -a $layers -expr 'equals(a,2)' -overwrite -prefix l02.nii.gz 
3dcalc -a $layers -expr 'equals(a,3)' -overwrite -prefix l03.nii.gz 
3dcalc -a $layers -expr 'equals(a,4)' -overwrite -prefix l04.nii.gz 
3dcalc -a $layers -expr 'equals(a,5)' -overwrite -prefix l05.nii.gz 
3dcalc -a $layers -expr 'equals(a,6)' -overwrite -prefix l06.nii.gz 


3dcalc -a $parc_hcp_kenshu -expr 'equals(a,1010)' -overwrite -prefix FEF.nii.gz


3dcalc -a FEF.nii.gz -b $columns -expr 'equals(a,1) * b' -overwrite -prefix FEF.columns.nii.gz 

fslmaths $layers -mas FEF.nii.gz  FEF_layers.nii.gz 

3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,1)' -overwrite -prefix FEF.l01.nii.gz 
3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,2)' -overwrite -prefix FEF.l02.nii.gz 
3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,3)' -overwrite -prefix FEF.l03.nii.gz 
3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,4)' -overwrite -prefix FEF.l04.nii.gz 
3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,5)' -overwrite -prefix FEF.l05.nii.gz 
3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,6)' -overwrite -prefix FEF.l06.nii.gz 


rois=(
    $roi_dir/FEF.l*.nii.gz
    $roi_dir/FEF.nii.gz
)

rois2=($rois_hcp/*.L_10pp.nii
        $rois_hcp/*.L_10v.nii
        $rois_hcp/*.L_10r.nii
        $rois_hcp/*.L_10d.nii
        $rois_hcp/*.L_9a.nii
        $rois_hcp/*.L_9p.nii
        $rois_hcp/*.L_9m.nii
        $rois_hcp/*.L_9-46d.nii
        $rois_hcp/*.L_8BL.nii
        $rois_hcp/*.L_8BM.nii
        $rois_hcp/*.L_8Av.nii
        $rois_hcp/*.L_8C.nii
        $rois_hcp/*.L_8Ad.nii
        $rois_hcp/*.L_FEF.nii
        $rois_hcp/*.L_7AL.nii
        $rois_hcp/*.L_7PC.nii
        $rois_hcp/*.L_7PL.nii
        $rois_hcp/*.L_7Pm.nii
        $rois_hcp/*.L_7Am.nii
        $rois_hcp/*.L_7m.nii
        $rois_hcp/*.L_V4.nii
        $rois_hcp/*.L_V8.nii
        $rois_hcp/*.L_V7.nii
        $rois_hcp/*.L_V6.nii
        $rois_hcp/*.L_V6A.nii
        $rois_hcp/*.L_MT.nii
        $rois_thalamic/8109.lh.LGN.nii
        $rois_hcp/*.L_V1.nii
        $rois_hcp/*.L_V2.nii
        $rois_hcp/*.L_V3.nii
        $rois_hcp/*.L_V3A.nii
        $rois_hcp/*.L_V3B.nii
        $rois_hcp/*.L_V3CD.nii
)

rois2=(

)

#mask="$rois_hcp_kenshu/1010.L_FEF.nii"
#mask_base=$(basename $mask .nii) 






#EPIs=($batches/*.nii.gz)
EPIs=($orig/pre*.nii.gz)
for epi in ${EPIs[@]}; do 

    timeseries_dir=$timeseries_maindir/$(basename $epi .nii.gz)
    timeseries_2D="$timeseries_dir/$mask_base.2D"
    timeseries_2D_null=${timeseries_2D}.perm
    timeseries_1D_mean_null=${timeseries_2D}.mean.perm

    mkdir -p $timeseries_dir
    cd $timeseries_dir
    

    3dmaskdump -noijk -mask $mask -o $timeseries_2D -overwrite $epi 

    2D_rotate_timeseries.py --input $timeseries_2D 

    get_pcas.py --file $timeseries_2D   #--var 0.50
    get_pcas.py --file $timeseries_2D_null   #--var 0.50

done 



work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5/"
orig=$work_dir"/orig"
layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"
rim="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers_bin.nii"

EPIs=($orig/pre*.nii.gz)
swarm_dir=$work_dir/swarm
swarm_submit=$work_dir/swarm/corrs.swarm 
mkdir -p $swarm_dir 
rm -f $swarm_submit & touch $swarm_submit 

seeds=(1010.L_FEF.2D.pca_000.1D 1010.L_FEF.2D.pca_001.1D 1010.L_FEF.2D.pca_002.1D 1010.L_FEF.2D.pca_003.1D 1010.L_FEF.2D.pca_004.1D)
seeds_null=(1010.L_FEF.2D.perm.pca_000.1D 1010.L_FEF.2D.perm.pca_001.1D 1010.L_FEF.2D.perm.pca_002.1D 1010.L_FEF.2D.perm.pca_003.1D 1010.L_FEF.2D.perm.pca_004.1D)
seeds=(${seeds_null[@]} ${seeds[@]})

for seed in ${seeds[@]}; do 
for epi in ${EPIs[@]}; do 

out_dir=$work_dir/corrs/$seed

out_file=$out_dir/$seed-$epi_base.nii.gz 
out_file_REML=$out_dir/$seed-${epi_base}_REML.nii.gz 
out_file_DECONVOLVE=$out_dir/$seed-${epi_base}_DECONVOLVE.nii.gz 
out_file_smoothed1=$out_dir/$seed-$epi_base-SMOOTHED1.nii.gz 
out_file_smoothed3=$out_dir/$seed-$epi_base-SMOOTHED3.nii.gz 
out_file_smoothed5=$out_dir/$seed-$epi_base-SMOOTHED5.nii.gz 



epi_base=$(basename $epi .nii.gz)
seed_file=$timeseries_maindir/$epi_base/$seed 

mkdir -p $out_dir 


echo $out_dir 
echo $out_file 
echo $epi
echo $seed_file


echo "3dTcorr1D -prefix $out_file $epi $seed_filed " #>> $swarm_submit
echo "3dDeconvolve -input $epi -input1D $seed_file -"
echo "3dREMLfit -input $epi -matim $seed_file -Rbeta $out_file_REML"
echo "LN_LAYER_SMOOTH -layer_file $layers -input $out_file -FWHM 1 -output $out_file_smoothed1" >> $swarm_submit 
echo "LN_LAYER_SMOOTH -layer_file $layers -input $out_file -FWHM 3 -output $out_file_smoothed3" >> $swarm_submit 
echo "LN_LAYER_SMOOTH -layer_file $layers -input $out_file -FWHM 5 -output $out_file_smoothed5" >> $swarm_submit 

done 
done 


dep_swarm=$(swarm -b 10 -f $swarm_submit -g 10 --job-name corrs )

dep_swarm=$(swarm -b 50 -f $swarm_submit -g 10 --job-name LN_SMOOTH )








for timeseries in timeseries_dir; do 
for epi in EPIs; so 
    
    epi_base=$(basename $epi .nii.gz)

    3dDeconvolve 
    3dTcorr1D

    3dDeconvolve
    3dTcorr1D



# extract seed
# extract null 




# GrandMean 





# Permute 





    get_pcas.py --file $timeseries_2D   #--var 0.50

    ts=(${timeseries_2D}.pca*.1D)


    for t in ${ts[@]:0:$num_pcas}; do 
      for e_num in $EPI_tocompare; do 

        e=${EPIs[$e_num]}

        e_pre=$(echo $e | cut -d'/' -f5- )
        e_pre=$(basename "${e_pre////_}" .nii)
        e_pre=$(basename "${e_pre////_}" .nii.gz)

        if [ $C -eq 1 ]; then 


          out_dir_2D="$out_dir/DAY0/$(basename $t .1D)/$epi_pre-$e_pre.corr"
          

          echo "pca:          $t "  | tee -a $log
          echo "out_dir_2D:   $out_dir_2D"  | tee -a $log

          rm -rf $out_dir_2D*
          mkdir -p $out_dir_2D

          echo "3dTcorr1D -prefix $out_dir_2D/corr.nii.gz  $e $t " >> $swarm_file 
        else 

          out_dir_2D="$out_dir/DAY0/$(basename $t .1D)/$epi_pre-$e_pre"
          

          echo "pca:          $t "  | tee -a $log
          echo "out_dir_2D:   $out_dir_2D"  | tee -a $log

          rm -rf $out_dir_2D*
          mkdir -p $out_dir_2D

          #echo "export NOBATCH=true ; fsl_feat.job.sh $e $t $out_dir_2D" >> $swarm_file 
          #echo "export NOBATCH=true ; fsl_feat.job.sh $e $t $out_dir_2D $fsl_feat_mask" >> $swarm_file 
          echo "fsl_feat.job.sh $e $t $out_dir_2D" >> $swarm_file 
        fi 









# get timeseries 

# corr 

# fit GLM 


# plots

















# data_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2/sub-02_ses-08_task-movie_run-04_VASO"
# data_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/test_film_gls"


# # INIT 
# /usr/local/apps/fsl/6.0.4/bin/fslmaths $data_dir prefiltered_func_data -odt float
# /usr/local/apps/fsl/6.0.4/bin/fslroi prefiltered_func_data example_func 90 1

# # PREPROC2 

# #/usr/local/apps/fsl/6.0.4/bin/mcflirt -in prefiltered_func_data -out prefiltered_func_data_mcf -mats -plots -reffile example_func -rmsrel -rmsabs -spline_final
# #/bin/mkdir -p mc ; /bin/mv -f prefiltered_func_data_mcf.mat prefiltered_func_data_mcf.par prefiltered_func_data_mcf_abs.rms prefiltered_func_data_mcf_abs_mean.rms prefiltered_func_data_mcf_rel.rms prefiltered_func_data_mcf_rel_mean.rms mc
# #/usr/local/apps/fsl/6.0.4/bin/fsl_tsplot -i prefiltered_func_data_mcf.par -t 'MCFLIRT estimated rotations (radians)' -u 1 --start=1 --finish=3 -a x,y,z -w 640 -h 144 -o rot.png
# #/usr/local/apps/fsl/6.0.4/bin/fsl_tsplot -i prefiltered_func_data_mcf.par -t 'MCFLIRT estimated translations (mm)' -u 1 --start=4 --finish=6 -a x,y,z -w 640 -h 144 -o trans.png
# #/usr/local/apps/fsl/6.0.4/bin/fsl_tsplot -i prefiltered_func_data_mcf_abs.rms,prefiltered_func_data_mcf_rel.rms -t 'MCFLIRT estimated mean displacement (mm)' -u 1 -w 640 -h 144 -a absolute,relative -o disp.png
# #/usr/local/apps/fsl/6.0.4/bin/fslmaths prefiltered_func_data_mcf -mas /data/NIMH_scratch/kleinrl/gdown/sub-02_layers_bin.nii.gz prefiltered_func_data_altmasked

# #/usr/local/apps/fsl/6.0.4/bin/fslstats prefiltered_func_data_altmasked -p 2 -p 98
# /usr/local/apps/fsl/6.0.4/bin/fslstats prefiltered_func_data -p 2 -p 98


# /usr/local/apps/fsl/6.0.4/bin/fslmaths prefiltered_func_data -thr 0.1584298 -Tmin -bin mask -odt char

# #/usr/local/apps/fsl/6.0.4/bin/fslstats prefiltered_func_data_mcf -k mask -p 50
# #/usr/local/apps/fsl/6.0.4/bin/fslmaths mask -dilF mask
# #/usr/local/apps/fsl/6.0.4/bin/fslmaths prefiltered_func_data_mcf -mas mask prefiltered_func_data_thresh

# /usr/local/apps/fsl/6.0.4/bin/fslmaths prefiltered_func_data_thresh -mul 10335.5754642 prefiltered_func_data_intnorm
# /usr/local/apps/fsl/6.0.4/bin/fslmaths prefiltered_func_data_intnorm -Tmean tempMean
# /usr/local/apps/fsl/6.0.4/bin/fslmaths prefiltered_func_data_intnorm -bptf 33.3333333333 -1 -add tempMean prefiltered_func_data_tempfilt
# /usr/local/apps/fsl/6.0.4/bin/imrm tempMean
# /usr/local/apps/fsl/6.0.4/bin/fslmaths prefiltered_func_data_tempfilt filtered_func_data
# /usr/local/apps/fsl/6.0.4/bin/fslmaths filtered_func_data -Tmean mean_func
# /bin/rm -rf prefiltered_func_data*


# /data/NIMH_scratch/kleinrl/analyses/wb3/aim1_v3.0-FEF_averages






# mkdir -p custom_timing_files ; /usr/local/apps/fsl/6.0.4/bin/fslFixText /data/NIMH_scratch/kleinrl/analyses/wb3/L_FEF_PERMUTE_FSLFEAT/fsl_feat_1075.L_45_pca10/timeseries//ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-04_task-movie_run-05_VASO.2D.pca_001.1D custom_timing_files/ev1.txt
# /usr/local/apps/fsl/6.0.4/bin/film_gls --in=filtered_func_data --rn=stats --pd=design.mat --thr=1000.0 --sa --ms=5 --con=design.con


#  /usr/local/apps/fsl/6.0.4/bin/film_gls --in=filtered_func_data --rn=stats --pd=design.mat --thr=1000.0 --sa --ms=5 --con=design.con --outputPWdata


# /usr/local/apps/fsl/6.0.4/bin/smoothest -d 178 -m mask -r stats/res4d > stats/smoothness

# /usr/local/apps/fsl/6.0.4/bin/fslmaths stats/zstat1 -mas mask thresh_zstat1
# echo 1425892 > thresh_zstat1.vol
# zstat1: DLH=3.89692 VOLUME=1425892 RESELS=1.18714
# /usr/local/apps/fsl/6.0.4/bin/cluster -i thresh_zstat1 -t 2 --othresh=thresh_zstat1 -o cluster_mask_zstat1 --connectivity=26 --olmax=lmax_zstat1.txt --scalarname=Z -p 0.05 -d 3.89692 --volume=1425892 -c stats/cope1 > cluster_zstat1.txt
# /usr/local/apps/fsl/6.0.4/bin/cluster2html . cluster_zstat1
# /usr/local/apps/fsl/6.0.4/bin/fslstats thresh_zstat1 -l 0.0001 -R 2>/dev/null
# 2.000429 4.299402
# Rendering using zmin=2.000429 zmax=4.299402
# /usr/local/apps/fsl/6.0.4/bin/overlay 1 0 example_func -a thresh_zstat1 2.000429 4.299402 rendered_thresh_zstat1
# /usr/local/apps/fsl/6.0.4/bin/slicer rendered_thresh_zstat1 -A 750 rendered_thresh_zstat1.png
# /bin/cp /usr/local/apps/fsl/6.0.4/etc/luts/ramp.gif .ramp.gif

# mkdir -p tsplot ; /usr/local/apps/fsl/6.0.4/bin/tsplot . -f filtered_func_data -o tsplot


