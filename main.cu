#include "config.h"
#include "utils.h"
#include "test_gpu.h"
#include "test_cpu.h"
#include <iostream>

#include <cuda_runtime.h>

int main() {
    std::cout << "START" << std::endl;
    size_t bytes = MATRIX_SIZE * MATRIX_SIZE * sizeof(float);
    std::cout << "bytes: " << bytes << std::endl;

    float* prev;
    float* curr;
    float* next;

   std::cout << "Alokacja pamieci..." << std::endl;
cudaError_t err1 = cudaMallocHost(&prev, bytes);
cudaError_t err2 = cudaMallocHost(&curr, bytes);
cudaError_t err3 = cudaMallocHost(&next, bytes);
std::cout << "prev: " << cudaGetErrorString(err1) << std::endl;
std::cout << "curr: " << cudaGetErrorString(err2) << std::endl;
std::cout << "next: " << cudaGetErrorString(err3) << std::endl;

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