
"""
FEF averages - made changes to layzii to remove analysis_dir
"""



source_wholebrain2.0


note="aim1_v4.0-V4Abstract-AVEPERMS"
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


# 3dcalc -a $layers -expr 'equals(a,1)' -overwrite -prefix l01.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,2)' -overwrite -prefix l02.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,3)' -overwrite -prefix l03.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,4)' -overwrite -prefix l04.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,5)' -overwrite -prefix l05.nii.gz 
# 3dcalc -a $layers -expr 'equals(a,6)' -overwrite -prefix l06.nii.gz 


# 3dcalc -a $parc_hcp_kenshu -expr 'equals(a,1010)' -overwrite -prefix FEF.nii.gz


# 3dcalc -a FEF.nii.gz -b $columns -expr 'equals(a,1) * b' -overwrite -prefix FEF.columns.nii.gz 

# fslmaths $layers -mas FEF.nii.gz  FEF_layers.nii.gz 

# 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,1)' -overwrite -prefix FEF.l01.nii.gz 
# 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,2)' -overwrite -prefix FEF.l02.nii.gz 
# 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,3)' -overwrite -prefix FEF.l03.nii.gz 
# 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,4)' -overwrite -prefix FEF.l04.nii.gz 
# 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,5)' -overwrite -prefix FEF.l05.nii.gz 
# 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,6)' -overwrite -prefix FEF.l06.nii.gz 



# rois=(
#     $roi_dir/FEF.l*.nii.gz
#     $roi_dir/FEF.nii.gz
# )



rois=($rois_hcp/1090.L_10pp.nii
        $rois_hcp/1088.L_10v.nii
        $rois_hcp/1065.L_10r.nii
        $rois_hcp/1072.L_10d.nii
        $rois_hcp/1087.L_9a.nii
        $rois_hcp/1071.L_9p.nii
        $rois_hcp/1069.L_9m.nii
        $rois_hcp/1086.L_9-46d.nii
        $rois_hcp/1070.L_8BL.nii
        $rois_hcp/1063.L_8BM.nii
        $rois_hcp/1067.L_8Av.nii
        $rois_hcp/1073.L_8C.nii
        $rois_hcp/1068.L_8Ad.nii
        $rois_hcp/1010.L_FEF.nii
        $rois_hcp/1042.L_7AL.nii
        $rois_hcp/1047.L_7PC.nii
        $rois_hcp/1046.L_7PL.nii
        $rois_hcp/1029.L_7Pm.nii
        $rois_hcp/1045.L_7Am.nii
        $rois_hcp/1030.L_7m.nii
        $rois_hcp/1006.L_V4.nii
        $rois_hcp/1007.L_V8.nii
        $rois_hcp/1016.L_V7.nii
        $rois_hcp/1003.L_V6.nii
        $rois_hcp/1152.L_V6A.nii
        $rois_hcp/1023.L_MT.nii
        $rois_thalamic/8109.lh.LGN.nii
        $rois_hcp/1001.L_V1.nii
        $rois_hcp/1004.L_V2.nii
        $rois_hcp/1005.L_V3.nii
        $rois_hcp/1013.L_V3A.nii
        $rois_hcp/1019.L_V3B.nii
        $rois_hcp/1158.L_V3CD.nii
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
pca_num=0

for i in "${types[@]}"; do 
for s in 10; do 
for j in $(seq 0 1 5); do 

echo $s $j $i 
#dir="$analysis_dir/FEF_${i}_pc${pca_num}_rand${s}_${j}"

pca_num_pad="$(printf "%02d\n" $pca_num)"
s="$(printf "%02d\n" $s)"
j="$(printf "%02d\n" $j)"

dir_emp="$analysis_dir/FEF_${i}_pc${pca_num_pad}_rand${s}_iter${j}_empircal"
dir_null="$analysis_dir/FEF_${i}_pc${pca_num_pad}_rand${s}_iter${j}_null"


echo "layZii_aim1.sh -r $roi_list -p $pca_num -i $i -s $s -d $dir_emp" | tee -a $submit_layzii;
echo "layZii_aim1.sh -r $roi_list -p $pca_num -i $i -s $s -d $dir_null -N" | tee -a $submit_layzii;

done 
done 
done




cat $submit_layzii

dep_layzii=$(swarm -b 10 -f $submit_layzii -g 10 --job-name 00layzii )



