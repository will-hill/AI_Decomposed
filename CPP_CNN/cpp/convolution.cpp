#include <iostream>
#include <vector>
#include <algorithm>
#include <numeric>
#include <tgmath.h>
#include <array>

std::vector<int> pool_2x2_kernel(std::vector<int> pixels, const int width, const int height, const int funct) {

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
        // grab 2x2 window, calculate max or mean and add to convolution
        std::vector<int> window{pixels[i], pixels[(i + 1)], pixels[(i + width)], pixels[(i + 1 + width)]};

        double y = 255;
        if (funct == 0) {
            double sum = std::accumulate(window.begin(), window.end(), 0.0);
            y = sum / window.size();
        } else {

            y = *max_element(window.begin(), window.end());
        }
        convolution.push_back(std::nearbyint(y));
    }
    return convolution;
}

extern "C" int *recurse_convolution(const int *pixels, const int width, const int height, const int recurse_cnt, const int use_max) {
    int w = width, h = height, pixel_count = h * w;
    std::vector<int> convolution(pixel_count);
    for (int i = 0; i < w * h; i++) {
        convolution[i] = pixels[i];
    }
    for (int i = 0; i < recurse_cnt; i++) {
        convolution = pool_2x2_kernel(convolution, w, h, use_max);
        w--;
        h--;
    }

    int *convo_array = new int[convolution.size()];
    std::copy(convolution.begin(), convolution.end(), convo_array);
    return convo_array;
}

int main(int argc, char *argv[]) {
    (void) argc;

    int mat[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
    int width = 4;
    int recurse_cnt = 2;

    int mat_size = sizeof(mat) / sizeof(mat[0]);
    int height = mat_size / width;
    int use_max = 0;

    int *output = recurse_convolution(mat, width, height, recurse_cnt, use_max);

    int ret_w = width - recurse_cnt;
    int ret_h = height - recurse_cnt;
    int array_size = ret_h * ret_w;
    std::cout << "---" << std::endl;
    for (int i = 0; i < array_size; i++) {
        std::cout << output[i] << " ";
    }
    //max_2x2_kernel(asdf)
    return 0;
}