#!/bin/bash 

#fsl_design_file=$1

# EPI=$EPI_4d
# timeseries=$t 
# feat_dir=$fsl_feat_out

source /home/kleinrl/projects/laminar_fmri/paths_wholebrain2.0

set -e 


EPI=$1
timeseries=$2
feat_dir=$3

# addded mask option


B=1 # B="False"


print_usage() {
  printf "Usage: ..."
}

while getopts 'B' flag; do
  case "${flag}" in
    B) B=1 ;;


    *) print_usage
       exit 1 ;;
  esac
done

echo "    "

echo "PARAMETERS:"
echo "    "
echo "B:        $B"





cd $feat_dir


#out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"
generated_fsl_design_file="$feat_dir/design.fsf"

log="$feat_dir/logs/fsl_feat.log"
log_dir="$feat_dir/logs"


echo "Running design.fsf ${1}"
echo "EPI:          $EPI"
echo "feat_dir:     $feat_dir "
echo "design_file:  $generated_fsl_design_file"
echo "log:          $log"


mkdir -p $feat_dir 
mkdir -p $log_dir


echo "mkdir feat_dir: $feat_dir  " | tee -a $log 



if [ -f $generated_fsl_design_file ]; then 
  rm $generated_fsl_design_file
fi 



generate_FSLFeat_design2.sh $EPI $timeseries $feat_dir > $generated_fsl_design_file

echo "running feat" | tee -a $log 


export NOBATCH=false
export FSL_MEM=20
export TMPDIR=${SLURM_JOB_ID}

feat $generated_fsl_design_file  

cd $feat_dir.feat


/usr/local/apps/fsl/6.0.4/bin/film_gls --in=filtered_func_data \
--rn=stats --pd=design.mat --thr=1000.0 --sa --ms=5 \
--con=design.con --outputPWdata



