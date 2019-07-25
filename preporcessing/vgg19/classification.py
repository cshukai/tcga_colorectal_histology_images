import os
from keras.applications.vgg19 import VGG19
from keras.preprocessing import image
from keras.applications.vgg19 import preprocess_input
from keras.models import Model
from keras.preprocessing.image import ImageDataGenerator, array_to_img, img_to_array, load_img
import numpy as np
# config
batch_size = 16

# input
train_datagen = ImageDataGenerator(rescale=1./255,shear_range=0.2,zoom_range=0.2,horizontal_flip=True)

train_generator = train_datagen.flow_from_directory('/storage/htc/nih-tcga/sc724/tcga_current/whole_slide_patches/images/wholeslide/colorectal/NCT-CRC-HE-100K', 
        target_size=(224, 224),  # all images will be resized to 150x150
        batch_size=batch_size)   # categorical for 1 hot encoding is default

test_datagen = ImageDataGenerator(rescale=1./255)
test_generator = test_datagen.flow_from_directory('/storage/htc/nih-tcga/sc724/tcga_current/whole_slide_patches/images/wholeslide/colorectal/CRC-VAL-HE-7K', 
        target_size=(224, 224),  # all images will be resized to 150x150
        batch_size=batch_size) 

# training
batch_size = 16
model= VGG19(weights='imagenet')
