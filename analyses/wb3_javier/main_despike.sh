
source_wholebrain2.0 


#export work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons/"
#export work_dir="./"
export work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_javier"


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
export test_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_javier/data_test_despike"



cd $work_dir 

cd $test_dir 

log_NEW=$test_dir/"log_NEW"
log_NEW25=$test_dir/"log_NEW25"
log_OLD=$test_dir/"log_OLD"



'''
TEST DESPIKE 
'''

3dDespike -NEW -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_NEW.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii >> $log_NEW &
3dDespike -OLD -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_OLD.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii >> $log_NEW25 &
3dDespike -NEW25 -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_NEW25.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii >> $log_OLD &


# NO MASK 
3dDespike -NEW -nomask -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_NEW_nomask.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii &
3dDespike -OLD -nomask -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_OLD_nomask.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii &
3dDespike -NEW25 -nomask -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_NEW25_nomask.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii &




# ------------------
# Outline of Method:
# ------------------
#  * L1 fit a smooth-ish curve to each voxel time series
#     [see -corder option for description of the curve]
#     [see -NEW option for a different & faster fitting method]
#  * Compute the MAD of the difference between the curve and
#     the data time series (the residuals).
#  * Estimate the standard deviation 'sigma' of the residuals
#     from the MAD.
#  * For each voxel value, define s = (value-curve)/sigma.
#  * Values with s > c1 are replaced with a value that yields
#     a modified s' = c1+(c2-c1)*tanh((s-c1)/(c2-c1)).
#  * c1 is the threshold value of s for a 'spike' [default c1=2.5].
#  * c2 is the upper range of the allowed deviation from the curve:
#     s=[c1..infinity) is mapped to s'=[c1..c2)   [default c2=4].




3dDespike -NEW -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_NEW.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii
3dDespike -OLD -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_OLD.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii



'''

[kleinrl@cn2877 data_test_despike]$ 3dDespike -NEW -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_NEW.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii 
sub-02_ses-11_task-movie_run-01_VASO_spc_despike_O++ 3dDespike: AFNI version=AFNI_22.3.03 (Oct 13 2022) [64-bit]
++ Authored by: RW Cox
LD.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii
3dDespike -NEW25 -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_NEW25.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii
*+ WARNING:   If you are performing spatial transformations on an oblique dset,
  such as /gpfs/gsfs12/users/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_javier/data_test_despike/sub-02_ses-11_task-movie_run-01_VASO_spc.nii,
  or viewing/combining it with volumes of differing obliquity,
  you should consider running: 
     3dWarp -deoblique 
  on this and  other oblique datasets in the same session.
 See 3dWarp -help for details.
++ Oblique dataset:/gpfs/gsfs12/users/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_javier/data_test_despike/sub-02_ses-11_task-movie_run-01_VASO_spc.nii is 4.400017 degrees from plumb.
++ ignoring first 0 time points, using last 180
++ using 180 time points => -corder 6
++ Loading dataset sub-02_ses-11_task-movie_run-01_VASO_spc.nii

++ 2291746 voxels in the automask [out of 4303040 in dataset]
++ 2779066 voxels in the dilated automask [out of 4303040 in dataset]
++ Procesing time series with NEW model fit algorithm
++ smash edit thresholds: 3.1 .. 5.0 MADs
 +   [ 3.457% .. 0.072% of normal distribution]
 +   [ 8.839% .. 3.125% of Laplace distribution]
++ start OpenMP thread #0
....................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
++ Elapsed despike time =  1m 9s 299ms

++ FINAL: 475598520 data points, 38861622 edits [8.171%], 16105717 big edits [3.386%]
++ Output dataset ./sub-02_ses-11_task-movie_run-01_VASO_spc_despike_NEW.nii

'''


'''
kleinrl@cn2877 data_test_despike]$ 3dDespike -OLD -prefix sub-02_ses-11_task-movie_run-01_VASO_spc_despike_OLD.nii sub-02_ses-11_task-movie_run-01_VASO_spc.nii
++ 3dDespike: AFNI version=AFNI_22.3.03 (Oct 13 2022) [64-bit]
++ Authored by: RW Cox
*+ WARNING:   If you are performing spatial transformations on an oblique dset,
  such as /gpfs/gsfs12/users/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_javier/data_test_despike/sub-02_ses-11_task-movie_run-01_VASO_spc.nii,
  or viewing/combining it with volumes of differing obliquity,
  you should consider running: 
     3dWarp -deoblique 
  on this and  other oblique datasets in the same session.
 See 3dWarp -help for details.
++ Oblique dataset:/gpfs/gsfs12/users/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_javier/data_test_despike/sub-02_ses-11_task-movie_run-01_VASO_spc.nii is 4.400017 degrees from plumb.
++ ignoring first 0 time points, using last 180
++ using 180 time points => -corder 6
++ Loading dataset sub-02_ses-11_task-movie_run-01_VASO_spc.nii
++ 2291746 voxels in the automask [out of 4303040 in dataset]
++ 2779066 voxels in the dilated automask [out of 4303040 in dataset]
++ Procesing time series with OLD model fit algorithm
++ smash edit thresholds: 3.1 .. 5.0 MADs
 +   [ 3.457% .. 0.072% of normal distribution]
 +   [ 8.839% .. 3.125% of Laplace distribution]
++ start OpenMP thread #0
......................................................................................................................................................................................................................................................................................................................................................................
'''




