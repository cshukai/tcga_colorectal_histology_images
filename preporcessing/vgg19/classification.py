import scipy.io
from keras.applications.vgg19 import VGG19

x=x=scipy.io.loadmat("/storage/htc/nih-tcga/sc724/tcga_current/whole_slide_patches/deep-stroma-histology/lastNet_TEXTURE_VGG.mat")
#weights are here x['None'][0][3]
model= VGG19(weights=weights)
