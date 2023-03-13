#!/bin/bash



IN=$1
toFILE=$2 


OUT_base=$(basename $IN .nii)
OUT_base=$(basename $OUT_base .nii.gz)

toFILE_base=$(basename $toFILE .nii)
toFILE_base=$(basename $toFILE_base .nii.gz)


OUT="$(dirname $IN)/$OUT_base.resampled2$toFILE_base.nii.gz"

echo "IN:   $IN"
echo "OUT:  $OUT"


# #module load afni
# sdelta_x=$(3dinfo -adi $toFILE)
# sdelta_y=$(3dinfo -adj $toFILE)
# sdelta_z=$(3dinfo -adk $toFILE)

# echo "$sdelta_x"
# echo "$sdelta_y"
# echo "$sdelta_z"

echo "3dresample -master $toFILE -overwrite -prefix $OUT -debug 1 -input $IN"

3dresample -master $toFILE -overwrite -prefix $OUT -debug 1 -input $IN

#3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Li -overwrite -prefix $scaled_EPI -input $EPI






# echo "************* upscaling EPI.nii ******************************"
# echo "requires 'EPI.nii file "
# echo "outputs as scaled_EPI.nii"

# # upsampling script on laynii.com



# #module load afni
# delta_x=$(3dinfo -di EPI.nii)
# delta_y=$(3dinfo -dj EPI.nii)
# delta_z=$(3dinfo -dk EPI.nii)
# sdelta_x=$(echo "(($delta_x / 4))"|bc -l)
# sdelta_y=$(echo "(($delta_x / 4))"|bc -l)
# sdelta_z=$(echo "(($delta_z / 4))"|bc -l)
# echo "$sdelta_x"
# echo "$sdelta_y"
# echo "$sdelta_z"
# 3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Li -overwrite -prefix scaled_EPI.nii -input EPI.nii


