#include "config.h"
#include "shared.h"
#include <cmath>
#include <cuda_runtime.h>

__global__ void wave_step_kernel(
    float*  prev,
    float*  curr,
    float*  next)
{
    int j = blockIdx.x * blockDim.x + threadIdx.x;
    int i = blockIdx.y * blockDim.y + threadIdx.y;

    int idx = i * MATRIX_SIZE + j;

    float orthoSum = curr[idx - MATRIX_SIZE] + curr[idx + MATRIX_SIZE]
                   + curr[idx - 1] + curr[idx + 1];

    float diagSum  = curr[idx - MATRIX_SIZE - 1] + curr[idx - MATRIX_SIZE + 1]
                   + curr[idx + MATRIX_SIZE - 1] + curr[idx + MATRIX_SIZE + 1];

    next[idx] = (2.0f * curr[idx] - prev[idx]
              + SPEED_K * (orthoSum + 0.5f * diagSum - 6.0f * curr[idx]))
              * DAMPING;
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
            createForce(prev, curr, step);
        }

        wave_step_kernel<<<grid, block>>>(prev, curr, next);

        float* tmp = prev;
        prev = curr;
        curr = next;
        next = tmp;
    }

    cudaDeviceSynchronize();
}