#!/bin/bash
3dcalc -a dwscaled_layers.nii -expr 'step(a)' -prefix GM_mask.nii
short_me_VASO.sh Av_acrossdays_VASO_LN.nii
3dTcorrMap -input short_Av_acrossdays_VASO_LN.nii.gz -prefix hubness.nii -mask GM_mask.nii


#switching layers amd time
LN2_LAYERDIMENSION -values hubness.nii -columns dwscaled_columns10000.nii -layers dwscaled_layers.nii -singleTR

#layer smoothing
LN_LAYER_SMOOTH -layer_file dwscaled_layers.nii -input hubness_layerdim.nii -FWHM 1


3dpc -prefix pca_hubnes.nii -pcsave 7 smoothed_hubness_layerdim.nii

3dcalc -overwrite -expr 'a' -a pca_hubnes.nii'[0..0]' -prefix 0thpca.nii
3dcalc -overwrite -expr 'a'  -a pca_hubnes.nii'[1..1]' -prefix 1srpca.nii
3dcalc -overwrite -expr 'a'  -a pca_hubnes.nii'[2..2]' -prefix 2ndpca.nii
3dcalc -overwrite -expr 'a'  -a pca_hubnes.nii'[3..3]' -prefix 3rdpca.nii
3dcalc -overwrite -expr 'a'  -a pca_hubnes.nii'[4..4]' -prefix 4thpca.nii
3dcalc -overwrite -expr 'a'  -a pca_hubnes.nii'[5..5]' -prefix 5thpca.nii
3dcalc -overwrite -expr 'a'  -a pca_hubnes.nii'[6..6]' -prefix 6thpca.nii


fslmerge -t megered_pca.nii *pca.nii

3dcalc -a short_smoothed_hubness_layerdim.nii -b dwscaled_layers.nii -expr 'step(b)*5000+a' -prefix offset_smooth_hubness.nii -overwrite
melodic -i offset_smooth_hubness.nii --nomask --nobet -d 5

 # creating fig
gnuplot
plot 'pca_hubnes.nii00.1D' w lines
plot 'pca_hubnes.nii04.1D' w lines
