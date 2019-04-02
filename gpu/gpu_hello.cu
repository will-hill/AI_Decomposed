#include <cuda.h>
#include <iostream>
#include <vector>
#include <numeric>
#include <algorithm>

__global__ void pooling ( int *pixels, int *convolution, int width, int height, int use_max ) {

    int convolution_idx = blockIdx.x * blockDim.x + threadIdx.x;
    int top_left = (blockIdx.x * width) + (threadIdx.x);
    int top_right = top_left + 1;
    int bot_left = top_left + width;
    int bot_right = bot_left + 1;

    // grab 2x2 window, calculate max or mean and add to convolution
    int *window = new int[4]{
            pixels[top_left], pixels[top_right],
            pixels[bot_left], pixels[bot_right]
    };

    if (use_max == 0) { // use mean
        double mean = (pixels[top_left] + pixels[top_right] + pixels[bot_left] + pixels[bot_right]) / 4.0;
        int mean_int = __double2int_rn(mean);

        /*printf("%d: window: %d  %d  %d  %d        %d %d %d %d : %f : %d \n",
               convolution_idx, top_left, top_right, bot_left, bot_right,

               pixels[top_left], pixels[top_right],
               pixels[bot_left], pixels[bot_right],

               mean,
               mean_int);*/


        convolution[convolution_idx] = mean_int;
    } else {

        int max = -9999;
        for (int idx = 0; idx < 4; idx++) {
            if (window[idx] > max) {
                max = window[idx];
            }
        }
        convolution[convolution_idx] = max;
    }
}

extern "C" int test(int *pixels) {
    return -999;
}

extern "C" int *pooling(int *pixels, const int width, const int height, const int use_max) {


    const int SIZE = width * height;
    const int CONVO_SIZE = (width - 1) * (height - 1);

    int *d_pixels;
    int *d_convolution;
    int *convolution = new int[CONVO_SIZE];

    cudaMallocManaged(&d_pixels, SIZE * sizeof(int));
    cudaMallocManaged(&d_convolution, CONVO_SIZE * sizeof(int));

    cudaMemcpy(d_pixels, pixels, SIZE * sizeof(int), cudaMemcpyHostToDevice);

    // no need to calculate last row
    pooling <<< (height - 1), (width - 1) >>> (d_pixels, d_convolution, width, height, use_max);

    cudaDeviceSynchronize();

    cudaMemcpy(convolution, d_convolution, CONVO_SIZE * sizeof(int), cudaMemcpyDeviceToHost);

    cudaFree(d_pixels);
    cudaFree(d_convolution);

    return convolution;
}

//  nvcc --ptxas-options=-v --compiler-options '-fPIC' -o gpu.so --shared  gpu_hello.cu
int main() {
    const int width = 4;
    const int height = 4;
    const int use_max = 0;

    int *pixels = new int[16]{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};

    int *convolution = pooling(pixels, width, height, use_max);

    for (int i = 0; i < 9; i++) {
        std::cout << i << " : " << convolution[i] << " \n";
    }
    return 0;
}

