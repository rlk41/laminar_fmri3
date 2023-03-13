source_wholebrain2.0

cd $scratch_dir
proj_dir="$scratch_dir/A1.1_average"
combs="$proj_dir/combs"


mkdir -p $proj_dir 
mdkir -p $combs 

cd $proj_dir 

EPIs=$(ls $scratch_dir/ds003216-download/derivatives/sub-02/VASO_fun2/*)



for i in $(seq -w 1 50 5 ); do 
for ii in $(seq -w 0 10); do 

echo $i $ii 


mean_dir="$combs/c$i/b$ii"

mkdir -p $mean_dir 

rand_nums=$(seq 0 $(($EPI_total-1)))

#echo "Selecting 20  random EPIs " | tee -a $log 
selected_EPIs=()
for iii in $(seq 1 $i); do 

size=${#EPIs[@]}
index=$(($RANDOM % $size))
selected_EPIs+=(${EPIs[$index]})

done 



# echo ${selected_EPIs[@]} | tee -a $log 
# echo ${selected_EPIs[@]} > $out_dir/selected_EPIs.txt
#echo ${#selected_EPIs[@]} | tee -a $log 


#3dMean -prefix $mean_dir/rand_sample.nii.gz ${selected_EPIs[@]}

echo ${selected_EPIs[@]}

done 
done 



