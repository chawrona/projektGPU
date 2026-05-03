#include "config.h"
#include "utils.h"
#include "test_gpu.h"
#include "test_cpu.h"
#include <iostream>

#include <cuda_runtime.h>

int main() {
    size_t bytes = MATRIX_SIZE * MATRIX_SIZE * sizeof(float);

    float* prev;
    float* curr;
    float* next;

    cudaMallocHost(&prev, bytes);
    cudaMallocHost(&curr, bytes);
    cudaMallocHost(&next, bytes);

    testGPU(prev, curr, next, 1);
    cudaDeviceSynchronize();

    for (int testIndex = 0; testIndex < TEST_COUNT; testIndex++) {
        for (int stepsIndex = 0; stepsIndex < STEPS_LENGTH; stepsIndex++) {
            // CPU TEST
            resetMatrixes(prev, curr, next);
            auto startTime = startTest();
            testCPU(prev, curr, next, STEPS[stepsIndex]);
            endTest(startTime, STEPS[stepsIndex], testIndex, "CPU");

            // GPU TEST
            resetMatrixes(prev, curr, next);
            startTime = startTest();
            testGPU(prev, curr, next, STEPS[stepsIndex]);
            endTest(startTime, STEPS[stepsIndex], testIndex, "GPU");
        }
    }

    cudaFreeHost(prev);
    cudaFreeHost(curr);
    cudaFreeHost(next);
}