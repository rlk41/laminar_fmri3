
fslmaths $warp_parc_hcp -mas sub-02_layers_bin.nii.gz warped_masked_hcp.nii.gz
3dmask_tool -dilate_inputs 1 -inputs warped_masked_hcp.nii.gz -prefix warped_masked_inflated_hcp.nii.gz

fslmaths warped_masked_inflated_hcp.nii.gz -mas sub-02_layers_bin.nii.gz warped_masked2_hcp.nii.gz
3dmask_tool -dilate_inputs 1 -inputs warped_masked2_hcp.nii.gz -prefix warped_masked_inflated2_hcp.nii.gz

fslmaths warped_masked_inflated_hcp.nii.gz -mas sub-02_layers_bin.nii.gz warped_masked2_hcp.nii.gz
3dmask_tool -dilate_inputs 1 -inputs warped_masked2_hcp.nii.gz -prefix warped_masked_inflated2_hcp.nii.gz

fslmaths warped_masked_inflated2_hcp.nii.gz -mas sub-02_layers_bin.nii.gz warped_masked3_hcp.nii.gz

3dROIMaker                     \
    -inset warped_masked_hcp.nii.gz     \
    -refset warped_masked_hcp.nii.gz     \
    -prefix warped_masked_inflated_hcp_ROIMaker.nii.gz              \
    -inflate 1          
    

rm warped_masked_inflated_hcp_ROIMaker.nii.gz

3dcalc -a warped_masked_inflated_hcp_ROIMaker.nii.gz_GMI+orig.HEAD \
-prefix warped_masked_inflated_hcp_ROIMaker.nii.gz   -expr 'a' \

fslmaths warped_masked_inflated_hcp_ROIMaker.nii.gz -mas sub-02_layers_bin.nii.gz warped_masked_ROIMaker_hcp.nii.gz


3dROIMaker                     \
    -inset warped_masked_inflated_hcp_ROIMaker.nii.gz     \
    -refset warped_masked_hcp.nii.gz     \
    -prefix warped_masked_inflated_hcp_ROIMaker2.nii.gz              \
    -inflate 1          
    

3dcalc -a warped_masked_inflated_hcp_ROIMaker2.nii.gz_GMI+orig.HEAD \
-prefix warped_masked_inflated_hcp_ROIMaker2.nii.gz   -expr 'a' 

fslmaths warped_masked_inflated_hcp_ROIMaker2.nii.gz -mas sub-02_layers_bin.nii.gz warped_masked_inflated_hcp_ROIMaker3.nii.gz





3dROIMaker                     \
    -inset warped_masked_inflated_hcp_ROIMaker3.nii.gz     \
    -refset warped_masked_hcp.nii.gz     \
    -prefix warped_masked_inflated_hcp_ROIMaker4.nii.gz              \
    -inflate 1          
    

3dcalc -a warped_masked_inflated_hcp_ROIMaker4.nii.gz_GMI+orig.HEAD \
-prefix warped_masked_inflated_hcp_ROIMaker4.nii.gz   -expr 'a' 

fslmaths warped_masked_inflated_hcp_ROIMaker4.nii.gz -mas sub-02_layers_bin.nii.gz warped_masked_inflated_hcp_ROIMaker4.nii.gz




3dROIMaker                     \
    -inset warped_masked_inflated_hcp_ROIMaker4.nii.gz     \
    -refset warped_masked_hcp.nii.gz     \
    -prefix warped_masked_inflated_hcp_ROIMaker4.nii.gz              \
    -inflate 1 -overwrite
    

3dcalc -a warped_masked_inflated_hcp_ROIMaker4.nii.gz_GMI+orig.HEAD \
-prefix warped_masked_inflated_hcp_ROIMaker4.nii.gz   -expr 'a' -overwrite 

fslmaths warped_masked_inflated_hcp_ROIMaker4.nii.gz -mas sub-02_layers_bin.nii.gz warped_masked_inflated_hcp_ROIMaker4.nii.gz

