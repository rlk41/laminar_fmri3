#!/usr/bin/env python

import os 
import argparse
from re import L
import numpy as np
import matplotlib.pyplot as plt
import nibabel as nib 
import matplotlib.pyplot as plt 
import pandas as pd 

import glob 
import scipy 
import scipy.stats 

from matplotlib.pylab import plot, boxplot, show, savefig, xlim, figure, \
                ylim, legend, setp, axes




def get_plots(base_dir, k=None, c=None, fwhm=7, plot_dir=None, type=None, nulls=None): 

    '''
    base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF_corr"

    plot_dir = None 
    base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF"
    fwhm=7
    k = 'L_VIP'
    c=10070
    type='regress'


    type="regress"
    base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF"
    c=26268
    k="L_VIP"
    fwhm=7 
    plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF_corr/FEF_for_layerClub-compare"


    type="corr"
    base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF_corr"
    c=26268
    k="L_VIP"
    fwhm=7 
    plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF_corr/L_VIP_10070-compare"
    plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF_corr/FEF_for_layerClub-compare"




    type="regress"
    base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF"
    c=10070
    k="L_VIP"
    fwhm=7 
    plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF_corr/FEF_for_layerClub-compare"


    type="corr"
    base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF_corr"
    c=10070
    k="L_VIP"
    fwhm=7 
    plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF_corr/L_VIP_10070-compare"
    plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF_corr/FEF_for_layerClub-compare"





    '''

    if type == 'corr':
        file_type = "inv_corr"
        ylabel = "Correlation (pearson)"
    elif type == "regress":
        file_type = "inv_pe1"
        ylabel = "Beta-weights"


    if plot_dir == None: 
        plot_dir=base_dir+"/plots"

    os.makedirs(plot_dir, exist_ok=True)

    
    LUT="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/HCPMMP1_LUT_ordered_RS.txt"

    lut = pd.read_csv(LUT, delimiter=' ')

    print('load lut')


    k_id = int(lut[lut['Lookup'] == k]['#'].values[0])

    print("K: {}, K_ID: {}".format(k, k_id))

    columns             = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii"
    parc                = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b_rmap.scaled2x.nii.gz"
    layers              = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii"
    
    if nulls == None: 
        nulls_3d            = glob.glob(base_dir+"/fsl_feat_*NULL*/mean/{}.fwhm{}.nii.gz".format(file_type, fwhm)) #fwhm7.L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz")
    elif nulls != None: 
        nulls_3d            = nulls 
    else: 
        print("something wrong with nulls ")


    feat_3d             = glob.glob(base_dir+"/fsl_feat_1010.L_FEF_pca10/mean/{}.fwhm{}.nii.gz".format(file_type, fwhm)) #L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz")
    feat_3d             = feat_3d[0]

    seed                = feat_3d.split('/')[-3].split('.')[-1].rstrip('_pca10')
    target              = k 

    img_parc            = nib.load(parc)
    img_col             = nib.load(columns)
    img_lay             = nib.load(layers)

    data_parc           = img_parc.get_fdata()
    data_columns        = img_col.get_fdata()
    data_layers         = img_lay.get_fdata()

    ind_roi     = np.where(data_parc == k_id )

    unq_roi_col = np.unique(data_columns[ind_roi]) 
    unq_roi_col = [ uc for uc in unq_roi_col if uc != 0 ]

    unq_layers  = np.flip(np.unique(data_layers))[:-1]

    print("unique columns: {}".format(len(unq_roi_col)))
    print("nulls_3d: {}".format(len(nulls_3d)))
    print("feat_3d: {}".format(feat_3d))


    if c != None: 
        unq_roi_col = [c]


    for uc in unq_roi_col: 

        # uc = unq_roi_col[0]
        #ind_col = np.where(data_columns == uc)
        ind_col = data_columns == uc
        col_voxels = np.sum(ind_col)

        if col_voxels == 0: 
            print("col_voxels == 0 ")
            continue 


        uc      = int(uc) 
        print("c: {}".format(uc))
        print("len ind_col: {}".format(col_voxels))



        null_i = 0 
        null_layer_data = [ [] for lc in range(0, int(np.max(unq_layers))+1 ) ]
        for null in nulls_3d: 
            print(null_i)
            null_i += 1 
            
            img_null  = nib.load(null)
            data_null = img_null.get_fdata()

            for lc in unq_layers: 
                ind_lay = data_layers == lc 
                #ind_both = np.where( ind_lay & ind_col )
                ind_both = ind_lay & ind_col 

                null_layer_data[int(lc)].append( data_null[ ind_both ] )


        null_layer_data_concat = [ [] for lc in range(0, int(np.max(unq_layers))+1 ) ]

        mean_null_layer_data = [ [] for lc in range(0, int(np.max(unq_layers))+1 ) ]
        for g in range(1, len(null_layer_data)): 
            mean_null_layer_data[g] = np.mean(null_layer_data[g], axis=0).flatten().tolist()
            null_layer_data_concat[g]      = np.concatenate(null_layer_data[g]).flatten().tolist()



        img_feat  = nib.load(feat_3d)
        data_feat = img_feat.get_fdata()

        emp_layer_data = [ [] for lc in range(0, int(np.max(unq_layers))+1 ) ]


        for lc in unq_layers: 
            ind_lay = data_layers == lc 
            ind_both = np.where( ind_lay & ind_col )

            emp_layer_data[int(lc)].append( data_feat[ ind_both ] )


        for g in range(1, len(emp_layer_data)): 
            emp_layer_data[g] = np.concatenate(emp_layer_data[g]).flatten().tolist()


        for g in range(1, len(null_layer_data_concat)): 
            if null_layer_data_concat[g] == []: 
                null_layer_data_concat[g] = [0]

        for g in range(1, len(mean_null_layer_data)): 
            if mean_null_layer_data[g] == []: 
                mean_null_layer_data[g] = [0]

        for g in range(1, len(emp_layer_data)): 
            if emp_layer_data[g] == []: 
                emp_layer_data[g] = [0] 


        colors = ['blue','red']


        ############
        ##########

        fig = figure()
        ax = axes()

        bon_corr = 10 
        p_thresh = 0.05 

        y_max = 0 
        y_min = 0 

        for j in range(1, len(null_layer_data_concat)):
            start = ((j-1)*3) + (j-1) + 1
            g, p1, p2, p3 = j, start, start+1, start+2 

            for npm in [null_layer_data_concat[g], mean_null_layer_data[g], emp_layer_data[g]]: 
                try: 
                    npm_max = np.max(npm)
                    if npm_max > y_max: 
                        y_max = npm_max 

                    npm_min = np.min(npm)
                    if npm_min < y_min: 
                        y_min = npm_min 
                    #print(npm_min, npm_max )
                except: pass

        y_max_annot, y_min_annot =  y_max*1.25, y_min*1.1
        y_min_plot, y_max_plot = y_min-(np.abs(y_min)*.4), y_max*1.4
        
        for j in range(1, len(null_layer_data_concat)):
            start           = ((j-1)*3) + (j-1) + 1
            g, p1, p2, p3   = j, start, start+1, start+2 
            end             = p3

            ax.errorbar(p1, np.mean(null_layer_data_concat[g]), yerr=np.std(null_layer_data_concat[g]),  fmt='ok', lw=3, color='blue') #fmt='ko', 
            ax.errorbar(p2, np.mean(emp_layer_data[g]), yerr=np.std(emp_layer_data[g]),  fmt='ok',lw=3, color='red') #ok


            mi, ma, me = np.min(null_layer_data_concat[g]), np.max(null_layer_data_concat[g]), np.mean(null_layer_data_concat[g])
            ax.errorbar(p1, me, [[ me - mi],[ma - me]] ,  fmt='.k', ecolor='gray', lw=1)

            mi, ma, me = np.min(emp_layer_data[g]), np.max(emp_layer_data[g]), np.mean(emp_layer_data[g])
            ax.errorbar(p2, me,[[ me - mi],[ma - me]] ,  fmt='.k', ecolor='gray', lw=1)
            
            y_max_annot = np.max([np.max(null_layer_data_concat[g]), np.max(emp_layer_data[g])])
            y_max_annot = y_max_annot * 1.1


            if (emp_layer_data[g] != [0]) & (null_layer_data_concat[g] != [0]):
                w = scipy.stats.mannwhitneyu(emp_layer_data[g], null_layer_data_concat[g], alternative='greater')
                if w.pvalue < p_thresh: 
                    plt.annotate('*', xy=(p1, y_max_annot*1.2 ), color='purple', fontsize=10)
                        # (p1+p2)/2
                if w.pvalue < p_thresh/bon_corr: 
                    plt.annotate('**', xy=(p1, y_max_annot*1.2 ), color='purple', fontsize=10)
                del w 

                w = scipy.stats.mannwhitneyu(emp_layer_data[g], null_layer_data_concat[g], alternative='two-sided')
                if w.pvalue < p_thresh: 
                    plt.annotate('*', xy=(p1, y_max_annot*1.1 ), color='blue', fontsize=10)
                        # (p1+p2)/2
                if w.pvalue < p_thresh/bon_corr: 
                    plt.annotate('**', xy=(p1, y_max_annot*1.1 ), color='blue', fontsize=10)
                del w 

                w = scipy.stats.kruskal(emp_layer_data[g], null_layer_data_concat[g])
                if w.pvalue < p_thresh: 
                    plt.annotate('*', xy=(p1, y_max_annot ), color='green', fontsize=10)
                        # (p1+p2)/2
                if w.pvalue < p_thresh/bon_corr: 
                    plt.annotate('**', xy=(p1, y_max_annot ), color='green', fontsize=10)
                del w 



            plt.annotate('{}'.format(len(null_layer_data_concat[g])), xy=((p1+p2)/2, y_min_annot*.95), color='blue', fontsize=7)
            plt.annotate('{}'.format(len(emp_layer_data[g])), xy=((p1+p2)/2, y_min_annot*.9), color='red', fontsize=7)
        
        ylim(y_min_plot, y_max_plot)

        ax.set_xticks([1, end])
        ax.set_xticklabels(['CSF', 'WM'])

        hB, = plot([1,1],'b-')
        hR, = plot([1,1],'r-')

        legend((hB, hR),
                        ('NULL ({})'.format(len(nulls_3d)), 
                        'VASO (1)'), 
                            loc='lower left', prop={'size': 6})


        hB.set_visible(False)
        hR.set_visible(False)

        plt.annotate('MannWhitneyU (greater) *', color='purple',    xy=(p3-15, y_min_plot-(y_min_plot*.15)), fontsize=7) #, xycoords=trans )
        plt.annotate('MannWhitneyU (two-sided) *', color='blue',    xy=(p3-15, y_min_plot-(y_min_plot*.11)), fontsize=7) #, xycoords=trans )
        plt.annotate('Kruskal *', color='green',                    xy=(p3-15, y_min_plot-(y_min_plot*.07)), fontsize=7) #, xycoords=trans )
        plt.annotate('bonferroni-corrected ** (0.05/10)', color='black',      xy=(p3-15, y_min_plot-(y_min_plot*.02)), fontsize=7) #, xycoords=trans)


        tit = "seed:{} target:{}-{} (fwhm{})".format(seed, target, uc, fwhm) 
        plt.title(tit )
        plt.ylabel(ylabel)

        save_tit=tit.replace(':','-').replace(' ','_').replace('(','').replace(')','')

        save_file = plot_dir+"/{}.{}.SD.box8.png".format(save_tit, type )
        plt.savefig(save_file)

        plt.close()

        print("plot saved -- {}".format(save_file))


        ############
        ##########

        fig = figure()
        ax = axes()

        bon_corr = 10 
        p_thresh = 0.05 

        y_max = 0 
        y_min = 0 

        for j in range(1, len(null_layer_data_concat)):
            start = ((j-1)*3) + (j-1) + 1
            g, p1, p2, p3 = j, start, start+1, start+2 

            for npm in [null_layer_data_concat[g], mean_null_layer_data[g], emp_layer_data[g]]: 
                try: 
                    npm_max = np.max(npm)
                    if npm_max > y_max: 
                        y_max = npm_max 

                    npm_min = np.min(npm)
                    if npm_min < y_min: 
                        y_min = npm_min 
                    #print(npm_min, npm_max )
                except: pass

        y_max_annot, y_min_annot =  y_max*1.25, y_min*1.1
        y_min_plot, y_max_plot = y_min-(np.abs(y_min)*.4), y_max*1.4
        
        for j in range(1, len(null_layer_data_concat)):
            start           = ((j-1)*3) + (j-1) + 1
            g, p1, p2, p3   = j, start, start+1, start+2 
            end             = p3

            ax.errorbar(p1, np.mean(null_layer_data_concat[g]), yerr=np.std(null_layer_data_concat[g]),  fmt='ok', lw=3, color='blue') #fmt='ko', 
            ax.errorbar(p2, np.mean(emp_layer_data[g]), yerr=np.std(emp_layer_data[g]),  fmt='ok',lw=3, color='red') #ok


            mi, ma, me = np.min(null_layer_data_concat[g]), np.max(null_layer_data_concat[g]), np.mean(null_layer_data_concat[g])
            ax.errorbar(p1, me, [[ me - mi],[ma - me]] ,  fmt='.k', ecolor='gray', lw=1)

            mi, ma, me = np.min(emp_layer_data[g]), np.max(emp_layer_data[g]), np.mean(emp_layer_data[g])
            ax.errorbar(p2, me,[[ me - mi],[ma - me]] ,  fmt='.k', ecolor='gray', lw=1)
            
            y_max_annot = np.max([np.max(null_layer_data_concat[g]), np.max(emp_layer_data[g])])
            y_max_annot = y_max_annot * 1.1


            if (emp_layer_data[g] != [0]) & (null_layer_data_concat[g] != [0]):
                w = scipy.stats.mannwhitneyu(emp_layer_data[g], null_layer_data_concat[g], alternative='greater')
                if w.pvalue < p_thresh: 
                    plt.annotate('*', xy=(p1, y_max_annot*1.2 ), color='purple', fontsize=10)
                        # (p1+p2)/2
                if w.pvalue < p_thresh/bon_corr: 
                    plt.annotate('**', xy=(p1, y_max_annot*1.2 ), color='purple', fontsize=10)
                del w 

                # w = scipy.stats.mannwhitneyu(emp_layer_data[g], null_layer_data_concat[g], alternative='two-sided')
                # if w.pvalue < p_thresh: 
                #     plt.annotate('*', xy=(p1, y_max_annot*1.1 ), color='blue', fontsize=10)
                #         # (p1+p2)/2
                # if w.pvalue < p_thresh/bon_corr: 
                #     plt.annotate('**', xy=(p1, y_max_annot*1.1 ), color='blue', fontsize=10)
                # del w 

                # w = scipy.stats.kruskal(emp_layer_data[g], null_layer_data_concat[g])
                # if w.pvalue < p_thresh: 
                #     plt.annotate('*', xy=(p1, y_max_annot ), color='green', fontsize=10)
                #         # (p1+p2)/2
                # if w.pvalue < p_thresh/bon_corr: 
                #     plt.annotate('**', xy=(p1, y_max_annot ), color='green', fontsize=10)
                # del w 



            plt.annotate('{}'.format(len(null_layer_data_concat[g])), xy=((p1+p2)/2, y_min_annot*.95), color='blue', fontsize=7)
            plt.annotate('{}'.format(len(emp_layer_data[g])), xy=((p1+p2)/2, y_min_annot*.9), color='red', fontsize=7)
        
        ylim(y_min_plot, y_max_plot)

        ax.set_xticks([1, end])
        ax.set_xticklabels(['CSF', 'WM'])

        hB, = plot([1,1],'b-')
        hR, = plot([1,1],'r-')

        legend((hB, hR),
                        ('NULL ({})'.format(len(nulls_3d)), 
                        'VASO (1)'), 
                            loc='lower left', prop={'size': 6})


        hB.set_visible(False)
        hR.set_visible(False)

        plt.annotate('MannWhitneyU (greater) *', color='purple',    xy=(p3-15, y_min_plot-(y_min_plot*.07)), fontsize=7) #, xycoords=trans )
        # plt.annotate('MannWhitneyU (two-sided) *', color='blue',    xy=(p3-15, y_min_plot-(y_min_plot*.11)), fontsize=7) #, xycoords=trans )
        # plt.annotate('Kruskal *', color='green',                    xy=(p3-15, y_min_plot-(y_min_plot*.07)), fontsize=7) #, xycoords=trans )
        plt.annotate('bonferroni-corrected ** (0.05/10)', color='black',      xy=(p3-15, y_min_plot-(y_min_plot*.02)), fontsize=7) #, xycoords=trans)


        tit = "seed:{} target:{}-{} (fwhm{})".format(seed, target, uc, fwhm) 
        plt.title(tit )
        plt.ylabel(ylabel)

        save_tit=tit.replace(':','-').replace(' ','_').replace('(','').replace(')','')

        save_file = plot_dir+"/{}.{}.SD2.box8.png".format(save_tit, type )
        plt.savefig(save_file)

        plt.close()

        print("plot saved -- {}".format(save_file))







        # # SEM 
        # fig = figure()
        # ax = axes()

        # bon_corr = 10 
        # p_thresh = 0.05 

        # y_max = 0 
        # y_min = 0 

        # for j in range(1, len(null_layer_data_concat)):
        #     start = ((j-1)*3) + (j-1) + 1
        #     g, p1, p2, p3 = j, start, start+1, start+2 

        #     for npm in [null_layer_data_concat[g], mean_null_layer_data[g], emp_layer_data[g]]: 
        #         try: 
        #             npm_max = np.max(npm)
        #             if npm_max > y_max: 
        #                 y_max = npm_max 

        #             npm_min = np.min(npm)
        #             if npm_min < y_min: 
        #                 y_min = npm_min 
        #             #print(npm_min, npm_max )
        #         except: pass

        # y_max_annot, y_min_annot =  y_max*1.25, y_min*1.1
        # y_min_plot, y_max_plot = y_min-(np.abs(y_min)*.4), y_max*1.4
        
        # for j in range(1, len(null_layer_data_concat)):
        #     start           = ((j-1)*3) + (j-1) + 1
        #     g, p1, p2, p3   = j, start, start+1, start+2 
        #     end             = p3


        #     ax.errorbar(p1, np.mean(null_layer_data_concat[g]), yerr=np.std(null_layer_data_concat[g])/np.sqrt(len(null_layer_data_concat[g])), fmt='o', lw=3, color='blue')
        #     ax.errorbar(p2, np.mean(emp_layer_data[g]),         yerr=np.std(emp_layer_data[g])/np.sqrt(len(emp_layer_data[g])), lw=3, fmt='o', color='red')


        #     mi, ma, me = np.min(null_layer_data_concat[g]), np.max(null_layer_data_concat[g]), np.mean(null_layer_data_concat[g])
        #     ax.errorbar(p1, me, [[ me - mi],[ma - me]] ,  fmt='.', ecolor='gray', lw=1)

        #     mi, ma, me = np.min(emp_layer_data[g]), np.max(emp_layer_data[g]), np.mean(emp_layer_data[g])
        #     ax.errorbar(p2, me,[[ me - mi],[ma - me]] ,  fmt='.', ecolor='gray', lw=1)

        #     y_max_annot = np.max([np.max(null_layer_data_concat[g]), np.max(emp_layer_data[g])])
        #     y_max_annot = y_max_annot * 1.1


        #     if (emp_layer_data[g] != [0]) & (null_layer_data_concat[g] != [0]):
        #         w = scipy.stats.mannwhitneyu(emp_layer_data[g], null_layer_data_concat[g], alternative='greater')
        #         if w.pvalue < p_thresh: 
        #             plt.annotate('*', xy=(p1, y_max_annot*1.2 ), color='purple', fontsize=10)
        #                 # (p1+p2)/2
        #         if w.pvalue < p_thresh/bon_corr: 
        #             plt.annotate('**', xy=(p1, y_max_annot*1.2 ), color='purple', fontsize=10)
        #         del w 

        #         w = scipy.stats.mannwhitneyu(emp_layer_data[g], null_layer_data_concat[g], alternative='two-sided')
        #         if w.pvalue < p_thresh: 
        #             plt.annotate('*', xy=(p1, y_max_annot*1.1 ), color='blue', fontsize=10)
        #                 # (p1+p2)/2
        #         if w.pvalue < p_thresh/bon_corr: 
        #             plt.annotate('**', xy=(p1, y_max_annot*1.1 ), color='blue', fontsize=10)
        #         del w 

        #         w = scipy.stats.kruskal(emp_layer_data[g], null_layer_data_concat[g])
        #         if w.pvalue < p_thresh: 
        #             plt.annotate('*', xy=(p1, y_max_annot ), color='green', fontsize=10)
        #                 # (p1+p2)/2
        #         if w.pvalue < p_thresh/bon_corr: 
        #             plt.annotate('**', xy=(p1, y_max_annot ), color='green', fontsize=10)
        #         del w 


        #     plt.annotate('{}'.format(len(null_layer_data_concat[g])), xy=((p1+p2)/2, y_min_annot*.96), color='blue', fontsize=7)
        #     plt.annotate('{}'.format(len(emp_layer_data[g])), xy=((p1+p2)/2, y_min_annot*.9), color='red', fontsize=7)
        
        # ylim(y_min_plot, y_max_plot)

        # ax.set_xticks([1, end])
        # ax.set_xticklabels(['CSF', 'WM'])
        # hB, = plot([1,1],'b-')
        # hR, = plot([1,1],'r-')

        # legend((hB, hR),
        #                 ('NULL ({})'.format(len(nulls_3d)), 
        #                 'VASO (1)'), 
        #                     loc='lower left', prop={'size': 6})


        # hB.set_visible(False)
        # hR.set_visible(False)

        # plt.annotate('MannWhitneyU (greater) *', color='purple',    xy=(p3-15, y_min_plot-(y_min_plot*.15)), fontsize=7) #, xycoords=trans )
        # plt.annotate('MannWhitneyU (two-sided) *', color='blue',    xy=(p3-15, y_min_plot-(y_min_plot*.11)), fontsize=7) #, xycoords=trans )
        # plt.annotate('Kruskal *', color='green',                    xy=(p3-15, y_min_plot-(y_min_plot*.07)), fontsize=7) #, xycoords=trans )
        # plt.annotate('bonferroni-corrected ** (0.05/10)', color='black',      xy=(p3-15, y_min_plot-(y_min_plot*.02)), fontsize=7) #, xycoords=trans)


        # tit = "seed:{} target:{}-{} (fwhm{})".format(seed, target, uc, fwhm) 
        # plt.title(tit )
        # plt.ylabel(ylabel)

        # save_tit=tit.replace(':','-').replace(' ','_').replace('(','').replace(')','')
        # save_file = plot_dir+"/{}.{}.SE.box8.png".format(save_tit, type )
        # plt.savefig(save_file)

        # plt.close()

        # print("plot saved -- {}".format(save_file))





        fig = figure()
        ax = axes()

        bon_corr = 10 
        p_thresh = 0.05 

        y_max = 0 
        y_min = 0 

        for j in range(1, len(null_layer_data)):
            start = ((j-1)*3) + (j-1) + 1
            g, p1, p2, p3 = j, start, start+1, start+2 

            for npm in [null_layer_data[g], emp_layer_data[g]]: 
                try: 
                    npm_max = np.max(npm)
                    if npm_max > y_max: 
                        y_max = npm_max 

                    npm_min = np.min(npm)
                    if npm_min < y_min: 
                        y_min = npm_min 
                    #print(npm_min, npm_max )
                except: pass

        y_max_annot, y_min_annot =  y_max*1.25, y_min*1.1
        y_min_plot, y_max_plot = y_min-(np.abs(y_min)*.4), y_max*1.4
        
        for j in range(1, len(null_layer_data)):
            start           = ((j-1)*3) + (j-1) + 1
            g, p1, p2, p3   = j, start, start+1, start+2 
            end             = p3

            bp = ax.boxplot([null_layer_data_concat[g], emp_layer_data[g]], positions = [p1,p2], widths = 0.6)

            
            for patch, color in zip(bp['boxes'], colors):
                patch.set(color=color)


            
            y_max_annot = np.max([np.max(null_layer_data_concat[g]), np.max(emp_layer_data[g])])
            y_max_annot = y_max_annot * 1.1


            if (emp_layer_data[g] != [0]) & (null_layer_data_concat[g] != [0]):
                w = scipy.stats.mannwhitneyu(emp_layer_data[g], null_layer_data_concat[g], alternative='greater')
                if w.pvalue < p_thresh: 
                    plt.annotate('*', xy=(p1, y_max_annot*1.2 ), color='purple', fontsize=10)
                        # (p1+p2)/2
                if w.pvalue < p_thresh/bon_corr: 
                    plt.annotate('**', xy=(p1, y_max_annot*1.2 ), color='purple', fontsize=10)
                del w 

                w = scipy.stats.mannwhitneyu(emp_layer_data[g], null_layer_data_concat[g], alternative='two-sided')
                if w.pvalue < p_thresh: 
                    plt.annotate('*', xy=(p1, y_max_annot*1.1 ), color='blue', fontsize=10)
                        # (p1+p2)/2
                if w.pvalue < p_thresh/bon_corr: 
                    plt.annotate('**', xy=(p1, y_max_annot*1.1 ), color='blue', fontsize=10)
                del w 

                w = scipy.stats.kruskal(emp_layer_data[g], null_layer_data_concat[g])
                if w.pvalue < p_thresh: 
                    plt.annotate('*', xy=(p1, y_max_annot ), color='green', fontsize=10)
                        # (p1+p2)/2
                if w.pvalue < p_thresh/bon_corr: 
                    plt.annotate('**', xy=(p1, y_max_annot ), color='green', fontsize=10)
                del w 

            plt.annotate('{}'.format(len(null_layer_data[g])), xy=(p1, y_min_annot*.95), color='blue', fontsize=7)
            plt.annotate('{}'.format(len(emp_layer_data[g])), xy=(p1, y_min_annot*.9), color='red', fontsize=7)
        
        ylim(y_min_plot, y_max_plot)

        ax.set_xticks([1, end])
        ax.set_xticklabels(['CSF', 'WM'])
        hB, = plot([1,1],'b-')
        hR, = plot([1,1],'r-')

        legend((hB, hR),
                        ('NULL ({})'.format(len(nulls_3d)), 
                        'VASO (1)'), 
                            loc='lower left', prop={'size': 6})


        hB.set_visible(False)
        hR.set_visible(False)

        plt.annotate('MannWhitneyU (greater) *', color='purple',    xy=(p3-15, y_min_plot-(y_min_plot*.15)), fontsize=7) #, xycoords=trans )
        plt.annotate('MannWhitneyU (two-sided) *', color='blue',    xy=(p3-15, y_min_plot-(y_min_plot*.11)), fontsize=7) #, xycoords=trans )
        plt.annotate('Kruskal *', color='green',                    xy=(p3-15, y_min_plot-(y_min_plot*.07)), fontsize=7) #, xycoords=trans )
        plt.annotate('bonferroni-corrected ** (0.05/10)', color='black',      xy=(p3-15, y_min_plot-(y_min_plot*.02)), fontsize=7) #, xycoords=trans)



        tit = "seed:{} target:{}-{} (fwhm{})".format(seed, target, uc, fwhm) 
        plt.title(tit )
        plt.ylabel(ylabel)

        save_tit=tit.replace(':','-').replace(' ','_').replace('(','').replace(')','')
        save_file = plot_dir+"/{}.{}.bp.box8.png".format(save_tit, type )
        plt.savefig(save_file)

        plt.close()

        print("plot saved -- {}".format(save_file))






if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--base_dir', type=str)
    parser.add_argument('--k', type=str)
    parser.add_argument('--fwhm', type=int)
    parser.add_argument('--c', type=int)
    parser.add_argument('--plot_dir', type=str)
    parser.add_argument('--type', type=str)
    parser.add_argument('--nulls', type=str, nargs='+')



    args = parser.parse_args()

    k           = args.k 
    fwhm        = args.fwhm
    base_dir    = args.base_dir
    c           = args.c 
    plot_dir    = args.plot_dir 
    type        = args.type
    nulls       = args.nulls 

    if type == None: 
        print("specify type")
        exit 
    elif type == 'corr': 
        print("type == corr")
    elif type == "regress":
        print("type == regress")
    else: 
        print("type == unknown")
        exit 

        

    get_plots(base_dir, k=k,c=c, fwhm=fwhm, plot_dir=plot_dir, type=type, nulls=nulls)

'''
rois=(L_FEF L_LIPv L_VIP L_V4t R_V4 R_V2 R_V3 L_V1 L_MST L_MT
    L_TF L_TE1a L_TE1p L_TE2a L_TE2p L_FST)

for r in ${rois[@]}; do 
    echo "python analysis_nullDist_FEF.py --k $r " >> swarm.plots
done 

'''


            # # sign rank 
            # try:
            #     w = scipy.stats.kruskal(emp_layer_data[g], null_layer_data[g])
            #     if w.pvalue < p_thresh: 
            #     #     plt.annotate('* {0:.1E}'.format(w.pvalue), xy=(p3, np.max(emp_layer_data[g])*1.1 ), color='blue', fontsize=5)
            #     # elif w.pvalue < p_thresh/bon_corr: 
            #     #     plt.annotate('** {0:.1E}'.format(w.pvalue), xy=(p3, np.max(emp_layer_data[g])*1.1 ), color='blue', fontsize=5)
            #         plt.annotate('* {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot ), color='blue', fontsize=7)
            #     elif w.pvalue < p_thresh/bon_corr: 
            #         plt.annotate('** {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot ), color='blue', fontsize=7)



            # except: 
            #     pass 

            # # equal sample 
            # try:
            #     w = scipy.stats.wilcoxon(emp_layer_data[g], y=mean_null_layer_data[g], alternative='two-sided')
            #     if w.pvalue < p_thresh: 
            #     #     plt.annotate('* {0:.1E}'.format(w.pvalue), xy=(p3, np.max(emp_layer_data[g])*1.3), color='green', fontsize=5)
            #     # elif w.pvalue < p_thresh/bon_corr: 
            #     #     plt.annotate('** {0:.1E}'.format(w.pvalue), xy=(p3, np.max(emp_layer_data[g])*1.1 ), color='blue', fontsize=5)
            #         plt.annotate('* {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot*.9), color='green', fontsize=7)
            #     elif w.pvalue < p_thresh/bon_corr: 
            #         plt.annotate('** {0:.1E}'.format(w.pvalue), xy=(p3, y_max_annot*.9), color='green', fontsize=7)
