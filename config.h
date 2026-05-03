#pragma once

constexpr float        DAMPING      = 0.996f;
constexpr float        SPEED_K      = 0.2f;
constexpr float        ENERGY = 1200.0f;

constexpr int          BLOCK_SIZE = 16;
constexpr int          MATRIX_SIZE = BLOCK_SIZE * 6 * 10;

constexpr int          STEPS_LENGTH = 7;
constexpr int          STEPS[] = {100, 500, 1000, 2500, 5000, 7500, 10000};
constexpr int          TEST_COUNT = 5;

