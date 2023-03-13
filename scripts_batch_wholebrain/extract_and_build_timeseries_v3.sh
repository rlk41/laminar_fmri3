#!/bin/bash 

timeseries_maindir=$1
epi=$2
roi=$3

echo "$timeseries_maindir $epi $roi"

roi_base=$(basename $(basename $roi .nii.gz) .nii)
epi_base=$(basename $(basename $epi .nii.gz) .nii)



timeseries_dir=$timeseries_maindir/${epi_base}
timeseries_2D="$timeseries_dir/${epi_base}-${roi_base}.2D"
timeseries_2D_null=${timeseries_2D}.perm
timeseries_1D_mean_null=${timeseries_2D}.mean.perm
timeseries_1D_mean=${timeseries_2D}.mean


#rm -f $timeseries
# rm -f $roi_dir 

#mkdir -p $roi_dir 
mkdir -p $timeseries_dir

cd $timeseries_dir



fslmaths $layers -mas $roi $roi_dir/${roi_base}_layers.nii.gz

3dcalc -a $roi_dir/${roi_base}_layers.nii.gz -expr 'equals(a,1)' -overwrite -prefix $roi_dir/${roi_base}_l01.nii.gz 
3dcalc -a $roi_dir/${roi_base}_layers.nii.gz -expr 'equals(a,2)' -overwrite -prefix $roi_dir/${roi_base}_l02.nii.gz 
3dcalc -a $roi_dir/${roi_base}_layers.nii.gz -expr 'equals(a,3)' -overwrite -prefix $roi_dir/${roi_base}_l03.nii.gz 
3dcalc -a $roi_dir/${roi_base}_layers.nii.gz -expr 'equals(a,4)' -overwrite -prefix $roi_dir/${roi_base}_l04.nii.gz 
3dcalc -a $roi_dir/${roi_base}_layers.nii.gz -expr 'equals(a,5)' -overwrite -prefix $roi_dir/${roi_base}_l05.nii.gz 
3dcalc -a $roi_dir/${roi_base}_layers.nii.gz -expr 'equals(a,6)' -overwrite -prefix $roi_dir/${roi_base}_l06.nii.gz 
3dcalc -a $roi_dir/${roi_base}_layers.nii.gz -expr 'equals(a,7)' -overwrite -prefix $roi_dir/${roi_base}_l07.nii.gz 


3dmaskave -quiet -mask  $roi_dir/${roi_base}_l01.nii.gz  $epi > "$timeseries_dir/${epi_base}-${roi_base}_l01.1D"
3dmaskave -quiet -mask  $roi_dir/${roi_base}_l02.nii.gz  $epi > "$timeseries_dir/${epi_base}-${roi_base}_l02.1D"
3dmaskave -quiet -mask  $roi_dir/${roi_base}_l03.nii.gz  $epi > "$timeseries_dir/${epi_base}-${roi_base}_l03.1D"
3dmaskave -quiet -mask  $roi_dir/${roi_base}_l04.nii.gz  $epi > "$timeseries_dir/${epi_base}-${roi_base}_l04.1D"
3dmaskave -quiet -mask  $roi_dir/${roi_base}_l05.nii.gz  $epi > "$timeseries_dir/${epi_base}-${roi_base}_l05.1D"
3dmaskave -quiet -mask  $roi_dir/${roi_base}_l06.nii.gz  $epi > "$timeseries_dir/${epi_base}-${roi_base}_l06.1D"
3dmaskave -quiet -mask  $roi_dir/${roi_base}_l07.nii.gz  $epi > "$timeseries_dir/${epi_base}-${roi_base}_l07.1D"



3dmaskdump -noijk -mask  $roi_dir/${roi_base}_l01.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l01.2D" -overwrite $epi 
3dmaskdump -noijk -mask  $roi_dir/${roi_base}_l02.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l02.2D" -overwrite $epi 
3dmaskdump -noijk -mask  $roi_dir/${roi_base}_l03.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l03.2D" -overwrite $epi 
3dmaskdump -noijk -mask  $roi_dir/${roi_base}_l04.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l04.2D" -overwrite $epi 
3dmaskdump -noijk -mask  $roi_dir/${roi_base}_l05.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l05.2D" -overwrite $epi 
3dmaskdump -noijk -mask  $roi_dir/${roi_base}_l06.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l06.2D" -overwrite $epi 
3dmaskdump -noijk -mask  $roi_dir/${roi_base}_l07.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l07.2D" -overwrite $epi 


# xyz 
3dmaskdump -mask  $roi_dir/${roi_base}_l01.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l01.ijk.2D" -overwrite $epi 
3dmaskdump -mask  $roi_dir/${roi_base}_l02.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l02.ijk.2D" -overwrite $epi 
3dmaskdump -mask  $roi_dir/${roi_base}_l03.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l03.ijk.2D" -overwrite $epi 
3dmaskdump -mask  $roi_dir/${roi_base}_l04.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l04.ijk.2D" -overwrite $epi 
3dmaskdump -mask  $roi_dir/${roi_base}_l05.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l05.ijk.2D" -overwrite $epi 
3dmaskdump -mask  $roi_dir/${roi_base}_l06.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l06.ijk.2D" -overwrite $epi 
3dmaskdump -mask  $roi_dir/${roi_base}_l07.nii.gz  -o  "$timeseries_dir/${epi_base}-${roi_base}_l07.ijk.2D" -overwrite $epi 





#2D_rotate_timeseries.py --input $timeseries_2D 

#get_pcas.py --file $timeseries_2D   #--var 0.50
#get_pcas.py --file $timeseries_2D_null   #--var 0.50

