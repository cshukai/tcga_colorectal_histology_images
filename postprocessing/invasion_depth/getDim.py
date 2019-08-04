import gc
import glob
import scipy.ndimage
from skimage.util import view_as_windows
import openslide
from PIL import Image
from openslide.lowlevel import *
import numpy as np
import cv2
import skimage.io
import os
import pandas as pd

def _load_image(buf, size):
    # Load entire buffer at once if possible
    MAX_PIXELS_PER_LOAD = (1 << 29) - 1
    # Otherwise, use chunks smaller than the maximum to reduce memory
    # requirements
    PIXELS_PER_LOAD = 1 << 26
    def do_load(buf, size):

        # First reorder the bytes in a pixel from native-endian aRGB to
        # big-endian RGBa to work around limitations in RGBa loader
        rawmode = (sys.byteorder == 'little') and 'BGRA' or 'ARGB'
        buf = PIL.Image.frombuffer('RGBA', size, buf, 'raw', rawmode, 0, 1)
        # Image.tobytes() is named tostring() in Pillow 1.x and PIL
        buf = (getattr(buf, 'tobytes', None) or buf.tostring)()
        # Now load the image as RGBA, undoing premultiplication
        return PIL.Image.frombuffer('RGBA', size, buf, 'raw', 'RGBa', 0, 1)

    # Fast path for small buffers
    w, h = size
    if w * h <= MAX_PIXELS_PER_LOAD:
        return do_load(buf, size)

    # Load in chunks to avoid OverflowError in PIL.Image.frombuffer()
    # https://github.com/python-pillow/Pillow/issues/1475
    if w > PIXELS_PER_LOAD:
        # We could support this, but it seems like overkill
        raise ValueError('Width %d is too large (maximum %d)' %
                (w, PIXELS_PER_LOAD))
    rows_per_load = PIXELS_PER_LOAD // w
    img = PIL.Image.new('RGBA', (w, h))
    for y in range(0, h, rows_per_load):
        rows = min(h - y, rows_per_load)
        if sys.version[0] == '2':
            chunk = buffer(buf, 4 * y * w, 4 * rows * w)
        else:
            # PIL.Image.frombuffer() won't take a memoryview or
            # bytearray, so we can't avoid copying
            chunk = memoryview(buf)[y * w:(y + rows) * w].tobytes()
        img.paste(do_load(chunk, (w, rows)), (0, y))
    return img

openslide.lowlevel._load_image = _load_image

def getBarcodeFmPath(fullpath):
    a=fullpath.split("/")
    b=a[len(a)-1]
    c=b.split('.')
    d=c[0]
    return(d)

all_wsi_path=glob.glob('/storage/htc/nih-tcga/sc724/tcga_current/coad/exp/slide/*.svs')
outdir='/storage/htc/nih-tcga/sc724/tcga_current/whole_slide_patches/deep-stroma-histology/invasion/dim.txt'


for idx,wsi_path in enumerate(all_wsi_path):
    d=openslide.OpenSlide(wsi_path)
    im=d.read_region((0,0),d.level_count-1,d.level_dimensions[0])
    im=np.array(im)
    width=im.shape[0]
    height=im.shape[1]
    barcode=getBarcodeFmPath(wsi_path)
    with open(outdir, 'a') as the_file: 
        the_file.write(barcode+','+width+','+height+','+'\n')
