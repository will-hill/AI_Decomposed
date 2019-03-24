#include <iostream>
#include <vector>
#include <algorithm>
#include <numeric>
#include <tgmath.h>

extern "C" int *max_2x2_kernel(const int *pixels, const int width, const int height) {
    // total pixels to convolve
    int total_pixels = width * height;
    // to hold convolution
    std::vector<int> convolution;
    // slide kernel over pixels
    for (int i = 0; i < total_pixels; i++) {
        // test if done
        if (i >= (width * (height - 1))) {
            break;
        }
        if (i != 0 and (i + 1) % width == 0) {
            continue;
        }
        // grab 2x2 window, calculate mean and add to convolution
        std::vector<int> window{pixels[i], pixels[(i + 1)], pixels[(i + width)], pixels[(i + 1 + width)]};
        double sum = std::accumulate(window.begin(), window.end(), 0.0);
        int mean = (int) std::round(sum / window.size());
        convolution.push_back(mean);
    }
    // return as array pointer
    return &convolution[0];
}

extern "C" int *recurse_convolution(const int *pixels, const int width, const int height, const int cnt) {
    std::cout << "start\n";
    int w = width, h = height;
    int *convolution = new int[h * w];
    for (int i = 0; i < w * h; i++) {
        convolution[i] = pixels[i];
    }
    for (int i = 0; i < cnt; i++) {
        convolution = max_2x2_kernel(convolution, width, height);
        w--;
        h--;
    }
    return convolution;
}

int main(int argc, char *argv[]) {
    (void) argc;
    int p[] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    recurse_convolution(p, 3, 3, 1000000);
    //max_2x2_kernel(asdf)
    return 0;
}