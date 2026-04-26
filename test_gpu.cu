#include "config.h"
#include "test_gpu.h"
#include "shared.h"
#include <cmath>
#include <cuda_runtime.h>

__global__ void wave_step_kernel(
    const float* __restrict__ prev,
    const float* __restrict__ curr,
          float* __restrict__ next)
{
    int j = blockIdx.x * blockDim.x + threadIdx.x;
    int i = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < 1 || i >= MATRIX_SIZE-1 || j < 1 || j >= MATRIX_SIZE-1) return;

    int idx = i * MATRIX_SIZE + j;

    float orthoSum = curr[idx - MATRIX_SIZE] + curr[idx + MATRIX_SIZE]
                   + curr[idx - 1] + curr[idx + 1];
    float diagSum  = curr[idx - MATRIX_SIZE - 1] + curr[idx - MATRIX_SIZE + 1]
                   + curr[idx + MATRIX_SIZE - 1] + curr[idx + MATRIX_SIZE + 1];

    next[idx] = (2.0f * curr[idx] - prev[idx]
              + SPEED_K * (orthoSum + 0.5f * diagSum - 6.0f * curr[idx]))
              * DAMPING;
}

__global__ void boundary_kernel(float* next)
{
    int k = blockIdx.x * blockDim.x + threadIdx.x;
    if (k >= 1 && k < MATRIX_SIZE-1) {
        next[k * MATRIX_SIZE + 0]              = next[k * MATRIX_SIZE + 1];
        next[k * MATRIX_SIZE + MATRIX_SIZE - 1] = next[k * MATRIX_SIZE + MATRIX_SIZE - 2];
        next[0 * MATRIX_SIZE + k]              = next[1 * MATRIX_SIZE + k];
        next[(MATRIX_SIZE-1)*MATRIX_SIZE + k]  = next[(MATRIX_SIZE-2)*MATRIX_SIZE + k];
    }
}


void testGPU(float* prev, float* curr, float* next, int steps)
{
    dim3 block(16, 16);
    dim3 grid((MATRIX_SIZE + 15) / 16, (MATRIX_SIZE + 15) / 16);

    for (int step = 0; step < steps; ++step) {
        if (step % 50 == 0)
            force_kernel(prev, curr, step);

        wave_step_kernel<<<grid, block>>>(prev, curr, next);
        boundary_kernel<<<(MATRIX_SIZE + 255) / 256, 256>>>(next);

        float* tmp = prev;
        prev = curr;
        curr = next;
        next = tmp;
    }

    cudaDeviceSynchronize();
}