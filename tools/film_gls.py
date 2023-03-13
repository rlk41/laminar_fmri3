#!/usr/bin/env python


"""Python implementation of FILM GLS algorithm.

Plans for development:

We will need the following functionality:

GLS fit for 4D timeseries (i, j, k, t), with smoothing in volume or on surface
GLS for for 2D array (time x vox) array, with single prewhitening matrix

We'll call the first "local" and the latter "regional" prewhitening

Which means we'll want the following functions:

- Interface for 4D data
- Interface for 2D data
- General interface?
- Autocorrelation estimation
- Autocorrelation smoothing
- Prewhitening 4D data
- Prewhitening 2D data
- Iterative OLS fit for locally prewhitened data
- Single step (?) OLS fit for regionally prewhitened data

"""
import numpy as np
import nibabel as nib
import argparse


def fit_film_gls(ts_img, X, tcon, mask=None,
                 smooth_struct=None, smooth_fwhm=None):

    from numpy import dot
    from numpy.fft import fft, ifft
    from numpy.linalg import lstsq, pinv

    ts_vol = ts_img.get_data() #.dropna(inplace=True)
    if mask is None:
        mask = ts_vol.var(axis=-1) > 0

    nvox = mask.sum()
    ntp = ts_vol.shape[-1]
    nev = X.shape[1]
    
    try: 
        ncon = len(tcon)
    except: 
        ncon = 1 


    assert X.shape[0] == ntp

    Y = ts_vol[mask].T
    Y = Y - Y.mean(axis=0)


    ####################
    del ts_vol

    ######################

    # Fit initial iteration OLS model in one step
    B_ols, _, _, _ = lstsq(X, Y)
    Yhat_ols = X.dot(B_ols)
    resid_ols = Y - Yhat_ols
    assert resid_ols.shape == (ntp, nvox)

    # Estimate the residual autocorrelation function
    tukey_m = int(np.round(np.sqrt(ntp)))
    acf_pad = ntp * 2 - 1
    resid_fft = fft(resid_ols, n=acf_pad, axis=0)
    acf_fft = resid_fft * resid_fft.conjugate()
    acf = ifft(acf_fft, axis=0).real[:tukey_m]
    
    np.seterr(invalid='ignore')
    acf = np.divide(acf, acf[0])

    #acf /= acf[0]
    #acf[np.isnan(acf) == True] = 0
        
    assert acf.shape == (tukey_m, nvox)

    # Regularize the autocorrelation estimates with a tukey taper
    lag = np.arange(tukey_m)
    window = .5 * (1 + np.cos(np.pi * lag / tukey_m))
    acf_tukey = acf * window[:, np.newaxis]
    assert acf_tukey.shape == (tukey_m, nvox)

    # Smooth the autocorrelation estimates
    # TODO

    # Compute the autocorrelation kernel
    w_pad = ntp + tukey_m
    acf_kernel = np.zeros((w_pad, nvox))
    acf_kernel[:tukey_m] = acf_tukey
    acf_kernel[-tukey_m + 1:] = acf_tukey[:0:-1]
    assert (acf_kernel != 0).sum() == (nvox * (tukey_m * 2 - 1))

    # Compute the prewhitening kernel in the spectral domain
    acf_fft = fft(acf_kernel, axis=0).real
    W_fft = np.zeros((w_pad, nvox))
    W_fft[1:] = 1 / np.sqrt(np.abs(acf_fft[1:]))
    W_fft /= np.sqrt(np.sum(W_fft[1:] ** 2, axis=0, keepdims=True)) / w_pad

    # Prewhiten the data
    Y_fft = fft(Y, axis=0, n=w_pad)
    WY = ifft(W_fft * Y_fft.real
              + W_fft * Y_fft.imag * 1j,
              axis=0).real[:ntp]

    # Prewhiten the design
    X_fft = fft(X, axis=0, n=w_pad)
    X_fft_exp = X_fft[:, :, np.newaxis]
    W_fft_exp = W_fft[:, np.newaxis, :]
    WX = ifft(W_fft_exp * X_fft_exp.real
              + W_fft_exp * X_fft_exp.imag * 1j,
              axis=0).real[:ntp]


    del X_fft, X_fft_exp, Y_fft, W_fft, acf_fft, acf_kernel


    # Fit the GLS model at each voxel
    B = np.empty((nvox, nev))
    G = np.empty((nvox, ncon))
    V = np.empty((nvox, ncon))

    for i in range(nvox):

        Wyi, WXi = WY[..., i], WX[..., i]
        XtXinv = pinv(dot(WXi.T, WXi))
        bi = dot(XtXinv, dot(WXi.T, Wyi))
        Ri = np.eye(ntp) - dot(WXi, dot(XtXinv, WXi.T))
        ri = dot(Ri, Wyi)
        ssi = dot(ri, ri.T) / Ri.trace()

        for j, cj in enumerate(tcon):

            keff = dot(cj, dot(XtXinv, cj))

            gij = dot(cj, bi)
            vij = keff * ssi

            G[i, j] = gij
            V[i, j] = vij

        B[i] = bi

    T = G / np.sqrt(V)

    # Deal with the outputs
    ni, nj, nk = ts_img.shape[:-1]

    beta_vol = np.zeros((ni, nj, nk, nev))
    beta_vol[mask] = B
    beta_img = nib.Nifti1Image(beta_vol, ts_img.affine, ts_img.header)

    cope_vol = np.zeros((ni, nj, nk, ncon))
    cope_vol[mask] = G
    cope_img = nib.Nifti1Image(cope_vol, ts_img.affine, ts_img.header)

    varcope_vol = np.zeros((ni, nj, nk, ncon))
    varcope_vol[mask] = V
    varcope_img = nib.Nifti1Image(varcope_vol, ts_img.affine, ts_img.header)

    t_vol = np.zeros((ni, nj, nk, ncon))
    t_vol[mask] = T
    t_img = nib.Nifti1Image(t_vol, ts_img.affine, ts_img.header)

    return beta_img, cope_img, varcope_img, t_img


if __name__ == "__main__":

    #import sys
    #_, ts_fname, dmat_fname, tcon_fname, thresh = sys.argv

    parser = argparse.ArgumentParser(description='film_gls')

    parser.add_argument('--ts_fname', type=str)
    parser.add_argument('--dmat_fname', type=str)
    parser.add_argument('--tcon_fname', type=str)
    parser.add_argument('--thresh', type=float)
    parser.add_argument('--mask', type=str)

    args = parser.parse_args()


    ts_fname    = args.ts_fname # 
    dmat_fname  = args.dmat_fname #
    tcon_fname  = args.tcon_fname #
    thresh      = args.thresh # 1000
    mask_fname        = args.mask 

    """
    ts_fname    = "/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_Preproc/sub-02_ses-10_task-movie_run-05_VASO.nii"
    dmat_fname  = "/data/NIMH_scratch/kleinrl/analyses/wb3/ALL_pca5_fslmask_across/fsl_feat_1076.L_47l_pca10/gdown_sub-02_VASO_across_days.2D.pca_001/gdown_sub-02_VASO_across_days-gdown_sub-02_VASO_across_days.feat/design.mat"
    tcon_fname  = "/data/NIMH_scratch/kleinrl/analyses/wb3/ALL_pca5_fslmask_across/fsl_feat_1076.L_47l_pca10/gdown_sub-02_VASO_across_days.2D.pca_001/gdown_sub-02_VASO_across_days-gdown_sub-02_VASO_across_days.feat/design.con"
    thresh      = 0
    mask_fname = "/data/NIMH_scratch/kleinrl/gdown/sub-02_layers_bin.nii.gz"
    
    """


    ts_img = nib.load(ts_fname)


    X = np.loadtxt(dmat_fname, comments="/")

    tcon = np.loadtxt(tcon_fname, comments="/")
    tcon = tcon.reshape([1,1])

    #mask = ts_img.get_data().mean(axis=-1) > float(thresh)
    mask_img = nib.load(mask_fname)
    mask_data = mask_img.get_data()
    mask = mask_data == 1 



    X = X.reshape([180,1])

    results = fit_film_gls(ts_img, X, tcon, mask)

    beta_img, cope_img, varcope_img, t_img = results

    beta_img.to_filename("betas.nii.gz")
    cope_img.to_filename("copes.nii.gz")
    varcope_img.to_filename("varcopes.nii.gz")
    t_img.to_filename("tstats.nii.gz")