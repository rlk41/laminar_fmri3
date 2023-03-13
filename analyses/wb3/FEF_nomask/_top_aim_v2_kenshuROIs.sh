


source_wholebrain2.0


note="aim1_v2.0"
analysis_dir="$my_scratch/analyses/wb3/${note}"
roi_dir="$analysis_dir/rois"
roi_list="$analysis_dir/roi_list.txt"

mkdir -p $analysis_dir
mkdir -p $roi_dir

cd $analysis_dir
cd $roi_dir 

layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"
rim="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers_bin.nii"

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

echo ${rois[@]}

echo ${rois[@]} >> $roi_list 


echo ${#rois[@]}

for r in ${rois[@]}; do 3dinfo $r; done 

cd $analsysis_dir





submit_layzii=$analysis_dir/submit.layZii
rm -f $submit_layzii 
touch $submit_layzii

types=('ave' 'perm')

for i in "${types[@]}"; do 
for s in $(seq 10 10 50); do 
for j in $(seq 0 1 10); do 
echo $s $j $i 
echo "layZii_aim1.sh -r $roi_list -p 0 -i $i -s $s -d $analysis_dir/FEF_ave_pc0_rand${s}_${j}" | tee -a $submit_layzii;
done 
done 
done




cat $submit_layzii

dep_layzii=$(swarm -b 10 -f $submit_layzii -g 10 --job-name 00layzii )



