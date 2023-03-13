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
from scipy.cluster.hierarchy import inconsistent

from sklearn.preprocessing import scale 


def to_gif(filenames, saveas): 
    images = []
    for filename in filenames:
        images.append(imageio.imread(filename))
    imageio.mimsave(saveas, images, duration=0.75 )


def get_pcs(X_train, nComp=None, idComp=None): 
    # https://stats.stackexchange.com/questions/229092/how-to-reverse-pca-and-reconstruct-original-variables-from-several-principal-com
    
    #X = FEF_cat
    #print("shape: "+ str(X_train.shape))
    
    mu = np.mean(X_train, axis=0)

    pca = sklearn.decomposition.PCA()
    pca.fit(X_train)

    if nComp != None: 
        #nComp = 2
        X_projected = np.dot(pca.transform(X_train)[:,:nComp], pca.components_[:nComp,:])
        X_projected += mu

    elif idComp != None: 
        #idComp = 2
        X_projected = np.dot(pca.transform(X_train)[:,idComp].reshape([ X_train.shape[0],1]), pca.components_[idComp,:].reshape([1, X_train.shape[1]]))
        X_projected += mu


    X_train_pca = pca.transform(X_train)[:,:nComp]
    
    exp_var = pca.explained_variance_ratio_[:nComp]

    loss = np.sum((X_train - X_projected) ** 2, axis=1).mean()

    #print(Xhat[0,])
    #print(Xhat[0,].shape)
    #print(Xhat.shape)
    
    
    # return pcs, recon, loss, cumLoss, 
    return X_train_pca, X_projected, exp_var, loss

def get_pcs_v2(X_train, nComp=None): 
    # https://stats.stackexchange.com/questions/229092/how-to-reverse-pca-and-reconstruct-original-variables-from-several-principal-com
    
    #print("shape: {}".format(X_train.shape))
    
    # we need (TRs x Voxels)
    assert(X_train.shape[0] == 180)
    
    
    # create pca object
    # nComp determines how many PCs we want ex. 10 
    pca = sklearn.decomposition.PCA(n_components=nComp)

    # X_train_pca is the nComp PCs ex. 10 
    #  X_train_pca.shape == (180, 5)
    X_train_pca = pca.fit_transform(X_train)
    assert(X_train_pca.shape == (180,nComp) )
    
    
    # X_projected is the PC projected back into signal space 
    X_projected = pca.inverse_transform(X_train_pca)
    assert(X_projected.shape == X_train.shape)
    
    exp_var = pca.explained_variance_ratio_
    assert(exp_var.shape == (nComp,))
    
    
    loss = np.sum((X_train - X_projected) ** 2, axis=1).mean()

    # returns
    #   PCs
    #   the PCs projected to singnal space (same dimensions as input data)
    #   explained variance for each PC 
    #   loss    
    return X_train_pca, X_projected, exp_var, loss


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

    n_comp = 30 

    X_train = np.random.randn(100, 50)
    #X_train = FEF_cat 
    
    pca = PCA(n_components=n_comp)
    pca.fit(X_train)

    U, S, VT = np.linalg.svd(X_train - X_train.mean(0), full_matrices=False)
    U, VT = svd_flip(U, VT)
    assert_array_almost_equal(VT[:n_comp], pca.components_, decimal=2)

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
    print("loss: {}".format(np.sum((X_train - X_projected2) ** 2, axis=1).mean()))


    ## SIMPLE 
    
    #n_comp = 30 

    #X_train = np.random.randn(100, 50)
    X_train = FEF_cat.T
    
        
    for n_comp in [0, 1, 2, 5, 10, 30, 50]:
        
        pca = PCA(n_components=n_comp)
        pca.fit(X_train)

        print("X_train.shape {}".format(X_train.shape))
        print("components.shape {}".format(pca.components_.shape))
        ## pca.transform calculates the loadings
        X_train_pca = pca.transform(X_train)
        print("loadings {}".format(X_train_pca.shape))
        
        X_train_pca2 = pca.fit_transform(X_train)
        print("loadings2 {}".format(X_train_pca2.shape))

        ## pca.inverse_transform obtains the projection onto 
        ## components in signal space you are interested in
        X_projected = pca.inverse_transform(X_train_pca)

        ## You can now evaluate the projection loss
        print("loss: {}".format(np.sum((X_train - X_projected) ** 2, axis=1).mean()))


        # # Plot the explained variance
        # model.plot()
        # # Biplot with the loadings
        # ax = model.biplot(legend=False)
        # # Biplot with the loadings
        # ax = model.biplot(n_feat=3, legend=False, label=False)
        # # Cleaning the biplot by removing the scatter, and looking only at the top 3 features.
        # ax = model.biplot(n_feat=3, legend=False, label=False, cmap=None)
        # # Make plot with 3 dimensions
        # model.biplot3d(n_feat=3, legend=False, label=False, cmap=None)






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
plot_dir=work_dir+"/plots_scaled"

img_path = "/data/NIMH_scratch/kleinrl/gdown/parc_hcp_kenshu_uthr.nii.gz"
img = nib.load(img_path)
img_data = img.get_fdata()
            

sess = glob(timeseries_maindir+"/VASO_grandmean_WITHOUT-ses-13_spc_despike")
#sess+= glob(timeseries_maindir+"/sub*_spc_despike")
#sess = sess[0:3]

roi="FEF"
#types = ["ward"] #, "centroid", "median", "weighted", "average", "complete", "single" ]
types = ["ward", "centroid", "median", "weighted", "average", "complete", "single" ]


cophenet_coefs = []
cophenet_coefs.append(['ses', 'type', 'i', 'corr_coef_sp', 'corr_coef_pe'])

for ses in sess:
    for type in types: 
        for i in [-1, 3, 5, 7 ]: #, 1, 2, 3, 4, 5, 6, 7]:#, 8, 9, 10, 11, 12, 15, 20, 25, 30]:


            plot_file           = plot_dir+'/clust_'+type+"_"+str(i)+"_"+ses.split('/')[-1]+"_"+roi+".jpeg"    
            plot_file_hist      = plot_dir+'/hist_'+type+"_"+str(i)+"_"+ses.split('/')[-1]+"_"+roi+".jpeg"    
            plot_file_voxs      = plot_dir+'/voxs_'+type+"_"+str(i)+"_"+ses.split('/')[-1]+"_"+roi+".jpeg"    
            plot_nifti_clusters = data_dir+'/clustVoxs2_'+type+"_"+str(i)+"_"+ses.split('/')[-1]+"_"+roi+".nii.gz"  


            #ts_FEF_2D=glob(ses+"/*"+roi+"*.2D")
            ts_FEF_2D=glob(ses+"/*"+roi+"*ijk.2D")
            ts_FEF_1D=glob(ses+"/*"+roi+"*.1D")
            
            ts_FEF_2D.sort()
            ts_FEF_1D.sort()


            FEF     = [ np.loadtxt(x) for x in ts_FEF_2D ] 
            FEF_ind = np.concatenate([len(x)*[y+1] for x,y in zip(FEF, range(0,len(FEF))) ])
            FEF_cat = np.concatenate(FEF)

            FEF_ijk = FEF_cat[:,:3]
            FEF_cat = FEF_cat[:,3:]

            X = scale(FEF_cat.T)
            X_T = X.T
            

            if i == -1: 
                D = np.corrcoef(X_T)
                D_pdist = pdist(X_T)
            else: 

                #X_train_pca, X_projected, exp_var, loss       = get_pcs(X, nComp=i)
                X_train_pca, X_projected, exp_var, loss       = get_pcs_v2(X, nComp=i)
                #X_train_pca, X_projected, exp_var, loss       = get_pcs_v2(FEF_cat.T, nComp=i)


                D = np.corrcoef(X_projected.T)
                D_pdist = pdist(X_projected.T)


            len_rois = D.shape[0]


            size=(12,12)
            fig = pylab.figure(figsize=size)
            plt.title(plot_file.split('/')[-1])


            axdendro = fig.add_axes([0.09,0.1,0.2,0.8])
            Y = sch.linkage(D, method=type)
            Z = sch.dendrogram(Y, orientation='right')


            cophe_dists = cophenet(Y)
            #orig_dists = pdist(D, metric='cityblock')#'euclidean')
            orig_dists = pdist(D, metric='euclidean')


            corr_coef_sp = spearmanr(orig_dists, cophe_dists)
            corr_coef_pe = np.corrcoef(orig_dists, cophe_dists)[0,1]
            
            #print("type:    {}\nSpearman:   {} \nPearson:   {}\n".format(type, corr_coef_sp[0], corr_coef_pe))
            print("{}   {}    {}   {}".format(type, i, corr_coef_sp[0], corr_coef_pe))

            
            cophenet_coefs.append([ses, type, i, corr_coef_sp[0], corr_coef_pe])
            
            #inconsistent(Y)
            """
            ward   -1       0.24470025084193034     0.29201046109784506
            ward   3        0.5021522716285319      0.5752291595069093
            ward   5        0.40494496940935165     0.44955005385557745
            ward   7        0.3323001564260219      0.40780775947036096
            centroid   -1   0.05979888667611828     0.10106087741554723
            centroid   3    0.6202011130330177      0.6682890007228585
            centroid   5    0.545857448985706       0.5842972132606946
            centroid   7    0.459118169238346       0.5065164455081683
            median   -1     0.06738679455519428     0.08737163520057448
            median   3      0.5421675222733277      0.6076323985721452
            median   5      0.4044780613411011      0.46140138268507547
            median   7      0.27256580931601737     0.33533451175631207
            weighted   -1   0.25141552368023173     0.32177403461460324
            weighted   3    0.6113909194798812      0.6393565133913255
            weighted   5    0.35395218576607584     0.4495845207166713
            weighted   7    0.35863537216968894     0.4351849925264713
            average   -1    0.3086997056677497      0.35637979630172345
            average   3     0.6054615988462017      0.6615187387157158
            average   5     0.5100858653218207      0.5724912826528012
            average   7     0.4187807116790556      0.5027376350739609
            complete   -1   0.2147912248491971      0.27347938540888045
            complete   3    0.6048554501342898      0.6393438976596559
            complete   5    0.44931649683308816     0.5068127964152372
            complete   7    0.44219122047806736     0.4859092968462903
            single   -1     0.05157979787438299     0.08486219659736799
            single   3      0.6214209649069805      0.5644545735135343
            single   5      0.43591942190528943     0.4566791689158187
            single   7      0.356258068333302       0.39091400655042774
            """

            index               = Z['leaves']
            color_list          = Z['color_list']
            #leaves_color_list   = Z['leaves_color_list']

            """
            NEED TO LOOK INTO THIS; 
                index           == 1848
                color_list      == 1847
                FEF_cat.shape   == 1848
            
            """
            
            if FEF_ind.shape[0] != len(index):
                #FEF_ind = FEF_ind[0:-1]
                #FEF_ijk = FEF_ijk[0:-1]
                index = index[0:-1]
            
            index_array = np.array(index)
            
            X_sorted        = X[:, index]
            X_T_sorted      = X_T[index, :]
            
            FEF_ijk_sorted  = FEF_ijk[index,:]
            FEF_ind_sorted  = FEF_ind[index]
            
            
            
            
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
                #lay_counts = FEF_ind[ind_color]
                #ijk_coord = FEF_ijk[ind_color,:]
                
                lay_counts = FEF_ind_sorted[ind_color]
                ijk_coord = FEF_ijk_sorted[ind_color,:]
                
                ijk_coords.append(ijk_coord)
                ijk_coords_lab.append(u)
                
                vox_by_color_ind = index_array[np.where(ind_color)]
                #voxs_by_color_inds.append(vox_by_color_ind)
                #vox_by_color.append(FEF_cat[vox_by_color_ind])
                vox_by_color.append(X[:,vox_by_color_ind])

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