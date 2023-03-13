
from sklearn.preprocessing import MinMaxScaler
from sklearn.decomposition import PCA
import argparse
import numpy as np 


def get_pcas(data):
 

    scaler = MinMaxScaler()

    data_rescaled = scaler.fit_transform(data)

    pca = PCA(n_components = 0.99)
    pca.fit(data_rescaled)
    reduced = pca.transform(data_rescaled)
    
    return reduced 





3dcalc -a $layers -b $parc_hcp -expr 'step(a)*b' -prefix  


filename = args.file
filename_base = filename.split('/')[-1] #.rstrip('.dump')

data = np.loadtxt(filename) 
data_t = data.T

reduced = get_pcas(data_t)

for col in range(reduced.shape[1]): 
    np.savetxt(
        "{}.pca_{:03d}.1D".format(filename_base,col),
        reduced[:,col])


