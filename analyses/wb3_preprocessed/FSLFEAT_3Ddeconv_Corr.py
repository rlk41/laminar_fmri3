
import numpy as np 
from glob import glob 
import matplotlib 

import matplotlib.pyplot as plt
import numpy as np
import os 
import pandas as pd 


work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5"
dataframe_dir=work_dir+"/dataframes"

plot_dir=work_dir+"/plots_compare_fslfeat_3dtcorr_3Ddeconvolve"

os.makedirs(plot_dir, exist_ok=True)


fsl_base="/data/NIMH_scratch/kleinrl/analyses/wb3/ALL/pca_num5_all10_nomask/fsl_feat_1010.L_FEF_pca5/DAY0/ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-04_task-movie_run-04_VASO.2D.pca_000/ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-04_task-movie_run-04_VASO-ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-04_task-movie_run-04_VASO.feat/"

fsl_zstat_thresh=fsl_base+"thresh_zstat1.nii.gz"
fsl_pe=fsl_base+"/stats/pe1.nii.gz"
fsl_tstat=fsl_base+"/stats/tstat1.nii.gz"
fsl_zstat=fsl_base+"/stats/zstat1.nii.gz"

"""
layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii"
layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"

cd /data/NIMH_scratch/kleinrl/analyses/wb3/ALL/pca_num5_all10_nomask/fsl_feat_1010.L_FEF_pca5/DAY0/ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-04_task-movie_run-04_VASO.2D.pca_000/ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-04_task-movie_run-04_VASO-ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-04_task-movie_run-04_VASO.feat

LN2_todataframe.py --input stats/zstat1.nii.gz  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input stats/tstat1.nii.gz  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input stats/pe1.nii.gz  --columns  $parc_hcp_kenshu --layers  $layers 

LN2_todataframe.py --input thresh_zstat1.nii.gz  --columns  $parc_hcp_kenshu --layers  $layers 


"""

df_zstat=glob(fsl_base+"/stats/tstat1*.npy")[0]
df_tstat=glob(fsl_base+"/stats/zstat1*.npy")[0]
df_pe=glob(fsl_base+"/stats/pe*.npy")[0]
df_thresh_zstat=glob(fsl_base+"/thresh_zstat*.npy")[0]

df_corr_=""



#dfs = glob(dataframe_dir+"/*")

lab_dict_full = pd.read_csv("/home/kleinrl/projects/laminar_fmri/tools/LUT_hcp-mmp-b_v2.txt",sep=" ", header=None, names=["id", "lab", "a", "b", "c","d"])
lab_dict_full = dict(zip(lab_dict_full['id'].to_list(), lab_dict_full['lab'].to_list()))




# L1 - WM 
# L7 - CSF 

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


#inv_lab_dict = {v: k for k, v in lab_dict.items()}
ids, labs = [],[]
for k,v in lab_dict.items():
    ids.append(k), labs.append(v)



# len_x = len(labs)
# len_y = len(labs) 

len_x = 3
len_y = 5

fig, axs = plt.subplots(ncols=len_x, nrows=len_y, figsize=(30,30), #len_x,len_y
                        layout="constrained")

target_id=1010


d_zstat_thresh  = np.load(df_thresh_zstat)[:,1:] #[target_id, : ]
d_zstat         = np.load(df_zstat)[:,1:] #[target_id, : ]
d_tstat         = np.load(df_tstat)[:,1:] #[target_id, : ]





#np.where(np.isnan(d_zstat_thresh).sum(axis=1)<7)


num = np.isnan(d_zstat_thresh).sum(axis=1)
num_ind = (num < 7) & (num > 5 )
lab_inds = np.where(num_ind)

rois_to_plot  = [ lab_dict_full[l] for l in lab_inds[0] ]

d_zstat_thresh[np.isnan(d_zstat_thresh).sum(axis=1)<7,:].index











for seed_i in range(len_x):
    seed_lab = labs[seed_i]

    dfs = glob(dataframe_dir+"/*"+seed_lab+"*pca*batch20*")
    dfs = [df for df in dfs if "SMOOTH" not in df ]



    nulls = [ df for df in dfs if "perm" in df ] 
    nulls000  = [ df for df in nulls if "pca_000" in df ] 
    nulls001  = [ df for df in nulls if "pca_001" in df ] 
    nulls002  = [ df for df in nulls if "pca_002" in df ] 
    nulls003  = [ df for df in nulls if "pca_003" in df ] 
    nulls004  = [ df for df in nulls if "pca_004" in df ] 

    emps = [ df for df in dfs if "perm" not in df ] 
    emps000   = [ df for df in emps if "pca_000" not in df ]
    emps001   = [ df for df in emps if "pca_001" not in df ]
    emps002   = [ df for df in emps if "pca_001" not in df ]
    emps003   = [ df for df in emps if "pca_003" not in df ]
    emps004   = [ df for df in emps if "pca_004" not in df ]


    for target_i in range(len_y):         
        target_lab = labs[target_i]
        target_id = inv_lab_dict[target_lab]

        null000_vals, emp000_vals  = [], [] 
        null001_vals, emp001_vals  = [], [] 
        null002_vals, emp002_vals  = [], [] 
        null003_vals, emp003_vals  = [], [] 
        null004_vals, emp004_vals  = [], [] 

        for df in nulls000: 
            d = np.load(df)[:,1:]
            null000_vals.append(d[target_id, : ])

        for df in nulls001: 
            d = np.load(df)[:,1:]
            null001_vals.append(d[target_id, : ])

        for df in nulls002: 
            d = np.load(df)[:,1:]
            null002_vals.append(d[target_id, : ])

        for df in nulls003: 
            d = np.load(df)[:,1:]
            null003_vals.append(d[target_id, : ])

        for df in nulls004: 
            d = np.load(df)[:,1:]
            null004_vals.append(d[target_id, : ])



        for df in emps000: 
            d = np.load(df)[:,1:]
            emp000_vals.append(d[target_id, : ])

        for df in emps001: 
            d = np.load(df)[:,1:]
            emp001_vals.append(d[target_id, : ])

        for df in emps002: 
            d = np.load(df)[:,1:]
            emp002_vals.append(d[target_id, : ])

        for df in emps003: 
            d = np.load(df)[:,1:]
            emp003_vals.append(d[target_id, : ])

        for df in emps004: 
            d = np.load(df)[:,1:]
            emp004_vals.append(d[target_id, : ])


        null000_vals   = np.stack(null000_vals)
        null001_vals   = np.stack(null001_vals)
        null002_vals   = np.stack(null002_vals)
        null003_vals   = np.stack(null003_vals)
        null004_vals   = np.stack(null004_vals)

        emp000_vals   = np.stack(emp000_vals)
        emp001_vals   = np.stack(emp001_vals)
        emp002_vals   = np.stack(emp002_vals)
        emp003_vals   = np.stack(emp003_vals)
        emp004_vals   = np.stack(emp004_vals)


        #emp_vals    = np.stack(emp_vals) 

        null000_means  = null000_vals.mean(axis=0)
        null001_means  = null001_vals.mean(axis=0)
        null002_means  = null002_vals.mean(axis=0)
        null003_means  = null003_vals.mean(axis=0)
        null004_means  = null004_vals.mean(axis=0)

        null000_stdevs  = null000_vals.std(axis=0)
        null001_stdevs  = null001_vals.std(axis=0)
        null002_stdevs  = null002_vals.std(axis=0)
        null003_stdevs  = null003_vals.std(axis=0)
        null004_stdevs  = null004_vals.std(axis=0)

        emp000_means  = emp000_vals.mean(axis=0)
        emp001_means  = emp001_vals.mean(axis=0)
        emp002_means  = emp002_vals.mean(axis=0)
        emp003_means  = emp003_vals.mean(axis=0)
        emp004_means  = emp004_vals.mean(axis=0)

        emp000_stdevs  = emp000_vals.std(axis=0)
        emp001_stdevs  = emp001_vals.std(axis=0)
        emp002_stdevs  = emp002_vals.std(axis=0)
        emp003_stdevs  = emp003_vals.std(axis=0)
        emp004_stdevs  = emp004_vals.std(axis=0)


        axs[seed_i, target_i].plot(null000_means)
        axs[seed_i, target_i].plot(null001_means)
        axs[seed_i, target_i].plot(null002_means)
        axs[seed_i, target_i].plot(null003_means)
        axs[seed_i, target_i].plot(null004_means)


        axs[seed_i, target_i].plot(emp000_means)
        axs[seed_i, target_i].plot(emp001_means)
        axs[seed_i, target_i].plot(emp002_means)
        axs[seed_i, target_i].plot(emp003_means)
        axs[seed_i, target_i].plot(emp004_means)

        axs[seed_i, target_i].fill_between(range(7),null000_means-null000_stdevs,null000_means+null000_stdevs,alpha=.1)
        axs[seed_i, target_i].fill_between(range(7),null001_means-null001_stdevs,null001_means+null001_stdevs,alpha=.1)
        axs[seed_i, target_i].fill_between(range(7),null002_means-null002_stdevs,null002_means+null002_stdevs,alpha=.1)
        axs[seed_i, target_i].fill_between(range(7),null003_means-null003_stdevs,null003_means+null003_stdevs,alpha=.1)
        axs[seed_i, target_i].fill_between(range(7),null004_means-null004_stdevs,null004_means+null004_stdevs,alpha=.1)

        axs[seed_i, target_i].fill_between(range(7),emp000_means-emp000_stdevs,emp000_means+emp000_stdevs,alpha=.1)
        axs[seed_i, target_i].fill_between(range(7),emp001_means-emp001_stdevs,emp001_means+emp001_stdevs,alpha=.1)
        axs[seed_i, target_i].fill_between(range(7),emp002_means-emp002_stdevs,emp002_means+emp002_stdevs,alpha=.1)
        axs[seed_i, target_i].fill_between(range(7),emp003_means-emp003_stdevs,emp003_means+emp003_stdevs,alpha=.1)
        axs[seed_i, target_i].fill_between(range(7),emp004_means-emp004_stdevs,emp004_means+emp004_stdevs,alpha=.1)

        if seed_i == 0: 
            axs[seed_i, target_i].title.set_text(target_lab)

        if target_i == 0: 
            axs[seed_i, target_i].set(ylabel=seed_lab)

        
        #axs[seed_i, target_i].legend(['null', 'vaso'])

# ax_i = 0 
# for ax in axs.flat:
#     ax.set(ylabel=labs[ax_i]) #xlabel='x-label', 

# Hide x labels and tick labels for top plots and y ticks for right plots.
# for ax in axs.flat:
#     ax.label_outer()
      
fig.suptitle("V4abstract (PCs Batch20 10iters)", fontsize=16)

fig.savefig(plot_dir+"/V4fig.png")














# 1090.L_10pp
# 1088.L_10v 
# 1065.L_10r 
# 1072.L_10d 
# 1087.L_9a 
# 1071.L_9p 
# 1069.L_9m 
# 1086.L_9-46d 
# 1070.L_8BL 
# 1063.L_8BM 
# 1067.L_8Av 
# 1073.L_8C 
# 1068.L_8Ad 
# 1010.L_FEF 
# 1042.L_7AL 
# 1047.L_7PC 
# 1046.L_7PL 
# 1029.L_7Pm 
# 1045.L_7Am 
# 1030.L_7m 
# 1006.L_V4 
# 1007.L_V8 
# 1016.L_V7 
# 1003.L_V6 
# 1153.L_V6A 
# 1023.L_MT 

# 8109.lh.LGN 

# 1001.L_V1 
# 1004.L_V2 
# 1005.L_V3 
# 1013.L_V3A 
# 1019.L_V3B 
# 1159.L_V3CD 

# 1048.L_LIPv 
# 1095.L_LIPd
