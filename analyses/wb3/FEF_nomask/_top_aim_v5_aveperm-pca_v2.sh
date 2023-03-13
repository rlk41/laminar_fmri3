
"""
FEF averages - made changes to layzii to remove analysis_dir



"""



source_wholebrain2.0


note="aim1_v5.0-FEF_aveperms_1-10x5_iter10_v2"

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
    #$roi_dir/FEF.l*.nii.gz
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



#types=('ave' 'perm')
types=('perm')

pca_num=0

for i in "${types[@]}"; do 
for s in 1 ; do 
for j in $(seq 0 1); do 
for pca_num in 0 ; do 

echo $s $j $i $pca_num
#dir="$analysis_dir/FEF_${i}_pc${pca_num}_rand${s}_${j}"

pca_num_pad="$(printf "%02d\n" $pca_num)"
s_pad="$(printf "%02d\n" $s)"
j_pad="$(printf "%02d\n" $j)"

dir_emp="$analysis_dir/FEF_${i}_pc${pca_num_pad}_rand${s_pad}_iter${j_pad}_empircal"
dir_null="$analysis_dir/FEF_${i}_pc${pca_num_pad}_rand${s_pad}_iter${j_pad}_null"


echo "layZii_aim1.sh -r $roi_list -p $pca_num -i $i -s $s -d $dir_emp" | tee -a $submit_layzii
#echo "layZii_aim1.sh -r $roi_list -p $pca_num -i $i -s $s -d $dir_null -N" | tee -a $submit_layzii;

done 
done 
done
done 






cat $submit_layzii

dep_layzii=$(swarm -b 10 -f $submit_layzii -g 10 --job-name 00layzii )


# submit_layzii_head=$analysis_dir/layzii_head

# head -n 5 $submit_layzii > $submit_layzii_head

# dep_layzii=$(swarm -b 10 -f $submit_layzii_head -g 10 --job-name 00layzii )
