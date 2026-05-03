#include "config.h"
#include <cmath>
#include <cuda_runtime.h>

__global__ void wave_step_kernel(
    float*  prev,
    float*  curr,
    float*  next)
{
    int j = blockIdx.x * blockDim.x + threadIdx.x;
    int i = blockIdx.y * blockDim.y + threadIdx.y;

    if (i == 0 || i >= MATRIX_SIZE - 1 || j == 0 || j >= MATRIX_SIZE - 1)
        return;

    int idx = i * MATRIX_SIZE + j;

    float orthoSum = curr[idx - MATRIX_SIZE] + curr[idx + MATRIX_SIZE]
                   + curr[idx - 1] + curr[idx + 1];

    float diagSum  = curr[idx - MATRIX_SIZE - 1] + curr[idx - MATRIX_SIZE + 1]
                   + curr[idx + MATRIX_SIZE - 1] + curr[idx + MATRIX_SIZE + 1];

    next[idx] = (2.0f * curr[idx] - prev[idx]
              + SPEED_K * (orthoSum + 0.5f * diagSum - 6.0f * curr[idx]))
              * DAMPING;
}

__global__ void createForceKernel(float* prev, float* curr, int step) {
    int r = MATRIX_SIZE / 4;
    int O = MATRIX_SIZE / 2;
    int x = O + (r * sinf(step));
    int y = O + (r * cosf(step));
    
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        prev[y * MATRIX_SIZE + x] = ENERGY;
        curr[y * MATRIX_SIZE + x] = ENERGY;
    }
}

void testGPU(
    float* prev,
    float* curr,
    float* next,
    int steps
) {
    dim3 block(BLOCK_SIZE, BLOCK_SIZE);
    dim3 grid(MATRIX_SIZE / BLOCK_SIZE, MATRIX_SIZE / BLOCK_SIZE);

    for (int step = 0; step < steps; ++step) {
        if (step % 50 == 0) {
            createForceKernel<<<1, 1>>>(prev, curr, step);
        }

        wave_step_kernel<<<grid, block>>>(prev, curr, next);

        float* tmp = prev;
        prev = curr;
        curr = next;
        next = tmp;
    }

    cudaDeviceSynchronize();
}

