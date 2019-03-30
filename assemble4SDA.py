import tifffile as tiff
import os
from glob import glob
import numpy as np
import random
import cv2
import math
from functools import reduce
import json
import pandas as pd 


tissuelist=glob("NCT-CRC-HE-100K/*")
total_num=100 # per class
edge_noise_ratio=0.3
inner_noise_ration=0.1
totalsize=100 # number of final patches of one image for learning

edge_noise_patch_num=int(math.ceil(int(math.sqrt(totalsize))*edge_noise_ratio))
inner_noise_patch_num=int(math.ceil(totalsize*inner_noise_ration))


def rowWiseImgCombine(rowArr,tiffs):
    pathArr=map(lambda idx: tiffs[idx],rowArr)
    imgArr=map(lambda path: cv2.imread(path,-1),pathArr)
    result=reduce(lambda im1,im2:np.vstack((im1,im2)),imgArr)
    return(result)
        
def getRowWiseLabels(rowArr,tiffs):
    pathArr=map(lambda idx: tiffs[idx],rowArr)
    labelArr=map(lambda tiff_path:tiff_path.split("/")[1],pathArr )
    return(labelArr)



def index2Pixels(i,label_row_col_indices,unitPixel):
    result={}
    for idx in range(len(label_row_col_indices)):
        tiss=label_row_col_indices[idx][0]
        positions=label_row_col_indices[idx][1:]
        for idx2 in range(len(positions)):
            x=positions[idx2][0]
            ys=positions[idx2][1]
            x_pixels_start=x*unitPixel
            x_pixels_end=x*unitPixel+unitPixel-1
            x_pixels=range(x_pixels_start,x_pixels_end+1)
            all_points_x=[]
            all_points_y=[]
            for idx3 in range(len(ys)):
                y_pixel_start=ys[idx3]*unitPixel
                y_pixel_end=ys[idx3]*unitPixel+unitPixel-1
                y_pixels=range(y_pixel_start,y_pixel_end+1)
                all_points_x=all_points_x+x_pixels
                all_points_y=all_points_y+y_pixels 
            result[i]={'filename':str(i)+'tif','name':tiss,'regions':{'all_points_x':all_points_x,'all_points_y':all_points_y} }
    return(result)        
    
def getIndexForLabel(label,labelArr):
    result=[label]
    for rowidx in range(len(labelArr)):
        colidx=[k for k,x in enumerate(labelArr[rowidx]) if x==label]
        if len(colidx)>0:
            result.append([rowidx,colidx])
    return(result)
    
def getAnoDictionary(i,labelArrs,unitPixel):
    flattened_list = [y for x in labelArrs for y in x]
    flattened_list = list(set(flattened_list))
    label_row_col_indices=map(lambda label:getIndexForLabel(label,labelArrs),flattened_list)
    ann=index2Pixels(i,label_row_col_indices,unitPixel)
    return(ann)

for j,path in enumerate(tissuelist):
    finalAnn={}  
    homo_tiflist=glob(path+"/*.tif")
    
    this_tissue=path.split("/")[1]
    this_data_source=path.split("/")[0]
    noisy_tiflist=glob(this_data_source+"/"+"[!"+this_tissue+"]*"+'/*.tif')

    for i in range(total_num):
        noisyTiffs=random.sample(noisy_tiflist,edge_noise_patch_num+inner_noise_patch_num)
        homoTiffs=random.sample(homo_tiflist,totalsize-(edge_noise_patch_num+inner_noise_patch_num))
        totalTiffs=noisyTiffs+homoTiffs
        unit=int(math.sqrt(totalsize))
        
        idices=np.reshape(range(totalsize),(unit,unit))
        labelArrs=map(lambda row:getRowWiseLabels(row,totalTiffs),idices)
        rowResults=map(lambda row: rowWiseImgCombine(row,totalTiffs),idices)
        finalImg=reduce(lambda rowImg1,rowImg2:np.hstack((rowImg1,rowImg2)),rowResults)
        unitPixel=finalImg.shape[0]/unit
        ann=getAnoDictionary(i,labelArrs,unitPixel)
        finalAnn.update(ann)
        tiff.imsave(this_tissue+"_"+str(i)+'.tif',finalImg)

    with open('annotation.json', 'w') as outfile:
        json.dump(finalAnn, outfile)
