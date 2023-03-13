#!/bin/bash 

batchSize=$1; shift 
epis=( "$@" )

echo "arg1=$batchSize"
echo "epis=${epis[@]}"


epiNum=${#epis[@]}



list=()
list=($(awk -v loop=$batchSize -v seed=$RANDOM -v range=$epiNum 'BEGIN{
  srand(seed)
  do {
    numb = 1 + int(rand() * range)
    if (!(numb in prev)) {
       print numb
       prev[numb] = 1
       count++
    }
  } while (count<loop)
}'))

echo ${list[@]}


to_ave=()
for i in ${list[@]}; do 
to_ave+=(${epis[$i]})
done 

printf -v batchSize_pad "%03d" $batchSize

printf -v RANDOM_pad "%05d" $RANDOM


3dMean -prefix RANDRUNS_batchSize${batchSize_pad}_${RANDOM_pad}.nii ${to_ave[@]} 



#i=$((i+1))
#done 

# parallel --jobs 2 < $joblist4
# parallel --jobs 2 < /data/NIMH_scratch/kleinrl/shared/hierClust//data_VASO_averuns/swarm4.jobs 


