#include <string>
#include <fstream>
#include <chrono>

using namespace std;
using namespace chrono;

time_point<high_resolution_clock> startTest();
void endTest(time_point<high_resolution_clock> startTime, int steps, int testIndex, string type);
void resetMatrixes(float* prev, float* curr, float* next);