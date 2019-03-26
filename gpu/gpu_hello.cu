#include <cuda.h>
#include <iostream>
#include <vector>
#include <numeric>
#include <algorithm>

__global__ void pooling(int *pixels, int *convolution, int width, int height, int use_max) {
    int i = threadIdx.x;

    if ((i != 0) && ((i + 1) % width == 0)) {
        return; // too far to right
    }

    // grab 2x2 window, calculate max or mean and add to convolution
    int *window = new int[4]{pixels[i], pixels[(i + 1)], pixels[(i + width)], pixels[(i + 1 + width)]};
    if (use_max == 0) { // use mean

        convolution[i] = (pixels[i] + pixels[(i + 1)] + pixels[(i + width)] + pixels[(i + 1 + width)]) / 4;

    } else {

        int max = -9999;

        for (int idx = 0; idx < 4; idx++) {
            if (window[idx] > max) {
                max = window[idx];
            }
        }

        convolution[i] = max;
    }
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
    pooling << < 1, (SIZE - height - 1) >> > (d_pixels, d_convolution, width, height, use_max);

    cudaDeviceSynchronize();

    cudaMemcpy(convolution, d_convolution, CONVO_SIZE * sizeof(int), cudaMemcpyDeviceToHost);

    cudaFree(d_pixels);
    cudaFree(d_convolution);

    return convolution;
}

int main() {
    const int width = 4;
    const int height = 4;
    const int use_max = 0;

    int *pixels = new int[16]{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15};

    int *convolution = pooling(pixels, width, height, use_max);

    for (int i = 0 ; i < 9 ; i++){
        std::cout << i << " : " << pixels[i] << "," << pixels[(i + 1)] << "," <<  pixels[(i + width)] << "," <<  pixels[(i + 1 + width)] << " --> " << convolution[i] << " \n";
    }
    return 0;
}

