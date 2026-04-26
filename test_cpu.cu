#include "config.h"
#include "shared.h"
#include <cmath>

using namespace std;

void testCPU( 
    float* prev,
    float* curr,
    float* next,
    int steps
) {
    
    for (int step = 0; step < steps; ++step) {
        if (step % 50 == 0) {
            createForce(prev, curr, step);
        }
        wave_step(prev, curr, next);
        prev = curr;
        curr = next;
    } 
}


void wave_step(
    float* prev,
    float* curr,
    float* next)
{
    for (unsigned int i = 1; i < MATRIX_SIZE - 1; ++i) {
        for (unsigned int j = 1; j < MATRIX_SIZE - 1; ++j) {
            unsigned int idx = i * MATRIX_SIZE + j;
            float orthoSum = curr[idx - MATRIX_SIZE] + curr[idx + MATRIX_SIZE]
                           + curr[idx - 1]  + curr[idx + 1];
            float diagSum  = curr[idx - MATRIX_SIZE - 1] + curr[idx - MATRIX_SIZE + 1]
                           + curr[idx + MATRIX_SIZE - 1] + curr[idx + MATRIX_SIZE + 1];
            next[idx] = 2.0f * curr[idx] - prev[idx]
                      + SPEED_K * (orthoSum + 0.5f * diagSum - 6.0f * curr[idx]);
            next[idx] *= DAMPING;
        }
    }
}