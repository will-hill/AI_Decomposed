#include <cuda.h>

__global__ void kernel(int *data) {
    int idx = threadIdx.x + blockDim.x * blockIdx.x;
    doSomeStuff(idx, data, ...);
}


int main(){
    int *data;
    data = 17;
    cudaMallocManaged(&data, N * sizeof(int));
    // initialize data on the CPU
    kernel<<<grid, block>>>(data);
}
