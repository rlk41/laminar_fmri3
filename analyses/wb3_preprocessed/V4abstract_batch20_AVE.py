
import numpy as np 
from glob import glob 
import matplotlib 

import matplotlib.pyplot as plt
import numpy as np

work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5"
dataframe_dir=work_dir+"/dataframes"

dfs = glob(dataframe_dir+"/*")


plot_dir=work_dir+"/plots"

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



len_x = len(labs)
len_y = len(labs) 



fig, axs = plt.subplots(ncols=len_x, nrows=len_y, figsize=(30,30), #len_x,len_y
                        layout="constrained")
for seed_i in range(len_x):
    seed_lab = labs[seed_i]

    dfs = glob(dataframe_dir+"/*"+seed_lab+"*")
    dfs = [df for df in dfs if "SMOOTH" not in df ]

    nulls = [ df for df in dfs if "perm" in df ] 
    emps   = [ df for df in dfs if "perm" not in df ]

    for target_i in range(len_y):         
        target_lab = labs[target_i]
        target_id = inv_lab_dict[target_lab]
        null_vals, emp_vals  = [], [] 

        for df in nulls: 
            d = np.load(df) 
            d = d[:,1:]
            null_vals.append(d[target_id, : ])
        for df in emps: 
            d = np.load(df) 
            d = d[:,1:]
            emp_vals.append(d[target_id, : ])

        null_vals   = np.stack(null_vals)
        emp_vals    = np.stack(emp_vals) 

        null_means  = null_vals.mean(axis=0)
        null_stdevs  = null_vals.std(axis=0)

        emp_means   = emp_vals.mean(axis=0)
        emp_stdevs  = emp_vals.std(axis=0)

        axs[seed_i, target_i].plot(null_means)
        axs[seed_i, target_i].plot(emp_means)

        axs[seed_i, target_i].fill_between(range(7),null_means-null_stdevs,null_means+null_stdevs,alpha=.1)
        axs[seed_i, target_i].fill_between(range(7),emp_means-emp_stdevs,emp_means+emp_stdevs,alpha=.1)

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
      
fig.suptitle("V4abstract (Batch20 10iters)", fontsize=16)

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
