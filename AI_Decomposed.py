from PIL import Image
import ctypes
from ctypes import *
import numpy as np
import time

###############################################################################################################################
# http://localhost:8888/notebooks/1_Image_Metadata.ipynb      
def image_meta(image_file):
    img = Image.open(image_file)
    width, height = img.size    
    channel_cnt = 3
    channel_size = width * height    
    pixels = list(img.getdata())
    red = list()
    green = list()
    blue = list()
    # will discard alpha channel
    for quadruple in pixels:
        red.append(quadruple[0])
        green.append(quadruple[1])
        blue.append(quadruple[2])
    
    return [height, width, red, green, blue]   

def save_image(pixels,width,name):
    height = (int) (len(pixels)/width)
    img = Image.new('L', (width, height))
    img.putdata(pixels)
    img.save("./imgs/" + name, "png")
###############################################################################################################################
# http://localhost:8888/notebooks/1_Image_Metadata.ipynb
def display_channel(pixels, width):
    height = (int) (len(pixels)/width)
    img = Image.new('L', (width, height))
    img.putdata(pixels)
    display(img)

   ###############################################################################################################################
# http://localhost:8888/notebooks/2_Py_Convolution.ipynb
def apply_kernel(window, filter, i, j):
    sum = 0
    for m in range(len(filter)):
        for n in range(len(filter[m])):
            sum = sum + ((window[i + m][j + n]) * (filter[m][n]))
    return sum
def convolve(matrix, kernel):
    convOut = []
    for i in range(len(matrix) - ((len(kernel)) - 1)):
        r = list()
        for j in range(len(matrix[i]) - ((len(kernel)) - 1)):
            r.append(apply_kernel(matrix, kernel, i, j))
        convOut.append(r)
    return convOut

def PY_apply_simple_kernel_func(mat, w, kernel_funct):
    
    # determine height
    h=(int)(len(mat)/w)
    
    # list for convolution
    new_image = list()
    
    # slide window over matrix
    for i,g in enumerate(mat):
    
        # out of bounds?
        if i >= (w*(h-1)): 
            break
        if i!= 0 and (i+1) % w == 0:
            continue
        
        # grab window of pixels
        window = [mat[i], mat[(i+1)], mat[(i+w)], mat[(i+1+w)]]
        
        # apply function
        output = kernel_funct(window)
        
        # round half to even
        output = int(round(output))
        
        # add pixel to convolution
        new_image.append(output)
    return new_image

###############################################################################################################################
# http://localhost:8888/notebooks/2_Py_Convolution.ipynb        
# recursify the function
def PY_recurse_pooling(mat, width, kernel_funct, recurse_cnt):
    m = mat
    w = width
    for i in range(recurse_cnt):    
        m = PY_apply_simple_kernel_func(m, w, kernel_funct)
        w = w - 1
    return m        


# credit https://stackoverflow.com/users/2005415/jason https://stackoverflow.com/questions/42463172
def pooling(mat,ksize,method='max'):
    '''Non-overlapping pooling on 2D or 3D data. <mat>: ndarray, input array to pool.
    <ksize>: tuple of 2, kernel size in (ky, kx). <method>: str, 'max for max-pooling, 'mean' for mean-pooling.
    Return <result>: pooled matrix.'''
    m, n = mat.shape[:2]
    ky,kx=ksize
    _ceil=lambda x,y: int(np.ceil(x/float(y)))
    ny=m//ky
    nx=n//kx
    mat_pad=mat[:ny*ky, :nx*kx, ...]
    new_shape=(ny,ky,nx,kx)+mat.shape[2:]
    if method=='max':
        result=np.nanmax(mat_pad.reshape(new_shape),axis=(1,3))
    else:
        result=np.nanmean(mat_pad.reshape(new_shape),axis=(1,3))
    return result

###############################################################################################################################
# http://localhost:8888/notebooks/3_CPP_Convolution.ipynb
def native_recurse_pooling(mat, width, recurse_cnt, use_max, function_ptr):    
    height = (int)(len(mat) / width)
    # create pointer array
    ptr_param = pointer((ctypes.c_int * len(mat))(*mat))

    # calculate array size after function call
    returned_height = height - recurse_cnt
    returned_width  = width - recurse_cnt
    returned_convolution_array_size = returned_height * returned_width
    # define return type of integer pointer array
    function_ptr.restype = ctypes.POINTER(ctypes.c_int * (returned_convolution_array_size))
    # conver boolean to int
    f=0
    if use_max:
       f=1 
    # actuall call to C++ code
    ptr_array_convolution = function_ptr(ptr_param, width, height, recurse_cnt, f)
    # convert int pointer array to Python list
    ret_convo = np.ctypeslib.as_array( ptr_array_convolution.contents ,shape=(1,)).astype(int).tolist()
    # return Python list of convolution pixels
    return ret_convo

###############################################################################################################################
# http://localhost:8888/notebooks/4_Compare_Performance_Python_VS_C%2B%2B.ipynb#Visualize-Performance
def calc_ttl_pixels(width, height, recursions):    
    w = width
    h = height
    total_pixels = 0
    for i in range(1,(recursions+1),1):    
        total_pixels = total_pixels + (w*h)
        w = w - 1
        h = h - 1
    return total_pixels
