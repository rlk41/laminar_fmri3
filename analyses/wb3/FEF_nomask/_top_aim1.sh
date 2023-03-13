


source_wholebrain2.0


note="aim1_v1.0"
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



# layZii_aim1.sh -rois $rois -epi_type "ave"   -runsrand 10 

#layZii_aim1.sh $rois  "ave" 10 

# p - pc_num 
#    p = 0 == average
#    p > 0 == pc compoennets 


submit_layzii=$analysis_dir/submit.layZii
rm -f $submit_layzii 
touch $submit_layzii

echo "
layZii_aim1.sh -r $roi_list -p 0 -i 'ave' -s 10 -d "$analysis_dir/FEF_ave_pc0_rand10"
layZii_aim1.sh -r $roi_list -p 0 -i 'perm' -s 10 -d "$analysis_dir/FEF_perm_pc0_rand10"
" > $submit_layzii


dep_layzii=$(swarm -b 10 -f $submit_layzii -g 10 --job-name 00layzii )





submit_layzii=$analysis_dir/submit.layZii_v2
rm -f $submit_layzii 
touch $submit_layzii

echo "
layZii_aim1.sh -r $roi_list -p 0 -i 'ave' -s 10 -d "$analysis_dir/FEF_ave_pc0_rand10_v2"
layZii_aim1.sh -r $roi_list -p 0 -i 'perm' -s 10 -d "$analysis_dir/FEF_perm_pc0_rand10_v2"
" > $submit_layzii

cat $submit_layzii

dep_layzii=$(swarm -b 10 -f $submit_layzii -g 10 --job-name 00layzii )








layZii_aim1.sh -r $rois     -t "ave"   -s 10    -n

layZii_aim1.sh -rois $rois -epi_type "perm"  -runsrand 10 
layZii_aim1.sh -rois $rois -epi_type "perm"  -runsrand 10 -null 


layZii_aim1.sh -rois $rois -epi_type "ave"   -runsrand 20 

layZii_aim1.sh -rois $rois -epi_type "perm"  -runsrand 20 

layZii_aim1.sh -rois $rois -epi_type "ave"   -runsrand 30 
layZii_aim1.sh -rois $rois -epi_type "perm"  -runsrand 30 






layZii.sh $rois -epi_type "ave"         -runs_start 10 -runs_end 20 
layZii.sh $rois -epi_type "perm_all"    -runs_start 10 -runs_end 20 
layZii.sh $rois -epi_type "perm_diag"   -runs_start 10 -runs_end 20 
layZii.sh $rois -epi_type "perm_horiz"  -runs_start 10 -runs_end 20 





dep=(swarm -f )