import scipy.io

x=x=scipy.io.loadmat("/home/shchang/scratch/whole_slide_patches/deep-stroma-histology/lastNet_TEXTURE_VGG.mat")
weight=x['None'][0][3]
