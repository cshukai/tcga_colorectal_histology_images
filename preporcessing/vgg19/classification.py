import scipy.io
from keras.applications.vgg19 import VGG19

x=x=scipy.io.loadmat("/home/shchang/scratch/whole_slide_patches/deep-stroma-histology/lastNet_TEXTURE_VGG.mat")
weights=x['None'][0][3]
model= VGG19(weights=weights)
