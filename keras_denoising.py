#srun --mem 40G -p Gpu  --gres gpu:"Tesla V100-PCIE-32GB":1 --pty /bin/bash --login
import tensorflow as tf
from keras.backend.tensorflow_backend import set_session
config = tf.ConfigProto()
config.gpu_options.allow_growth = True  # dynamically grow the memory used on the GPU
config.log_device_placement = True  # to log device placement (on which device the operation ran)
                                    # (nothing gets printed in Jupyter, only if you run it standalone)
sess = tf.Session(config=config)
set_session(sess)  # set this TensorFlow session as the default session for Keras




import keras
from keras.models import Model
from keras.layers import Conv2D, MaxPooling2D, Dense, Input, Reshape, Flatten, Lambda, Conv2DTranspose,Activation 
from keras import backend as K
#import matplotlib.pyplot as plt
import numpy as np
from keras.datasets import mnist

import math
import cv2
import glob
import os 
from sklearn.cluster import KMeans

################################################################
os.chdir("./tif")
labels=os.listdir()
img_num=100 #per class ; train one denoising autoencoder for each class
width=2240
height=2240
channel=1
train_size=.8
train_num=int(math.ceil(img_num*train_size))
test_num=img_num-train_num

################################################


for i,lbl in enumerate(labels):
    print(lbl)
    tiff_list=glob.glob(lbl+"/*.tif")
    X_train=np.zeros(shape=(train_num,width,height,channel),dtype=np.float64)
    X_orig=X_train
    for j in range(train_num):
        this_noise_path=lbl+"/"+lbl+"_"+"noisy"+"_"+str(j)+".tif"
        this_orig_path=lbl+"/"+lbl+"_"+"orig"+"_"+str(j)+".tif"
        X_train[j]=np.reshape(cv2.imread(this_noise_path,cv2.IMREAD_GRAYSCALE)/255,(width,height,channel))
        X_orig[j]=np.reshape(cv2.imread(this_orig_path,cv2.IMREAD_GRAYSCALE)/255,(width,height,channel))
        #X_train[j]=cv2.imread(this_noise_path,-1)/255
        #X_orig[j]=cv2.imread(this_orig_path,-1)/255
        
    # creating denoising autoencoder model
    inputs = Input(shape = (width,height,channel))
    
    conv1 = Conv2D(16, (3,3), activation = 'sigmoid', padding = "SAME")(inputs)
    pool1 = MaxPooling2D(pool_size = (2,2), strides = 2)(conv1)
    conv2 = Conv2D(32, (3,3), activation = 'sigmoid', padding = "SAME")(pool1)
    pool2 = MaxPooling2D(pool_size = (2,2), strides = 2)(conv2)
    upsampling_1 = Conv2DTranspose(32, 3, padding='same', activation='sigmoid', strides=(2, 2))(pool2)
    act3=Activation('sigmoid')(upsampling_1)
    upsampling_2 = Conv2DTranspose(16, 3, padding='same', activation='sigmoid', strides=(2, 2))(act3)
    outputs = Conv2DTranspose(channel, 3, padding='same', activation='sigmoid')(upsampling_2)
    autoencoder = Model(inputs, outputs)
    m = 1
    n_epoch = 1
    autoencoder.compile(optimizer='sgd', loss='binary_crossentropy')
    autoencoder.fit(X_train,X_orig, epochs=n_epoch, batch_size=m, shuffle=True,validation_split=0.2)
    print("predicting")    
    X_test=np.zeros(shape=(test_num,width,height,channel),dtype=np.float64)
    for r in range(test_num):
        num=train_num+r
        path=lbl+"/"+lbl+"_"+"noisy"+"_"+str(num)+".tif"
        this_test_img=np.reshape(cv2.imread(path,cv2.IMREAD_GRAYSCALE),(width,height,channel))
        #this_test_img=cv2.imread(path,-1)
        X_test[r]=this_test_img
    
    decoded_imgs = autoencoder.predict(X_test,batch_size=1)
    diff_imgs=X_test-decoded_imgs

    for r in range(test_num):
        print("writing")
        num=train_num+r
        this_decoded_name=lbl+"/"+lbl+"_"+"dec"+"_"+str(num)+".tif"
        this_diff_name=lbl+"/"+lbl+"_"+"dif"+"_"+str(num)+".tif"
        cv2.imwrite(this_decoded_name,decoded_imgs[r])
        cv2.imwrite(this_diff_name,diff_imgs[r])
