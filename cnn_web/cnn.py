from PIL import Image
import numpy as np


def display_channel(pixels, width):
    height = (int)(len(pixels) / width)
    img = Image.new('L', (width, height))
    img.putdata(pixels)
    img.show()


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

# credit https://stackoverflow.com/users/2005415/jason
# https://stackoverflow.com/questions/42463172
def pooling(mat,ksize,method='max'):
    '''Non-overlapping pooling on 2D or 3D data.
    <mat>: ndarray, input array to pool.
    <ksize>: tuple of 2, kernel size in (ky, kx).
    <method>: str, 'max for max-pooling,
                   'mean' for mean-pooling.
    Return <result>: pooled matrix.
    '''
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

w = 9
h = 5
sample = list(range(w*h))
sample_matrix = np.asarray(sample).reshape(h,w)
print(sample_matrix)

print()
pooled = pooling(sample_matrix, (4,2), 'max')
print(pooled)
# image_file = '/home/will/git/AI_Decomposed/imgs/cpp_small.png'
image_file = '/home/will/git/AI_Decomposed/imgs/green_golf.jpg'
[height, width, red, green, blue] = image_meta(image_file)
display_channel(green, width)

green_array = np.asarray(green).reshape(height, width)
green_padded = np.pad(green_array, 1, 'constant')
kernel = np.array([[-1, -1, -1], [-1, 8, -1], [-1, -1, -1]])
g = convolve(green_padded, kernel)

g_list = list(np.array(g).flat)  # 48672
display_channel(g_list, width)

print()

pooled = pooling(np.array(g), (2,2), 'max')
pooled_width = pooled.shape[1]
g_list = list(np.array(pooled).flat)  # 48672
display_channel(g_list, pooled_width)

print()