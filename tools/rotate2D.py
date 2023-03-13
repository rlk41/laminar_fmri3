


def rotate_2D(d, num=10, prefix=None):

    #d = np.loadtxt(path_1D)

    dimx = d.shape[1]
    dimy = d.shape[0]
    
    
    timecourses = []

    for i in range(num): 
        
        o = np.zeros(shape=d.shape)

        for ii in range(dimy): 

            r = randint(0, dimx)
            o[ii,:] = np.concatenate((d[ii,r:], d[ii,:r]), axis=0)
            

        o_ave = np.mean(o, axis=0)

        filename="{}-rotate2D-{}.1D".format(prefix.rstrip('.1D'), str(r).zfill(4))
        
        timecourses.append(filename)
        
        np.savetxt(filename, o_ave, fmt='%.6f')

        print(filename, o.shape ) 

    
    return timecourses