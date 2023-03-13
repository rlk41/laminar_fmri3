
data_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5/orig"


to_mean=($data_dir/prewhitened*VASO.nii.gz)
echo ${#to_mean[@]}
3dMean -prefix $data_dir/VASO_grandmean.nii.gz ${to_mean[@]} &
#3dTstat -mean -prefix VASO_grandmean_spc_mean.nii VASO_grandmean_spc.nii
# without ses13 
to_mean=($(find $data_dir -type f -name "prewhitened*VASO.nii.gz" -not -name "*ses-13*"))
echo ${#to_mean[@]}
3dMean -prefix $data_dir/VASO_grandmean_wo13.nii.gz ${to_mean[@]} &

