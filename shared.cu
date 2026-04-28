#include "config.h"

void createForce(
    float* prev,
    float* curr,
    int step
)
{
    int r = MATRIX_SIZE / 4;
    int O = MATRIX_SIZE / 2;
    int x = O + (r * sin(step));
    int y = O + (r * cos(step));
    prev[y * MATRIX_SIZE + x] = ENERGY;
    curr[y * MATRIX_SIZE + x] = ENERGY;
}