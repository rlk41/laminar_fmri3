import numpy as np 
from glob import glob 
import matplotlib 

import matplotlib.pyplot as plt
import numpy as np
import os 
import pandas as pd 


work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons"
dataframe_dir   =work_dir+"/dataframes"
out_dir         =work_dir+"/out"
plot_dir        =work_dir+"/plots_001"
data_dir        =work_dir+"/data"

#os.makedirs(plot_dir, exist_ok=True)
lab_dict_full = pd.read_csv(data_dir"LUT_hcp-mmp-b_v2.txt",sep=" ", header=None, names=["id", "lab", "a", "b", "c","d"])
lab_dict_full = dict(zip(lab_dict_full['id'].to_list(), lab_dict_full['lab'].to_list()))

lab_dict = {
1090:"L_10pp",
#1088:"L_10v", 
#1065:"L_10r", 
#1072:"L_10d",  
1087:"L_9a",  
#1071:"L_9p",  
#1069:"L_9m",  
#1086:"L_9-46d",  
1070:"L_8BL",  
#1063:"L_8BM",  
#1067:"L_8Av",  
#1073:"L_8C",  
#1068:"L_8Ad",  
1010:"L_FEF",  
#1042:"L_7AL",  
#1047:"L_7PC",  
1046:"L_7PL",  
#1029:"L_7Pm",  
#1045:"L_7Am",  
#1030:"L_7m",  
1006:"L_V4",  
#1007:"L_V8",  
#1016:"L_V7",  
#1003:"L_V6",  
1153:"L_V6A",  
1023:"L_MT",  

#8109:"lh.LGN",  

1001:"L_V1",  
#1004:"L_V2",  
1005:"L_V3",  
#1013:"L_V3A",  
#1019:"L_V3B",  
#1159:"L_V3CD",  

#1048:"L_LIPv",  
1095:"L_LIPd", 
}
inv_lab_dict = {v: k for k, v in lab_dict.items()}

ids, labs = [],[]
for k,v in lab_dict.items():
    ids.append(k), labs.append(v)

len_x, len_y = 3, 5 
# layers 7=csf, 1=WM

fsl_base=data_dir+"/feat_001"
df_tstat        =fsl_base+"/stats/tstat1-sub-02_layers-parc_hcp_kenshu-means.npy"
df_zstat        =fsl_base+"/stats/zstat1-sub-02_layers-parc_hcp_kenshu-means.npy"
df_pe           =fsl_base+"/stats/pe1-sub-02_layers-parc_hcp_kenshu-means.npy"
df_thresh_zstat =fsl_base+"/thresh_zstat1-sub-02_layers-parc_hcp_kenshu-means.npy"

#raw 
f="raw_pca001_v2"
tr="TR5"

df_corr=out_dir+'/{}/sub-02_ses-04_task-movie_run-04_VASO-sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_001.1D-CORR-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
df_corr_deconv_coefs=out_dir+'/{}/deconv_{}_Coef-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
df_corr_deconv_fstat=out_dir+'/{}/deconv_{}_Fstat-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
df_corr_deconv_fullr2=out_dir+'/{}/deconv_{}_FULLR2-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)

# preprocessed
f="preprocessed_pca001_v2"
tr="TR5"

df_corr_preproc=out_dir+"/{}/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_001.1D-CORR-sub-02_layers-parc_hcp_kenshu-means.npy".format(f)
df_corr_preproc_deconv_coefs=out_dir+'/{}/deconv_{}_Coef-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
df_corr_preproc_deconv_fstat=out_dir+'/{}/deconv_{}_Fstat-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
df_corr_preproc_deconv_fullr2=out_dir+'/{}/deconv_{}_FULLR2-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
