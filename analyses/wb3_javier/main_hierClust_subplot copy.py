import numpy as np 
import nibabel as nib 
from glob import glob 
import matplotlib.pyplot as plt 

from sklearn.preprocessing import MinMaxScaler
from sklearn.decomposition import PCA
import argparse
import numpy as np 
#import pingouin as pg
#!pip install pingouin
#import pingouin as pg
#pg.partial_corr(data=df, x='A', y='B', covar='Z')
import pandas as pd 
import os 
from numpy.testing import assert_array_almost_equal

import numpy as np
import sklearn.datasets, sklearn.decomposition
import matplotlib.pyplot as plt
import pylab
import scipy.cluster.hierarchy as sch
from scipy.cluster.hierarchy import cut_tree, fcluster, cophenet
import imageio
from scipy.spatial.distance import pdist 
from scipy.stats import spearmanr
import nibabel as nib


def to_gif(filenames, saveas): 
    images = []
    for filename in filenames:
        images.append(imageio.imread(filename))
    imageio.mimsave(saveas, images, duration=0.75 )


def get_pcs(X, nComp=None, idComp=None): 
    # https://stats.stackexchange.com/questions/229092/how-to-reverse-pca-and-reconstruct-original-variables-from-several-principal-com
    # https://stackoverflow.com/questions/36566844/pca-projection-and-reconstruction-in-scikit-learn
    
    
    #X = FEF_cat
    #print("shape: "+ str(X.shape))
    
    mu = np.mean(X, axis=0)

    pca = sklearn.decomposition.PCA()
    pca.fit(X)

    if nComp != None: 
        #nComp = 2
        Xhat = np.dot(pca.transform(X)[:,:nComp], pca.components_[:nComp,:])
        Xhat += mu
        
        

    elif idComp != None: 
        #idComp = 2
        Xhat = np.dot(pca.transform(X)[:,idComp].reshape([ X.shape[0],1]), pca.components_[idComp,:].reshape([1, X.shape[1]]))
        Xhat += mu


    data_pca = pca.transform(X)
    
    exp_var = pca.explained_variance_ratio_


    #print(Xhat[0,])
    #print(Xhat[0,].shape)
    #print(Xhat.shape)
    
    
    # return pcs, recon, loss, cumLoss, 
    return data_pca, Xhat, exp_var 


def get_pcs_simple(X, nComp=None): 
    # https://stats.stackexchange.com/questions/229092/how-to-reverse-pca-and-reconstruct-original-variables-from-several-principal-com
    # https://stackoverflow.com/questions/36566844/pca-projection-and-reconstruction-in-scikit-learn
    
    X.shape # (1848, 180) (Voxels, Timepoints)

    #pca = sklearn.decomposition.PCA(n_components=10)
    pca = sklearn.decomposition.PCA()

    pca.fit(X) # 	Fit the model with X.
    
    print(pca.explained_variance_ratio_)
    
    
    data_pca = pca.transform(X) # Apply dimensionality reduction to X.
    
    
    data_proj = pca.inverse_transform(X_train_pca)

    
    
    return data_pca, Xhat, exp_var 


def get_pcs_tutorial(): 
    # https://stackoverflow.com/questions/36566844/pca-projection-and-reconstruction-in-scikit-learn
    
    from sklearn.decomposition import PCA
    import numpy as np
    from numpy.testing import assert_array_almost_equal
    from sklearn.utils.extmath import svd_flip 

    X_train = np.random.randn(100, 50)

    pca = PCA(n_components=30)
    pca.fit(X_train)

    U, S, VT = np.linalg.svd(X_train - X_train.mean(0), full_matrices=False)
    U, VT = svd_flip(U, VT)
    assert_array_almost_equal(VT[:30], pca.components_)

    ## pca.transform calculates the loadings
    X_train_pca = pca.transform(X_train)
    X_train_pca2 = (X_train - pca.mean_).dot(pca.components_.T)
    assert_array_almost_equal(X_train_pca, X_train_pca2)


    ## pca.inverse_transform obtains the projection onto 
    ## components in signal space you are interested in
    X_projected = pca.inverse_transform(X_train_pca)
    X_projected2 = X_train_pca.dot(pca.components_) + pca.mean_
    assert_array_almost_equal(X_projected, X_projected2)


    ## You can now evaluate the projection loss

    print("loss: {}".format(np.sum((X_train - X_projected) ** 2, axis=1).mean()))
    print("loss: {}".format(np.sum((X_train - X_projected) ** 2, axis=1).mean()))


def cluster(o_array, save_path, dpi=400, size=(24,24)):
    '''
    o_array=array
    df=ids
    path='./hierarchicalClust'
    dpi=400
    size=(24,24)
    '''

    #if not os.path.exists(save_path):
    #    os.makedirs(save_path)

    print("o_array shape: {}".format(o_array.shape))

    D = np.corrcoef(o_array)

    print("D shape: {}".format(D.shape))

    len_rois = D.shape[0]

    # Compute and plot dendrogram.
    fig = pylab.figure(figsize=size, dpi=dpi)
    
    
    axdendro = fig.add_axes([0.09,0.1,0.2,0.8])
    Y = sch.linkage(D, method='centroid')
    Z = sch.dendrogram(Y, orientation='right')

    index           = Z['leaves']
    #labels          = [ '-'.join([df['r1'].iloc[l], df['r2'].iloc[l]]) for l in range(df.shape[0]) ]
    #labels_reorg    = [ labels [x] for x in index ]
    labels_reorg = ids 

    #axdendro.set_xticks([])
    #axdendro.set_yticks([])
    #axdendro.set_xticks(range(len_rois))
    #axdendro.set_yticks(range(len_rois))
    #axdendro.set_xticklabels(labels_reorg)
    axdendro.set_yticklabels(labels_reorg)

    # Plot distance matrix.
    axmatrix = fig.add_axes([0.3,0.1,0.6,0.8])

    D = D[index,:]
    D = D[:,index]

    im = axmatrix.matshow(D, aspect='auto', origin='lower')
    axmatrix.set_xticks([])
    axmatrix.set_yticks([])

    # Plot colorbar.
    axcolor = fig.add_axes([0.91,0.1,0.02,0.8])
    pylab.colorbar(im, cax=axcolor)

    # Display and save figure.
    fig.show()

    plt.savefig(os.path.join(save_path,'dendrogram.ALL.jpeg'))

    plt.close()

    return Y,Z

work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_afni"
data_dir=work_dir+"/data"

out_dir=work_dir+"/out"
roi_dir=work_dir+"/rois"
timeseries_maindir=work_dir+"/timeseries"
plot_dir=work_dir+"/plots_despike"

img_path = "/data/NIMH_scratch/kleinrl/gdown/parc_hcp_kenshu_uthr.nii.gz"
img = nib.load(img_path)
img_data = img.get_fdata()
            

sess = glob(timeseries_maindir+"/VASO_grandmean_WITHOUT-ses-13_spc_despike")
sess+= glob(timeseries_maindir+"/sub*_spc_despike")
#sess = sess[0:3]

roi="FEF"
types = ["ward"] #, "centroid", "median", "weighted", "average", "complete", "single" ]
#types = ["ward", "centroid", "median", "weighted", "average", "complete", "single" ]


for ses in sess:
    for type in types: 
        for i in [-1, 0, 1, 2, 3, 4, 5, 6, 7]:#, 8, 9, 10, 11, 12, 15, 20, 25, 30]:

            
            plot_file           = plot_dir+'/clust_'+type+"_"+str(i)+"_"+ses.split('/')[-1]+"_"+roi+".jpeg"    
            plot_file_hist      = plot_dir+'/hist_'+type+"_"+str(i)+"_"+ses.split('/')[-1]+"_"+roi+".jpeg"    
            plot_file_voxs      = plot_dir+'/voxs_'+type+"_"+str(i)+"_"+ses.split('/')[-1]+"_"+roi+".jpeg"    
            plot_nifti_clusters = data_dir+'/clustVoxs_'+type+"_"+str(i)+"_"+ses.split('/')[-1]+"_"+roi+".nii.gz"  


            #ts_FEF_2D=glob(ses+"/*"+roi+"*.2D")
            ts_FEF_2D=glob(ses+"/*"+roi+"*ijk.2D")
            ts_FEF_1D=glob(ses+"/*"+roi+"*.1D")
            
            ts_FEF_2D.sort()
            ts_FEF_1D.sort()


            FEF     = [ np.loadtxt(x) for x in ts_FEF_2D ] 
            FEF_ind = np.concatenate([len(x)*[y+1] for x,y in zip(FEF, range(0,len(FEF))) ])
            #FEF_ind = np.concatenate([len(x)*[y] for x,y in zip(FEF, range(0,len(FEF))) ])
            FEF_cat = np.concatenate(FEF)

            FEF_ijk = FEF_cat[:,:3]
            FEF_cat = FEF_cat[:,3:]


            if i == -1: 
                D = np.corrcoef(FEF_cat)
                D_pdist = pdist(FEF_cat)
            else: 
                data_pca, Xhat, exp_var = get_pcs(FEF_cat, nComp=i)
                D = np.corrcoef(Xhat)
                D_pdist = pdist(Xhat)


            #print("D shape: {}".format(D.shape))

            len_rois = D.shape[0]

                    # Compute and plot dendrogram.
                    # dpi=400
                    # size=(24,24)
                    # fig = pylab.figure(figsize=size, dpi=dpi)

            size=(12,12)
            fig = pylab.figure(figsize=size)
            
            
            
                    #fig = pylab.figure(nrows=2, ncols=5)#), dpi=dpi)
            #fig, axs = plt.subplots(ncols=5, nrows=4, figsize=(15,12))#, layout="constrained")
            #axdendro = plt.subplot(1,2,nrows=2, ncols=2)
            
            plt.title(plot_file.split('/')[-1])


            axdendro = fig.add_axes([0.09,0.1,0.2,0.8])
            Y = sch.linkage(D, method=type) # 'centroid'
            Z = sch.dendrogram(Y, orientation='right')

            cophe_dists = cophenet(Y)
            orig_dists = pdist(D)
            
            #orig_dists = D_pdist
            #orig_dists = D[np.triu_indices(D.shape[0], k=1)]

            #orig_dists = D[np.triu_indices(D.shape[0], k=1)]


            #corr_coef = np.corrcoef(orig_dists, cophe_dists)[0,1]
            corr_coef_sp = spearmanr(orig_dists, cophe_dists)
            corr_coef_pe = np.corrcoef(orig_dists, cophe_dists)[0,1]
            
            print("type: {}\n {} \nPearson: {}\n".format(type, corr_coef_sp, corr_coef_pe))




            index               = Z['leaves']
            color_list          = Z['color_list']
            #leaves_color_list   = Z['leaves_color_list']

            """
            NEED TO LOOK INTO THIS; 
                index           == 1848
                color_list      == 1847
                FEF_cat.shape   == 1848
            
            """
            
            if FEF_ind.shape[0] != len(color_list):
                FEF_ind = FEF_ind[0:-1]
                FEF_ijk = FEF_ijk[0:-1]

            
            index_array = np.array(index)
            
            
            chart = []
            to_plot = []
            to_plot_labs =[]
            voxs_by_color = []
            voxs_by_color_inds = []
            vox_by_color = []
            
            ijk_coords = []
            ijk_coords_lab = []
            
            for u in np.unique(color_list): 
                ind_color = np.isin(color_list, u)
                lay_counts = FEF_ind[ind_color]
                ijk_coord = FEF_ijk[ind_color,:]
                
                ijk_coords.append(ijk_coord)
                ijk_coords_lab.append(u)
                
                vox_by_color_ind = index_array[np.where(ind_color)]
                voxs_by_color_inds.append(vox_by_color_ind)
                vox_by_color.append(FEF_cat[vox_by_color_ind])
                
                # FEF_cat[vox_by_color_ind]
                
                #print(" ")
                to_plot.append(lay_counts)
                to_plot_labs.append(u)
                
                for uu in range(8):
                    ind = np.where(lay_counts == uu)
                    
                    #print("{}    {}    {}    {}".format(u, uu,len(ind[0]),  len(ind[0])/len(ind_color)*100))
                    chart.append([u, uu,len(ind[0]),  len(ind[0])/len(ind_color)*100])

            chart = pd.DataFrame(chart)
            #to_plot = np.concatenate(to_plot)
            
            
            
            
            ##### SAVING CLUSTERS TO VOUME 
            # img_path = "/data/NIMH_scratch/kleinrl/gdown/parc_hcp_kenshu_uthr.nii.gz"
            # img = nib.load(img_path)
            # img_data = img.get_fdata()
            # img_data = np.zeros(shape=img_data.shape)
            
            out_data = np.zeros(shape=img_data.shape)

            c_count = 1 
            for ijk_clust in ijk_coords:
                for ijk_ind in ijk_clust:
                    ijk_ind = ijk_ind.astype(int)
                    out_data[ijk_ind[0],ijk_ind[1], ijk_ind[2]] = c_count 
                    
                c_count += 1 
            
            clipped_img = nib.Nifti1Image(out_data, img.affine, img.header)
            
            nib.save(clipped_img, plot_nifti_clusters)
            
            

            #labels_reorg = ids 

            axdendro.set_xticks([])
            axdendro.set_yticks([])
            
            # fix this need to assign labels 
            #axdendro.set_yticklabels(labels_reorg)

            # Plot distance matrix.
            axmatrix = fig.add_axes([0.3,0.1,0.6,0.8])
            #axmatrix = plt.subplot(1,1,ncols=2, nrows=2)
            
            D = D[index,:]
            D = D[:,index]

            #FEF_ijk_sorted = FEF_ijk[index,:]
            
            

            im = axmatrix.matshow(D, aspect='auto', origin='lower')
            
            axmatrix.set_xticks([])
            axmatrix.set_yticks([])

            # Plot colorbar.
            axcolor = fig.add_axes([0.91,0.1,0.02,0.8])
            pylab.colorbar(im, cax=axcolor)

            # Display and save figure.
            fig.show()
            plt.savefig(plot_file)
            plt.close()
            
            
            
            
            # HIST PLOTS 
            fig = pylab.figure(figsize=size)
            plt.hist(to_plot, 7, label=to_plot_labs, histtype='bar', stacked=False, fill=True)
            plt.legend(prop={'size': 10})
            plt.title(plot_file.split('/')[-1])
            plt.savefig(plot_file_hist)
            plt.close()



            # VOX PLOTS 
            fig = pylab.figure(figsize=size)
            p = []
            for i_vox in range(len(vox_by_color)):
                voxs    = vox_by_color[i_vox]
                mu      = np.mean(voxs, axis=0)
                stdev   = np.std(voxs, axis=0)
                
                plt.plot(mu, label=to_plot_labs[i_vox])
                plt.fill_between(range(mu.shape[0]),mu-stdev,mu+stdev,alpha=.1)

            plt.legend(loc="upper right") #p, to_plot_labs, prop={'size': 10}
            plt.title(plot_file.split('/')[-1])
            plt.savefig(plot_file_voxs)
            plt.close()

            
            FEF_cat_sorted = FEF_cat[index]
            
            rois2 = [   "L_V1",
                        "L_V2",
                        "L_V3",
                        "L_V4",
                        #"L_FST",
                        "L_PH",
                        "L_MS",
                        "L_LO3",
                        "L_MT",
                        "L_V4t",
                        "L_MST",
                        "L_VIP",
                        "L_VIP",
                                                
                        "L_LIPv",
                        "L_LIPd",

                        "L_7Pm",
                        "L_7m",
                        "L_7AL",
                        "L_7Am",
                        "L_7PL",
                        "L_7PC",
                        ]
            
            for roi2 in rois2:
            
                ts_ROI2_2D=glob(ses+"/*"+roi2+"*ijk.2D")
                ts_ROI2_1D=glob(ses+"/*"+roi2+"*.1D")
                ts_ROI2_2D.sort()
                ts_ROI2_1D.sort()

                ROI2     = [ np.loadtxt(x) for x in ts_ROI2_2D ] 
                ROI2_ind = np.concatenate([len(x)*[y+1] for x,y in zip(ROI2, range(0,len(ROI2))) ])
                ROI2_cat = np.concatenate(ROI2)
                
        

                ROI2_ijk = ROI2_cat[:,:3]
                ROI2_cat = ROI2_cat[:,3:]
                    
                    
                
                
                plot_file_corr = plot_dir+'/corr_'+roi2+"_"+type+"_"+str(i)+"_"+ses.split('/')[-1]+"_"+roi+".jpeg"    
                cat = np.concatenate([FEF_cat_sorted, ROI2_cat])
                c = np.corrcoef(cat)
                fig = pylab.figure(figsize=size)
                p = plt.imshow(c)
                fig.colorbar(p)
                plt.title(plot_file.split('/')[-1])
                plt.savefig(plot_file_corr)
                plt.close()

                
                
                # SINGLE COMP 
                plot_file_corr_single = plot_dir+'/corrSingle_'+roi2+"_"+type+"_"+str(i)+"_"+ses.split('/')[-1]+"_"+roi+".jpeg"    
                len_x=FEF_cat_sorted.shape[0]
                len_y=ROI2_cat.shape[0]
                cc = c[:len_x,len_x:]
                fig = pylab.figure(figsize=size)
                p = plt.imshow(cc)
                fig.colorbar(p)
                plt.title(plot_file.split('/')[-1])
                plt.savefig(plot_file_corr_single)
                plt.close()
            
            print(type, ses,i)
            
            
            
    filenames=glob(plot_dir+"/clust*"+type+"_"+str(i)+"_*FEF.jpeg")
    saveas=plot_dir+"/clust_"+type+"_"+str(i)+"_FEF.gif"
    to_gif(filenames, saveas)      
                
    filenames=glob(plot_dir+"/hist*"+type+"_"+str(i)+"_*FEF.jpeg")
    saveas=plot_dir+"/hist_"+type+"_"+str(i)+"_FEF.gif"
    to_gif(filenames, saveas)      
            
    filenames=glob(plot_dir+"/voxs*"+type+"_"+str(i)+"_*FEF.jpeg")
    saveas=plot_dir+"/voxs_"+type+"_"+str(i)+"_FEF.gif"
    to_gif(filenames, saveas)      
            
            
# plot the clustered timeseires 
#   averages
#   individual voxs 
# skew plots 
# summary plots voxs per layer 
# correlated the clustered timerseries 
#       across brian, but also nuisance timecousrses csf, resp
#       


    """
    
import numpy as np 
import nibabel as nib 
from glob import glob 
import matplotlib.pyplot as plt 

from sklearn.preprocessing import MinMaxScaler
from sklearn.decomposition import PCA
import argparse
import numpy as np 
#import pingouin as pg
#!pip install pingouin
#import pingouin as pg
#pg.partial_corr(data=df, x='A', y='B', covar='Z')
import pandas as pd 
import os 
from numpy.testing import assert_array_almost_equal

import numpy as np
import sklearn.datasets, sklearn.decomposition
import matplotlib.pyplot as plt
import pylab
import scipy.cluster.hierarchy as sch
from scipy.cluster.hierarchy import cut_tree, fcluster
import imageio


def to_gif(filenames, saveas): 
    images = []
    for filename in filenames:
        images.append(imageio.imread(filename))
    imageio.mimsave(saveas, images, duration=0.75 )



work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_javier"
data_dir=work_dir+"/data"
out_dir=work_dir+"/out"
roi_dir=work_dir+"/rois"
timeseries_maindir=work_dir+"/timeseries"
plot_dir=work_dir+"/plots"


sess = glob(timeseries_maindir+"/VASO_grandmean_WITHOUT-ses-13_spc")
sess+= glob(timeseries_maindir+"/sub*_spc")
#sess = sess[0:3]

roi="FEF"
types = ["ward", "centroid", "median", "weighted", "average", "complete", "single" ]

for type in types: 
    for i in [-1, 0, 1, 2, 3, 4, 5, 7]:
        try: 
    
            filenames=glob(plot_dir+"/clust*"+type+"_"+str(i)+"_*FEF.jpeg")
            saveas=plot_dir+"/clust_"+type+"_"+str(i)+"_FEF.gif"
            to_gif(filenames, saveas)      
                        
            filenames=glob(plot_dir+"/hist*"+type+"_"+str(i)+"_*FEF.jpeg")
            saveas=plot_dir+"/hist_"+type+"_"+str(i)+"_FEF.gif"
            to_gif(filenames, saveas)      
                    
            filenames=glob(plot_dir+"/voxs*"+type+"_"+str(i)+"_*FEF.jpeg")
            saveas=plot_dir+"/voxs_"+type+"_"+str(i)+"_FEF.gif"
            to_gif(filenames, saveas)      
        except: 
            print("")
    
    
    """