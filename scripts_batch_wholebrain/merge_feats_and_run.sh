#!/bin/bash 

set -e 


analysis_dir=$1

# B="true"

# print_usage() {
#   printf "Usage: ..."
# }

# while getopts 'B' flag; do
#   case "${flag}" in
#     B) B="false" ;;

#     *) print_usage
#        exit 1 ;;
#   esac
# done

# echo "    "

# echo "PARAMETERS:"
# echo "    "
# echo "B     $B"





swarm_merged_dir=$analysis_dir/swarm_merged
swarm_merged_feat=$swarm_merged_dir/swarm_merged.feat


mkdir -p $swarm_merged_dir



feats_to_merge=($(find $analysis_dir  -name swarm.feat ))
echo ${#feats_to_merge[@]}

size=${#feats_to_merge[@]}




if [ -f "$swarm_merged_feat" ] ; then
    rm "$swarm_merged_feat"
fi


cat ${feats_to_merge[@]} | tee -a $swarm_merged_feat


cat $swarm_merged_feat | wc 


dep_merged_feat=$(swarm -f $swarm_merged_feat -g 30 -t 1 --job-name feat_merged --logdir $swarm_merged_dir --time 10:00:00 )

# dep_merged_feat=$(swarm -f $/data/NIMH_scratch/kleinrl/analyses/wb3/FEF_grandmean_kenshu_PC0_all0_nomask/swarm_merged/swarm_merged.feat2 -g 30 -t 1 --job-name feat_merg_batch --logdir $swarm_merged_dir --time 10:00:00 )


echo $dep_merged_feat

exit $dep_merged_feat