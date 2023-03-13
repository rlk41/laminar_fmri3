#!/bin/bash 

timeseries_maindir=$1
epi=$2
roi=$3

echo "$timeseries_maindir $epi $roi"

timeseries_dir=$timeseries_maindir/$(basename $epi .nii.gz)
timeseries_2D="$timeseries_dir/$(basename $epi .nii.gz)-$(basename $roi .nii).2D"
timeseries_2D_null=${timeseries_2D}.perm
timeseries_1D_mean_null=${timeseries_2D}.mean.perm
timeseries_1D_mean=${timeseries_2D}.mean

mkdir -p $timeseries_dir
cd $timeseries_dir


3dmaskave -quiet -mask $roi $epi > $timeseries_1D_mean


3dmaskdump -noijk -mask $roi -o $timeseries_2D -overwrite $epi 

2D_rotate_timeseries.py --input $timeseries_2D 

get_pcas.py --file $timeseries_2D   #--var 0.50
get_pcas.py --file $timeseries_2D_null   #--var 0.50

