#include "config.h"

#include <iostream>
#include <string>
#include <fstream>
#include <chrono>
#include <cstring>

using namespace std;
using namespace chrono;


time_point<high_resolution_clock> startTest() {
    return high_resolution_clock::now();
}

void endTest(time_point<high_resolution_clock> startTime, int steps, int testIndex, string type) {
    ofstream csv("results.csv", ios::app);
    auto endTime = high_resolution_clock::now();
    double ms = duration<double, milli>(endTime - startTime).count();
    csv << type << "," << steps << "," << testIndex + 1 << "," << ms << "\n";;
}

void resetMatrixes(float* prev, float* curr, float* next) {
    size_t n = MATRIX_SIZE * MATRIX_SIZE;
    memset(prev, 0, n * sizeof(float));
    memset(curr, 0, n * sizeof(float));
    memset(next, 0, n * sizeof(float));
}