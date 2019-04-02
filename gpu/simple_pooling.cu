#include <iostream>
#include <numeric>
#include <stdlib.h>
#include <stdio.h>
using namespace std;

__global__ void pooling(int *pixels, int *convolution, int width, int height, int use_max) {
	int convolution_idx = blockIdx.x * blockDim.x + threadIdx.x;
	// int top_left = (blockIdx.x * width) + (threadIdx.x);
	// int top_right = top_left + 1;
	// int bot_left = top_left + width;
	// int bot_right = bot_left + 1;

	if (use_max == 0) { // use mean
		convolution[convolution_idx] =
				__double2int_rn(
						(pixels[((blockIdx.x * width) + (threadIdx.x))]
								+ pixels[((blockIdx.x * width) + (threadIdx.x))
										+ 1]
								+ pixels[(((blockIdx.x * width) + (threadIdx.x))
										+ width)]
								+ pixels[(((blockIdx.x * width) + (threadIdx.x))
										+ width) + 1]

						) / 4.0);
	} else {
		int max = -9999;
		int *window = new int[4] { pixels[((blockIdx.x * width) + (threadIdx.x))],
					pixels[((blockIdx.x * width) + (threadIdx.x)) + 1],
					pixels[(((blockIdx.x * width) + (threadIdx.x)) + width)],
					pixels[(((blockIdx.x * width) + (threadIdx.x)) + width) + 1] };

		for (int idx = 0; idx < 4; idx++) {
			if (window[idx] > max) {
				max = window[idx];
			}
		}
		convolution[convolution_idx] = max;
	}
}

extern "C" int *pooling(int *pixels, const int width, const int height, const int recurse_cnt, const int use_max) {
	int w = width;
	int h = height;
	int size = w * h;
	int convo_size = (w - 1) * (h - 1);
	int *d_pixels;
	int *d_convolution;

	cudaMalloc(&d_pixels, size * sizeof(int));
	cudaMalloc(&d_convolution, convo_size * sizeof(int));

	cudaMemcpy(d_pixels, pixels, size * sizeof(int), cudaMemcpyHostToDevice);

	for (int recurse_idx = 0; recurse_idx < recurse_cnt; recurse_idx++) {
		size = w * h;
		convo_size = (w - 1) * (h - 1);

		if (recurse_idx % 2 == 0) {
			pooling<<< (h - 1), (w - 1) >>>(d_pixels, d_convolution, w, h, use_max);
		} else {
			pooling<<< (h - 1), (w - 1) >>>(d_convolution, d_pixels, w, h, use_max);
		}
		w--;
		h--;
	}

	int *convolution = new int[convo_size];
	if (recurse_cnt % 2 == 0) {
		cudaMemcpy(convolution, d_pixels, convo_size * sizeof(int),
				cudaMemcpyDeviceToHost);
	} else {
		cudaMemcpy(convolution, d_convolution, convo_size * sizeof(int),
				cudaMemcpyDeviceToHost);
	}

	cudaFree(d_pixels);
	cudaFree(d_convolution);
	return convolution;
}

int *init_array(const int size) {
	int * array = new int[size];
	for (int i = 0; i < size; i++) {
		array[i] = rand() % 100;
	}
	return array;
}

//  nvcc --ptxas-options=-v --compiler-options '-fPIC' -o gpu.so --shared  simple_poolings.cu
int main(void) {
	const int width = 4;
	const int height = 4;
	const int recurse_cnt = 3;
	const int use_max = 0;
	//int *pixels = new int[16] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,14, 15 };
	int * pixels = init_array(1000000);
	int *convolution = pooling(pixels, width, height, recurse_cnt, use_max);
	cout << "\n\nend\n";
	for (int i = 0; i < ((width - recurse_cnt) * (height - recurse_cnt)); i++) {
		std::cout << i << " : " << convolution[i] << " \n";
	}
	return 0;
}
