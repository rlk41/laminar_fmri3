
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
plot_dir        =work_dir+"/plots_v2"
data_dir        =work_dir+"/data"

os.makedirs(plot_dir, exist_ok=True)

lab_dict_full = pd.read_csv(data_dir+"/LUT_hcp-mmp-b_v2.txt",sep=" ", header=None, names=["id", "lab", "a", "b", "c","d"])
lab_dict_full = dict(zip(lab_dict_full['id'].to_list(), lab_dict_full['lab'].to_list()))

# layers 7=csf, 1=WM

fsl_base=data_dir+"/feat_001"
#path_tstat        =fsl_base+"/stats/tstat1-sub-02_layers-parc_hcp_kenshu-means.npy"
#path_zstat        =fsl_base+"/stats/zstat1-sub-02_layers-parc_hcp_kenshu-means.npy"
path_pe           =fsl_base+"/stats/pe1-sub-02_layers-parc_hcp_kenshu-means.npy"
path_thresh_zstat =fsl_base+"/thresh_zstat1-sub-02_layers-parc_hcp_kenshu-means.npy"

#raw 
f="raw_pca001_v2"
tr="TR5"
path_raw_corr=out_dir+'/{}/sub-02_ses-04_task-movie_run-04_VASO-sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_001.1D-CORR-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
path_raw_deconv_coefs=out_dir+'/{}/deconv_{}_Coef-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
#path_raw_deconv_fstat=out_dir+'/{}/deconv_{}_Fstat-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
#path_raw_deconv_fullr2=out_dir+'/{}/deconv_{}_FULLR2-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)

# preprocessed
f="preprocessed_pca001_v2"
tr="TR5"
path_preproc_corr=out_dir+"/{}/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_001.1D-CORR-sub-02_layers-parc_hcp_kenshu-means.npy".format(f)
path_preproc_deconv_coefs=out_dir+'/{}/deconv_{}_Coef-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
#path_preproc_deconv_fstat=out_dir+'/{}/deconv_{}_Fstat-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
#path_preproc_deconv_fullr2=out_dir+'/{}/deconv_{}_FULLR2-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)

# preprocessed
f="raw_pca001_seed_across_preproced_FSL"
tr="TR5"
path_raw_seed_preproc_corr=out_dir+"/{}/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_001.1D-CORR-sub-02_layers-parc_hcp_kenshu-means.npy".format(f)
path_raw_seed_preproc_deconv_coefs=out_dir+'/{}/deconv_{}_Coef-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
#path_raw_seed_preproc_deconv_fstat=out_dir+'/{}/deconv_{}_Fstat-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)
#path_raw_seed_preproc_deconv_fullr2=out_dir+'/{}/deconv_{}_FULLR2-sub-02_layers-parc_hcp_kenshu-means.npy'.format(f, tr)





d_pe                            = np.load(path_pe)[:,1:]
d_zstat_thresh                  = np.load(path_thresh_zstat)[:,1:]
#d_zstat                        = np.load(df_zstat)[:,1:]
#d_tstat                        = np.load(df_tstat)[:,1:]

d_raw_corr                      = np.load(path_raw_corr)[:,1:]
d_raw_deconv_coefs              = np.load(path_raw_deconv_coefs)[:,1:]

d_preproc_corr                  = np.load(path_preproc_corr)[:,1:]
d_preproc_deconv_coefs          = np.load(path_preproc_deconv_coefs)[:,1:]

d_raw_seed_preproc_corr         = np.load(path_raw_seed_preproc_corr)[:,1:]
d_raw_seed_preproc_deconv_coefs = np.load(path_raw_seed_preproc_deconv_coefs)[:,1:]





def get_plots1(lab_inds, d_pe, d_raw_corr, d_raw_deconv_coefs, d_preproc_corr,  \
    d_preproc_deconv_coefs, d_raw_seed_preproc_corr, d_raw_seed_preproc_deconv_coefs, plot_path):

    rows, cols = 5,7
    fig, axs = plt.subplots(ncols=cols, nrows=rows, figsize=(15,15)) #, #len_x,len_y
    for i in range(rows):

        target_id = lab_inds[i]
        target_lab = lab_dict_full[ target_id ]

        print(i, target_id, target_lab)
        #fig.suptitle('{} {} '.format(target_id, target_lab))

        pe                              = d_pe[target_id, : ]
        zstat_thresh                    = d_zstat_thresh[target_id, : ]
        #d_zstat                        = np.load(df_zstat)[:,1:][target_id, : ]
        #d_tstat                        = np.load(df_tstat)[:,1:][target_id, : ]

        raw_corr                        = d_raw_corr[target_id, : ]
        raw_deconv_coefs                = d_raw_deconv_coefs[target_id, : ]

        preproc_corr                    = d_preproc_corr[target_id, : ]
        preproc_deconv_coefs            = d_preproc_deconv_coefs[target_id, : ]

        raw_seed_preproc_corr           = d_raw_seed_preproc_corr[target_id, : ]
        raw_seed_preproc_deconv_coefs   = d_raw_seed_preproc_deconv_coefs[target_id, : ]


        axs[i,0].plot(pe)
        
        axs[i,1].plot(raw_corr)
        axs[i,2].plot(preproc_corr)
        axs[i,3].plot(raw_seed_preproc_corr)

        axs[i,4].plot(raw_deconv_coefs)
        axs[i,5].plot(preproc_deconv_coefs)
        axs[i,6].plot(raw_seed_preproc_deconv_coefs)


        if i == 0: 
            axs[i,0].title.set_text("FSLFEAT\n(B-values)")

            axs[i,1].title.set_text("Rawdata 3dTCorr \n(r-values)")
            axs[i,2].title.set_text("Prep-FSL \n3dTCorr (r-values)")
            axs[i,3].title.set_text("rawseed + Prep-FSL\n3dTCorr (r-values)")

            axs[i,4].title.set_text("Rawdata \n3dDeconvolve (Coefs)")
            axs[i,5].title.set_text("Prep-FSL\n3dDeconvolve (Coefs)")
            axs[i,6].title.set_text("rawseed + Prep-FSL\n3dDeconvolve (Coefs)")

        
        axs[i,0].set_ylabel("{} {}\nB-values".format(target_lab, target_id))



        axs[i,0].set_xticklabels([])
        axs[i,1].set_xticklabels([])
        axs[i,2].set_xticklabels([])
        axs[i,3].set_xticklabels([])
        axs[i,4].set_xticklabels([])

        axs[i,0].set_xticks([])
        axs[i,1].set_xticks([])
        axs[i,2].set_xticks([])
        axs[i,3].set_xticks([])
        axs[i,4].set_xticks([])

    for j in range(5):
        axs[i,j].set_xticks([0,7])
        axs[i,j].set_xticklabels(["WM","CSF"])

    plt.tight_layout()

    plt.savefig(plot_path)



get_plots1([1001, 1002, 1006, 1007, 1008], d_pe, d_raw_corr, d_raw_deconv_coefs, d_preproc_corr,  \
    d_preproc_deconv_coefs, d_raw_seed_preproc_corr, d_raw_seed_preproc_deconv_coefs, plot_dir+"/plots1_v2.png")

get_plots1([1070, 1069, 1098, 1010, 1052], d_pe, d_raw_corr, d_raw_deconv_coefs, d_preproc_corr, \
    d_preproc_deconv_coefs, d_raw_seed_preproc_corr, d_raw_seed_preproc_deconv_coefs, plot_dir+"/plots2_v2.png")

get_plots1([1039,1015, 1013, 1004, 1001] , d_pe, d_raw_corr, d_raw_deconv_coefs, d_preproc_corr, \
    d_preproc_deconv_coefs, d_raw_seed_preproc_corr, d_raw_seed_preproc_deconv_coefs, plot_dir+"/plots3_v2.png")

get_plots1([1009, 1010, 1046, 1049, 1048] , d_pe, d_raw_corr, d_raw_deconv_coefs, d_preproc_corr, \
    d_preproc_deconv_coefs, d_raw_seed_preproc_corr, d_raw_seed_preproc_deconv_coefs, plot_dir+"/plots4_v2.png")



data = [d_pe, d_raw_corr, d_raw_deconv_coefs, d_preproc_corr, d_preproc_deconv_coefs, d_raw_seed_preproc_corr, d_raw_seed_preproc_deconv_coefs]
def get_correlations(data):

    len_d = len(data)
    results={}

    y = [ y for x in [range(1001,1181), range(2001,2181)] for y in x ]

    for i in range(1,len_d):
        cc = []
        for c in y: 
            cc.append(np.corrcoef(data[0][c,:], data[i][c,:])[0,1])
        results[i] = cc


    corr_map_mean = np.zeros(shape=(len_d,len_d))
    corr_map_stdev = np.zeros(shape=(len_d,len_d))

    results = []
    for i in range(len_d):
        for j in range(len_d):
            cc = []
            for c in y: 
                cc.append(np.corrcoef(data[i][c,:], data[j][c,:])[0,1])
            #results[i] = cc

            cc_stdev    = np.std(cc)
            cc_mean     = np.mean(cc)
            cc_count    = len(cc)

            corr_map_mean[i,j]  = cc_mean
            corr_map_stdev[i,j] = cc_stdev

            results.append({'i':i, 'j':j,'std':cc_stdev, 'mean':cc_mean, 'count':cc_count, 'data':cc}) 



    plt.plot(corr_map_mean)
    
    plt.savefig()



















# lab_dict = {
# 1090:"L_10pp",
# #1088:"L_10v", 
# #1065:"L_10r", 
# #1072:"L_10d",  
# 1087:"L_9a",  
# #1071:"L_9p",  
# #1069:"L_9m",  
# #1086:"L_9-46d",  
# 1070:"L_8BL",  
# #1063:"L_8BM",  
# #1067:"L_8Av",  
# #1073:"L_8C",  
# #1068:"L_8Ad",  
# 1010:"L_FEF",  
# #1042:"L_7AL",  
# #1047:"L_7PC",  
# 1046:"L_7PL",  
# #1029:"L_7Pm",  
# #1045:"L_7Am",  
# #1030:"L_7m",  
# 1006:"L_V4",  
# #1007:"L_V8",  
# #1016:"L_V7",  
# #1003:"L_V6",  
# 1153:"L_V6A",  
# 1023:"L_MT",  

# #8109:"lh.LGN",  

# 1001:"L_V1",  
# #1004:"L_V2",  
# 1005:"L_V3",  
# #1013:"L_V3A",  
# #1019:"L_V3B",  
# #1159:"L_V3CD",  

# #1048:"L_LIPv",  
# 1095:"L_LIPd", 
# }
# inv_lab_dict = {v: k for k, v in lab_dict.items()}

# ids, labs = [],[]
# for k,v in lab_dict.items():
#     ids.append(k), labs.append(v)

# len_x, len_y = 3, 5 



# lab_inds = [1001, 1002, 1006, 1007, 1008]
# # 1003, 1004, 1005, 
# rows, cols = 5,5
# fig, axs = plt.subplots(ncols=cols, nrows=rows, figsize=(15,15)) #, #len_x,len_y
# for i in range(rows):

#     target_id = lab_inds[i]
#     target_lab = lab_dict_full[ target_id ]

#     print(i, target_id, target_lab)
#     #fig.suptitle('{} {} '.format(target_id, target_lab))

#     pe                        = d_pe[target_id, : ]
#     zstat_thresh              = d_zstat_thresh[target_id, : ]
#     #d_zstat                     = np.load(df_zstat)[:,1:][target_id, : ]
#     #d_tstat                     = np.load(df_tstat)[:,1:][target_id, : ]

#     corr                      = d_corr[target_id, : ]
#     corr_deconv_coefs         = d_corr_deconv_coefs[target_id, : ]

#     corr_preproc              = d_corr_preproc[target_id, : ]
#     corr_preproc_deconv_coefs = d_corr_preproc_deconv_coefs[target_id, : ]

#     corr_preproc              = d_corr_preproc[target_id, : ]
#     corr_preproc_deconv_coefs = d_corr_preproc_deconv_coefs[target_id, : ]


#     axs[i,0].plot(pe)
#     axs[i,1].plot(corr)
#     axs[i,2].plot(corr_preproc)
#     axs[i,3].plot(corr_deconv_coefs)
#     axs[i,4].plot(corr_preproc_deconv_coefs)

#     if i == 0: 
#         axs[i,0].title.set_text("FSLFEAT\n(B-values)")
#         axs[i,1].title.set_text("Rawdata using \n3dTCorr (r-values)")
#         axs[i,2].title.set_text("Preprocessed-FSLFEAT using \n3dTCorr (r-values)")
#         axs[i,3].title.set_text("Rawdata using \n3dDeconvolve (Coefs)")
#         axs[i,4].title.set_text("Preprocessed-FSLFEAT using \n3dDeconvolve (Coefs)")
#         axs[i,5].title.set_text("raw seed + Preprocessed-FSLFEAT \3dTCorr (r-values)")
#         axs[i,6].title.set_text("raw seed + Preprocessed-FSLFEAT \n3dDeconvolve (Coefs)")

     
#     axs[i,0].set_ylabel("{} {}\nB-values".format(target_lab, target_id))



#     axs[i,0].set_xticklabels([])
#     axs[i,1].set_xticklabels([])
#     axs[i,2].set_xticklabels([])
#     axs[i,3].set_xticklabels([])
#     axs[i,4].set_xticklabels([])

#     axs[i,0].set_xticks([])
#     axs[i,1].set_xticks([])
#     axs[i,2].set_xticks([])
#     axs[i,3].set_xticks([])
#     axs[i,4].set_xticks([])

# for j in range(5):
#     axs[i,j].set_xticks([0,7])
#     axs[i,j].set_xticklabels(["WM","CSF"])

# plt.tight_layout()

# plt.savefig(plot_dir+"/plots1.png")







# lab_inds = [1070, 1069, 1098, 1010, 1052]

# rows, cols = 5,5
# fig, axs = plt.subplots(ncols=cols, nrows=rows, figsize=(15,15)) #, #len_x,len_y
# for i in range(rows):

#     target_id = lab_inds[i]
#     target_lab = lab_dict_full[ target_id ]

#     print(i, target_id, target_lab)

    
#     fig.suptitle('')

#     d_pe                        = np.load(df_pe)[:,1:][target_id, : ]
#     d_zstat_thresh              = np.load(df_thresh_zstat)[:,1:][target_id, : ]
#     d_zstat                     = np.load(df_zstat)[:,1:][target_id, : ]
#     d_tstat                     = np.load(df_tstat)[:,1:][target_id, : ]

#     d_corr                      =np.load(df_corr)[:,1:][target_id, : ]
#     d_corr_deconv_coefs         =np.load(df_corr_deconv_coefs)[:,1:][target_id, : ]
#     d_corr_deconv_fullr2        =np.load(df_corr_deconv_fullr2)[:,1:] [target_id, : ]

#     # preprocessed
#     d_corr_preproc              =np.load(df_corr_preproc)[:,1:][target_id, : ]
#     d_corr_preproc_deconv_coefs =np.load(df_corr_preproc_deconv_coefs)[:,1:][target_id, : ]
#     d_corr_preproc_deconv_fullr2=np.load(df_corr_preproc_deconv_fullr2)[:,1:][target_id, : ]


#     axs[i,0].plot(d_pe)
#     axs[i,1].plot(d_corr)
#     axs[i,2].plot(d_corr_preproc)
#     axs[i,3].plot(d_corr_deconv_coefs)
#     axs[i,4].plot(d_corr_preproc_deconv_coefs)

#     if i == 0: 
#         axs[i,0].title.set_text("FSLFEAT\n(B-values)")
#         axs[i,1].title.set_text("Rawdata using \n3dTCorr (r-values)")
#         axs[i,2].title.set_text("Preprocessed-FSLFEAT using \n3dTCorr (r-values)")
#         axs[i,3].title.set_text("Rawdata using \n3dDeconvolve (Coefs)")
#         axs[i,4].title.set_text("Preprocessed-FSLFEAT using \n3dDeconvolve (Coefs)")

     
#     axs[i,0].set_ylabel("{} {}\nB-values".format(target_lab, target_id))



#     axs[i,0].set_xticklabels([])
#     axs[i,1].set_xticklabels([])
#     axs[i,2].set_xticklabels([])
#     axs[i,3].set_xticklabels([])
#     axs[i,4].set_xticklabels([])

#     axs[i,0].set_xticks([])
#     axs[i,1].set_xticks([])
#     axs[i,2].set_xticks([])
#     axs[i,3].set_xticks([])
#     axs[i,4].set_xticks([])
#     #axs[i,0].set_ylabels([""])
#     # axs[i,1].set_ylabel("r-values")
#     # axs[i,2].set_ylabel("r-values")
#     # axs[i,3].set_ylabel("Coefs")
#     # axs[i,4].set_ylabel("Coefs")


# for j in range(5):
#     axs[i,j].set_xticks([0,7])
#     axs[i,j].set_xticklabels(["WM","CSF"])

# plt.tight_layout()
# plt.savefig(plot_dir+"/plots2.png")





# lab_inds = [1039,1015, 1013, 1004, 1001] 

# rows, cols = 5,5
# fig, axs = plt.subplots(ncols=cols, nrows=rows, figsize=(15,15)) #, #len_x,len_y
# for i in range(rows):

#     target_id = lab_inds[i]
#     target_lab = lab_dict_full[ target_id ]

#     print(i, target_id, target_lab)

    
#     fig.suptitle('')

#     d_pe                        = np.load(df_pe)[:,1:][target_id, : ]
#     d_zstat_thresh              = np.load(df_thresh_zstat)[:,1:][target_id, : ]
#     d_zstat                     = np.load(df_zstat)[:,1:][target_id, : ]
#     d_tstat                     = np.load(df_tstat)[:,1:][target_id, : ]

#     d_corr                      =np.load(df_corr)[:,1:][target_id, : ]
#     d_corr_deconv_coefs         =np.load(df_corr_deconv_coefs)[:,1:][target_id, : ]
#     d_corr_deconv_fullr2        =np.load(df_corr_deconv_fullr2)[:,1:] [target_id, : ]

#     # preprocessed
#     d_corr_preproc              =np.load(df_corr_preproc)[:,1:][target_id, : ]
#     d_corr_preproc_deconv_coefs =np.load(df_corr_preproc_deconv_coefs)[:,1:][target_id, : ]
#     d_corr_preproc_deconv_fullr2=np.load(df_corr_preproc_deconv_fullr2)[:,1:][target_id, : ]


#     axs[i,0].plot(d_pe)
#     axs[i,1].plot(d_corr)
#     axs[i,2].plot(d_corr_preproc)
#     axs[i,3].plot(d_corr_deconv_coefs)
#     axs[i,4].plot(d_corr_preproc_deconv_coefs)

#     if i == 0: 
#         axs[i,0].title.set_text("FSLFEAT\n(B-values)")
#         axs[i,1].title.set_text("Rawdata using \n3dTCorr (r-values)")
#         axs[i,2].title.set_text("Preprocessed-FSLFEAT using \n3dTCorr (r-values)")
#         axs[i,3].title.set_text("Rawdata using \n3dDeconvolve (Coefs)")
#         axs[i,4].title.set_text("Preprocessed-FSLFEAT using \n3dDeconvolve (Coefs)")

     
#     axs[i,0].set_ylabel("{} {}\nB-values".format(target_lab, target_id))



#     axs[i,0].set_xticklabels([])
#     axs[i,1].set_xticklabels([])
#     axs[i,2].set_xticklabels([])
#     axs[i,3].set_xticklabels([])
#     axs[i,4].set_xticklabels([])

#     axs[i,0].set_xticks([])
#     axs[i,1].set_xticks([])
#     axs[i,2].set_xticks([])
#     axs[i,3].set_xticks([])
#     axs[i,4].set_xticks([])
#     #axs[i,0].set_ylabels([""])
#     # axs[i,1].set_ylabel("r-values")
#     # axs[i,2].set_ylabel("r-values")
#     # axs[i,3].set_ylabel("Coefs")
#     # axs[i,4].set_ylabel("Coefs")


# for j in range(5):
#     axs[i,j].set_xticks([0,7])
#     axs[i,j].set_xticklabels(["WM","CSF"])

# plt.tight_layout()
# plt.savefig(plot_dir+"/plots3.png")





# lab_inds = [1009, 1010, 1046, 1049, 1048] 

# rows, cols = 5,5
# fig, axs = plt.subplots(ncols=cols, nrows=rows, figsize=(15,15)) #, #len_x,len_y
# for i in range(rows):

#     target_id = lab_inds[i]
#     target_lab = lab_dict_full[ target_id ]

#     print(i, target_id, target_lab)

    
#     fig.suptitle('')

#     d_pe                        = np.load(df_pe)[:,1:][target_id, : ]
#     d_zstat_thresh              = np.load(df_thresh_zstat)[:,1:][target_id, : ]
#     d_zstat                     = np.load(df_zstat)[:,1:][target_id, : ]
#     d_tstat                     = np.load(df_tstat)[:,1:][target_id, : ]

#     d_corr                      =np.load(df_corr)[:,1:][target_id, : ]
#     d_corr_deconv_coefs         =np.load(df_corr_deconv_coefs)[:,1:][target_id, : ]
#     d_corr_deconv_fullr2        =np.load(df_corr_deconv_fullr2)[:,1:] [target_id, : ]

#     # preprocessed
#     d_corr_preproc              =np.load(df_corr_preproc)[:,1:][target_id, : ]
#     d_corr_preproc_deconv_coefs =np.load(df_corr_preproc_deconv_coefs)[:,1:][target_id, : ]
#     d_corr_preproc_deconv_fullr2=np.load(df_corr_preproc_deconv_fullr2)[:,1:][target_id, : ]


#     axs[i,0].plot(d_pe)
#     axs[i,1].plot(d_corr)
#     axs[i,2].plot(d_corr_preproc)
#     axs[i,3].plot(d_corr_deconv_coefs)
#     axs[i,4].plot(d_corr_preproc_deconv_coefs)

#     if i == 0: 
#         axs[i,0].title.set_text("FSLFEAT\n(B-values)")
#         axs[i,1].title.set_text("Rawdata using \n3dTCorr (r-values)")
#         axs[i,2].title.set_text("Preprocessed-FSLFEAT using \n3dTCorr (r-values)")
#         axs[i,3].title.set_text("Rawdata using \n3dDeconvolve (Coefs)")
#         axs[i,4].title.set_text("Preprocessed-FSLFEAT using \n3dDeconvolve (Coefs)")

     
#     axs[i,0].set_ylabel("{} {}\nB-values".format(target_lab, target_id))



#     axs[i,0].set_xticklabels([])
#     axs[i,1].set_xticklabels([])
#     axs[i,2].set_xticklabels([])
#     axs[i,3].set_xticklabels([])
#     axs[i,4].set_xticklabels([])

#     axs[i,0].set_xticks([])
#     axs[i,1].set_xticks([])
#     axs[i,2].set_xticks([])
#     axs[i,3].set_xticks([])
#     axs[i,4].set_xticks([])
#     #axs[i,0].set_ylabels([""])
#     # axs[i,1].set_ylabel("r-values")
#     # axs[i,2].set_ylabel("r-values")
#     # axs[i,3].set_ylabel("Coefs")
#     # axs[i,4].set_ylabel("Coefs")


# for j in range(5):
#     axs[i,j].set_xticks([0,7])
#     axs[i,j].set_xticklabels(["WM","CSF"])

# plt.tight_layout()
# plt.savefig(plot_dir+"/plots4.png")
