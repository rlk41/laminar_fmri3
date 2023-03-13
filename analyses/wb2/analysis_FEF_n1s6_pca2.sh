
source_wholebrain2.0

analysis_dir="$my_scratch/analyses/seedLayers_FEF_n1s6_pca2"

mkdir -p $analysis_dir

cd $analysis_dir

parc=$warped_columns_30k

base=$(basename $parc .nii )

roi_dir="$analysis_dir/rois"
mkdir -p $roi_dir 



swarm_submit=$analysis_dir/swarm.submit
swarm_merged_dir=$analysis_dir/swarm_merged
swarm_merged_feat=$swarm_merged_dir/swarm_mearged.feat
swarm_merged_post=$swarm_merged_dir/swarm_merged.post 
swarm_merged_L2D=$swarm_merged_dir/swarm_merged.L2D 

mkdir -p $swarm_merged_dir


# warp_ANTS_resampleNN.sh $columns_30k $EPI_mean
# warp_ANTS_resampleNN.sh $layers_ed_n10 $EPI_mean
# warp_ANTS_resampleNN.sh $parc_hcp $EPI_mean

layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/warped_equi_volume_layers_n10.nii"
columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/warped_columns_ev_30000_borders.nii"
parc="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/warped_hcp-mmp-b_rmap.nii"


cd $roi_dir 

cp $layers $roi_dir
cp $columns $roi_dir
cp $parc $roi_dir


3dcalc -a $layers -expr 'equals(a,1)' -overwrite -prefix l01.nii.gz 
3dcalc -a $layers -expr 'equals(a,2)' -overwrite -prefix l02.nii.gz 
3dcalc -a $layers -expr 'equals(a,3)' -overwrite -prefix l03.nii.gz 
3dcalc -a $layers -expr 'equals(a,4)' -overwrite -prefix l04.nii.gz 
3dcalc -a $layers -expr 'equals(a,5)' -overwrite -prefix l05.nii.gz 
3dcalc -a $layers -expr 'equals(a,6)' -overwrite -prefix l06.nii.gz 
3dcalc -a $layers -expr 'equals(a,7)' -overwrite -prefix l07.nii.gz 
3dcalc -a $layers -expr 'equals(a,8)' -overwrite -prefix l08.nii.gz 
3dcalc -a $layers -expr 'equals(a,9)' -overwrite -prefix l09.nii.gz 
3dcalc -a $layers -expr 'equals(a,10)' -overwrite -prefix l10.nii.gz 

3dcalc -a l01.nii.gz -b l02.nii.gz -c l03.nii.gz -d l04.nii.gz -expr 'or(a,b,c,d)' -overwrite -prefix wm.nii.gz 
3dcalc -b l05.nii.gz -c l06.nii.gz -d l07.nii.gz -expr 'or(b,c,d)' -overwrite -prefix mid.nii.gz 
3dcalc -a l08.nii.gz -b l09.nii.gz -c l10.nii.gz -expr 'or(a,b,c)' -overwrite -prefix csf.nii.gz 



3dcalc -a $parc -expr 'equals(a,10)' -overwrite -prefix FEF.nii.gz


3dcalc -a FEF.nii.gz -b $columns -expr 'equals(a,1) * b' -overwrite -prefix FEF.columns.nii.gz 

3dmaskdump -mask FEF.nii.gz -noijk -o dumpcolumns.txt $columns 

cat dumpcolumns.txt | sort -nu >> dumpcolumns_unqiue.txt

mkdir -p layered_rois
cd layered_rois

while read p; do
  echo "$p"

  3dcalc -a $columns -expr "equals(a,$p)" -overwrite -prefix $c.nii.gz

  3dcalc -a $columns -b ../csf.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.csf.nii.gz
  3dcalc -a $columns -b ../mid.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.mid.nii.gz
  3dcalc -a $columns -b ../wm.nii.gz   -expr "equals(a,$p) * b" -overwrite -prefix $p.wm.nii.gz


done <../dumpcolumns_unqiue.txt


3dcalc -a 13707.wm.nii.gz -b 22746.wm.nii.gz -c 27431.wm.nii.gz -d 17722.wm.nii.gz -expr "or(a,b,c,d)" -overwrite -prefix 13707.22746.27431.17722.wm.nii.gz
3dcalc -a 13707.csf.nii.gz -b 22746.csf.nii.gz -c 27431.csf.nii.gz -d 17722.csf.nii.gz -expr "or(a,b,c,d)" -overwrite -prefix 13707.22746.27431.17722.csf.nii.gz
3dcalc -a 13707.mid.nii.gz -b 22746.mid.nii.gz -c 27431.mid.nii.gz -d 17722.mid.nii.gz -expr "or(a,b,c,d)" -overwrite -prefix 13707.22746.27431.17722.mid.nii.gz


3dcalc -a 13707.22746.27431.17722.wm.nii.gz -b 13707.22746.27431.17722.csf.nii.gz -c 13707.22746.27431.17722.mid.nii.gz \
-expr "or(a,b,c)" -overwrite -prefix seed1.nii.gz

3dcalc -a 13707.22746.27431.17722.wm.nii.gz -b 13707.22746.27431.17722.csf.nii.gz -c 13707.22746.27431.17722.mid.nii.gz \
-expr "a*3+b*2+c*1"  -overwrite -prefix seed1.display.nii.gz


# 13707.22746.27431.17722.wm.nii.gz
# 13707.22746.27431.17722.csf.nii.gz
# 13707.22746.27431.17722.mid.nii.gz

# 13707.22746.27431.17722


#NULLS 
nulls=(19398 13156 22342)
for p in ${nulls[@]}; do 

    echo $p

    3dcalc -a $columns -expr "equals(a,$p)" -overwrite -prefix $p.nii.gz

    3dcalc -a $columns -b $roi_dir/csf.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.csf.nii.gz
    3dcalc -a $columns -b $roi_dir/mid.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.mid.nii.gz
    3dcalc -a $columns -b $roi_dir/wm.nii.gz   -expr "equals(a,$p) * b" -overwrite -prefix $p.wm.nii.gz


done 


3dcalc -a ${nulls[0]}.wm.nii.gz -b ${nulls[1]}.wm.nii.gz   -c ${nulls[2]}.wm.nii.gz  -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz
3dcalc -a ${nulls[0]}.csf.nii.gz -b ${nulls[1]}.csf.nii.gz -c ${nulls[2]}.csf.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz
3dcalc -a ${nulls[0]}.mid.nii.gz -b ${nulls[1]}.mid.nii.gz -c ${nulls[2]}.mid.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz


3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "or(a,b,c)"  -overwrite -prefix null1.nii.gz

3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "a*3+b*2+c*1"  -overwrite -prefix null1.display.nii.gz





nulls=(13695 22040 26126)
for p in ${nulls[@]}; do 

    echo $p

    3dcalc -a $columns -expr "equals(a,$p)" -overwrite -prefix $p.nii.gz

    3dcalc -a $columns -b $roi_dir/csf.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.csf.nii.gz
    3dcalc -a $columns -b $roi_dir/mid.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.mid.nii.gz
    3dcalc -a $columns -b $roi_dir/wm.nii.gz   -expr "equals(a,$p) * b" -overwrite -prefix $p.wm.nii.gz


done 


3dcalc -a ${nulls[0]}.wm.nii.gz -b ${nulls[1]}.wm.nii.gz   -c ${nulls[2]}.wm.nii.gz  -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz
3dcalc -a ${nulls[0]}.csf.nii.gz -b ${nulls[1]}.csf.nii.gz -c ${nulls[2]}.csf.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz
3dcalc -a ${nulls[0]}.mid.nii.gz -b ${nulls[1]}.mid.nii.gz -c ${nulls[2]}.mid.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz


3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "or(a,b,c)"  -overwrite -prefix null2.nii.gz

3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "a*3+b*2+c*1"  -overwrite -prefix null2.display.nii.gz


nulls=(17401 10646 22118)
for p in ${nulls[@]}; do 

    echo $p

    3dcalc -a $columns -expr "equals(a,$p)" -overwrite -prefix $p.nii.gz

    3dcalc -a $columns -b $roi_dir/csf.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.csf.nii.gz
    3dcalc -a $columns -b $roi_dir/mid.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.mid.nii.gz
    3dcalc -a $columns -b $roi_dir/wm.nii.gz   -expr "equals(a,$p) * b" -overwrite -prefix $p.wm.nii.gz


done 


3dcalc -a ${nulls[0]}.wm.nii.gz -b ${nulls[1]}.wm.nii.gz   -c ${nulls[2]}.wm.nii.gz  -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz
3dcalc -a ${nulls[0]}.csf.nii.gz -b ${nulls[1]}.csf.nii.gz -c ${nulls[2]}.csf.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz
3dcalc -a ${nulls[0]}.mid.nii.gz -b ${nulls[1]}.mid.nii.gz -c ${nulls[2]}.mid.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz


3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "or(a,b,c)"  -overwrite -prefix null3.nii.gz

3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "a*3+b*2+c*1"  -overwrite -prefix null3.display.nii.gz



nulls=(20636 29285 20513)
for p in ${nulls[@]}; do 

    echo $p

    3dcalc -a $columns -expr "equals(a,$p)" -overwrite -prefix $p.nii.gz

    3dcalc -a $columns -b $roi_dir/csf.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.csf.nii.gz
    3dcalc -a $columns -b $roi_dir/mid.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.mid.nii.gz
    3dcalc -a $columns -b $roi_dir/wm.nii.gz   -expr "equals(a,$p) * b" -overwrite -prefix $p.wm.nii.gz


done 


3dcalc -a ${nulls[0]}.wm.nii.gz  -b ${nulls[1]}.wm.nii.gz   -c ${nulls[2]}.wm.nii.gz  -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz
3dcalc -a ${nulls[0]}.csf.nii.gz -b ${nulls[1]}.csf.nii.gz -c ${nulls[2]}.csf.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz
3dcalc -a ${nulls[0]}.mid.nii.gz -b ${nulls[1]}.mid.nii.gz -c ${nulls[2]}.mid.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz


3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "or(a,b,c)"  -overwrite -prefix null4.nii.gz

3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "a*3+b*2+c*1"  -overwrite -prefix null4.display.nii.gz



nulls=(13995 24940 14713)
for p in ${nulls[@]}; do 

    echo $p

    3dcalc -a $columns -expr "equals(a,$p)" -overwrite -prefix $p.nii.gz

    3dcalc -a $columns -b $roi_dir/csf.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.csf.nii.gz
    3dcalc -a $columns -b $roi_dir/mid.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.mid.nii.gz
    3dcalc -a $columns -b $roi_dir/wm.nii.gz   -expr "equals(a,$p) * b" -overwrite -prefix $p.wm.nii.gz


done 


3dcalc -a ${nulls[0]}.wm.nii.gz  -b ${nulls[1]}.wm.nii.gz  -c ${nulls[2]}.wm.nii.gz  -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz
3dcalc -a ${nulls[0]}.csf.nii.gz -b ${nulls[1]}.csf.nii.gz -c ${nulls[2]}.csf.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz
3dcalc -a ${nulls[0]}.mid.nii.gz -b ${nulls[1]}.mid.nii.gz -c ${nulls[2]}.mid.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz


3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "or(a,b,c)"  -overwrite -prefix null5.nii.gz
3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "a*3+b*2+c*1"  -overwrite -prefix null5.display.nii.gz



nulls=(13456 21286 10778)
for p in ${nulls[@]}; do 

    echo $p

    3dcalc -a $columns -expr "equals(a,$p)" -overwrite -prefix $p.nii.gz

    3dcalc -a $columns -b $roi_dir/csf.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.csf.nii.gz
    3dcalc -a $columns -b $roi_dir/mid.nii.gz  -expr "equals(a,$p) * b" -overwrite -prefix $p.mid.nii.gz
    3dcalc -a $columns -b $roi_dir/wm.nii.gz   -expr "equals(a,$p) * b" -overwrite -prefix $p.wm.nii.gz


done 


3dcalc -a ${nulls[0]}.wm.nii.gz -b ${nulls[1]}.wm.nii.gz   -c ${nulls[2]}.wm.nii.gz  -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz
3dcalc -a ${nulls[0]}.csf.nii.gz -b ${nulls[1]}.csf.nii.gz -c ${nulls[2]}.csf.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz
3dcalc -a ${nulls[0]}.mid.nii.gz -b ${nulls[1]}.mid.nii.gz -c ${nulls[2]}.mid.nii.gz -expr "or(a,b,c)" -overwrite -prefix ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz


3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "or(a,b,c)"  -overwrite -prefix null6.nii.gz
3dcalc -a ${nulls[0]}.${nulls[1]}.${nulls[2]}.wm.nii.gz -b ${nulls[0]}.${nulls[1]}.${nulls[2]}.csf.nii.gz -c ${nulls[0]}.${nulls[1]}.${nulls[2]}.mid.nii.gz \
-expr "a*3+b*2+c*1"  -overwrite -prefix null6.display.nii.gz



3dcalc -a seed1.display.nii.gz -b null1.display.nii.gz -c null2.display.nii.gz -d null3.display.nii.gz -e null4.display.nii.gz -f null5.display.nii.gz -g null6.display.nii.gz \
-expr "a+b+c+d+e+f+g" -overwrite -prefix seed1.Nulls1-6.display.nii.gz




rois=($(ls $roi_dir/seed1.nii.gz))

rois=($(ls $roi_dir/layered_rois/{seed,null}?.nii.gz))


echo ${rois[@]}
echo ${#rois[@]}




mkdir -p $analysis_dir 
mkdir -p $roi_dir 

swarm_submit=$analysis_dir/swarm.submit
swarm_merged_dir=$analysis_dir/swarm_merged
swarm_merged_feat=$swarm_merged_dir/swarm_mearged.feat
swarm_merged_post=$swarm_merged_dir/swarm_merged.post 
swarm_merged_L2D=$swarm_merged_dir/swarm_merged.L2D 

mkdir -p $swarm_merged_dir


if [ -f $swarm_submit  ]; 
then 
rm $swarm_submit
touch $swarm_submit
else 
touch $swarm_submit
fi 

size=${#rois[@]}

type='pca2'
runs='single'

for start in `seq 0 1 $(( $size - 1 ))`
do    

    roi_path=${rois[$start]} 

    c=$(basename $roi_path .nii)
    c=$(basename $c .nii.gz)

    echo $c


    out_dir=$analysis_dir/fsl_feat_${c}_${type}_${runs}

    mkdir -p $out_dir 


    # echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -A " | tee -a $swarm_submit
    echo "run_laminar_permute_swarm.sh -r $roi_path -p 2 -o $out_dir -X " | tee -a $swarm_submit


done 

# type='pca2'
# runs='all'
# for start in `seq 0 1 $(( $size - 1 ))`
# do    

#     roi_path=${rois[$start]} 

#     c=$(basename $roi_path .nii)
#     c=$(basename $c .nii.gz)

#     echo $c


#     out_dir=$analysis_dir/fsl_feat_${c}_${type}_${runs}

#     mkdir -p $out_dir 


#     # echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -A " | tee -a $swarm_submit
#     echo "run_laminar_permute_swarm.sh -r $roi_path -p 2 -o $out_dir -X -A" | tee -a $swarm_submit


# done 





# for start in $(seq -f "%04g" 0 20)
# do    

#     roi_path=${rois[0]} 

#     c=$(basename $roi_path .nii)

#     echo $c


#     out_dir=$analysis_dir/fsl_feat_${c}_pca10_NULL${start}

#     mkdir -p $out_dir 


#     # echo "run_laminar_permute_swarm.sh -r $roi_path -p 10 -o $out_dir -A " | tee -a $swarm_submit
#     echo "run_laminar_permute_swarm.sh -r $roi_path -p 0 -o $out_dir -X -N -A" | tee -a $swarm_submit


# done 






# this will generate the pcas and file stricture but not run 
# if -X included 
dep_prepare_submit=$(swarm -b 1 -f $swarm_submit -g 10)


#prepare_swarms.sh 

#merge the swarm.feat files together and submit 

#find $analysis_dir -name swarm.feat






if [ -f $swarm_merged_feat  ]; 
then 
rm $swarm_merged_feat
touch $swarm_merged_feat
else 
touch $swarm_merged_feat
fi 




cd $analysis_dir
feats_to_merge=($(find $analysis_dir/fsl_* -name swarm.feat ))

echo ${#feats_to_merge[@]}
size=${#feats_to_merge[@]}

cat ${feats_to_merge[@]} | tee -a $swarm_merged_feat

cat $swarm_merged_feat | wc 



if [ -f $swarm_merged_post  ]; 
then 
rm $swarm_merged_post 
touch $swarm_merged_post
else 
touch $swarm_merged_post
fi 

if [ -f $swarm_merged_L2D ]; 
then 
rm $swarm_merged_L2D
touch $swarm_merged_L2D
else 
touch $swarm_merged_L2D
fi 


for out_dir in $analysis_dir/fsl_feat_*; do 

    # if [ -d $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat ]; 
    # then 
    # echo "EXISTS RUNNING -- $out_dir/DAY1_run1_VASO_LN.2D.pca_001/DAY1_run1_VASO_LN-DAY1_run1_VASO_LN.feat "


    echo "run_laminar_permute_post.sh -d $out_dir -f zstat1.nii.gz" | tee -a $swarm_merged_post 
    echo "run_laminar_permute_post.sh -d $out_dir -f thresh_zstat1.nii.gz" | tee -a $swarm_merged_post 

    s=( 3  )
    dir="$out_dir/mean"
    mkdir -p $dir 
    mkdir -p $dir/logs

    for smoothing in ${s[@]};do 
    echo "L2D.job.sh $dir $smoothing zstat1.nii.gz" | tee -a $swarm_merged_L2D 
    echo "L2D.job.sh $dir $smoothing thresh_zstat1.nii.gz" | tee -a $swarm_merged_L2D 

    done 


    #fi 
done 






dep_merged_feat=$(swarm -f $swarm_merged_feat -g 20 -t 1 --job-name feat_merged --logdir $swarm_merged_dir --time 10:00:00 )


# dep_merged_post=$(swarm -f $swarm_merged_post -g 10 --job-name post_merged --logdir $swarm_merged_dir \
# --time 02:00:00)

dep_merged_post=$(swarm -f $swarm_merged_post -g 10 --job-name swarm_merged_post --logdir $swarm_merged_dir \
--dependency=afterany:$dep_merged_feat --time 02:00:00)


dep_merged_L2D=$(swarm -f $swarm_merged_L2D -g 20  --job-name L2D_merged --logdir $swarm_merged_dir \
--dependency=afterany:$dep_merged_post --time 48:00:00 )











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






# # ###############
# # # build null 
# # #################

# # # create dir 
# # null_dir=$analysis_dir/null_1000
# # mkdir -p $null_dir

# # pes=($(find $analysis_dir/fsl_feat* -name inv_pe1.nii))
# # size=${#pes[@]}

# # echo $size ${pes[1]}

# # null_pes=()

# # for s in `seq 1 1000`; do 
# #     num=$((0 + $RANDOM % $(( $size - 1 )) ))
# #     num_pe=${pes[$num]}
# #     echo $num $num_pe

# #     null_pes+=($num_pe)

# # done 

# # 3dMean -prefix $null_dir/inv_pe1.nii ${null_pes[@]} 
# # 3dinfo $null_dir/inv_pe1.nii


# # # get inv_mean_func.nii in dir 
# # null_means=($(find $analysis_dir -name inv_mean_func.nii ))
# # cp ${null_means[0]} $null_dir/inv_mean_func.nii 





# # if [ -f $swarm_merged_dir/swarm_merged.L2D_null ]; 
# # then 
# # rm $swarm_merged_dir/swarm_merged.L2D_null
# # touch $swarm_merged_dir/swarm_merged.L2D_null
# # else 
# # touch $swarm_merged_dir/swarm_merged.L2D_null
# # fi 


# # s=( 1 3 5 7 8 )

# # mkdir -p $null_dir 
# # mkdir -p $null_dir/logs

# # for smoothing in ${s[@]};do 
# # echo "L2D.job.sh $null_dir $smoothing" | tee -a $swarm_merged_dir/swarm_merged.L2D_null 
# # done 


    

# # swarm -f $swarm_merged_dir/swarm_merged.L2D_null -g 20  --job-name L2DNULL_merged --logdir $null_dir/logs \
# # --time 48:00:00 









# LN2_LAYERDIMENSION.py \
# --input "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.nii.gz" \
# --columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii" \
# --layers "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" 

# cd /data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000

# downsample_2x_NN.sh "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.mean.nii.gz" 
# downsample_2x_NN.sh "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.se.nii.gz" 
# downsample_2x_NN.sh "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.sd.nii.gz" 


# for f in fsl_feat_*; do 
# if [ -f $f/mean/inv_pe1.fwhm7.nii.gz ]; then 
# echo  "LN2_LAYERDIMENSION.py --input $analysis_dir/$f/mean/inv_pe1.fwhm7.nii.gz --columns  /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii --layers /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" >> swarm.getDist


# fi
# done 

# cat $analysis_dir/swarm.getDist  | wc -l 


# swarm -f $analysis_dir/swarm.getDist_test -g 10  --job-name getDist --time 00:30:00 

# 34000087

# 34000621



# # swarm -f swarm.post -g 10 --job-name feat_post --time 00:30:00





# #pes=($(find $analysis_dir -name inv_pe1.fwhm7.nii.gz))

# pes=($(ls $analysis_dir/fsl_feat_*/mean/inv_pe1.fwhm?.nii.gz))
# echo ${#pes[@]}
# echo ${pes[@]}


# swarm_todataframe=$analysis_dir/swarm_merged/swarm.dataframe 

# rm $swarm_todataframe
# touch $swarm_todataframe 

# for p in ${pes[@]}; do 
# #echo "LN2_todataframe.py --input $p --columns  /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii --layers /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" >> $swarm_todataframe 
# echo "LN2_todataframe.py --input $p --columns  /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b_rmap.scaled2x.nii.gz --layers /data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" >> $swarm_todataframe 
# done 

# swarm -f $swarm_todataframe -g 10 --job-name todataframe --time 00:30:00

