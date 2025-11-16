#include <stdio.h>

long double w1 = 0.7L;
long double w2 = 0.3L;
long double bias = -0.1L;

// 1995-style simple sigmoid approximation
long double sigmoid(long double x) {
    // A fast approximation: x / (1.0L + |x|)
    long double abs_x = (x < 0 ? -x : x);
    return x / (1.0L + abs_x);
}

long double perceptron(long double x1, long double x2) {
    return sigmoid(w1 * x1 + w2 * x2 + bias);
}

int main() {
    long double inputs[][2] = {{0.0L, 0.0L}, {0.0L, 1.0L}, {1.0L, 0.0L}, {1.0L, 1.0L}};
    long double expected[] = {0.0L, 0.0L, 0.0L, 1.0L};

    printf("=== 80387 Neural Perceptron (2025 Edition) ===\n");

    for (int i = 0; i < 4; i++) {
        long double y = perceptron(inputs[i][0], inputs[i][1]);
        printf("Input: (%d, %d) → Output: %.10Lf (expected %.1Lf)\n",
               (int)inputs[i][0], (int)inputs[i][1], y, expected[i]);
    }
    return 0;
}
