//#include "boost/filesystem.hpp"
//#include <iostream>
//#include <string>
//#include <opencv2/imgcodecs.hpp>
//#include <unistd.h>
//using namespace boost::filesystem;

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <iostream>
#include <string>
#include <unistd.h>
#include <opencv/cv.hpp>

using namespace std;
using namespace cv;

extern "C"
int *max_2x2_kernel(const int *mat, const int width, const int height) {

    int curr_ttl = width * height;
    vector<int> shrunk_vec;
    for (int i = 0; i < curr_ttl; i++) {
        if (i >= (width * (height - 1))) {
            break;
        }
        if (i != 0 and (i + 1) % width == 0) {
            continue;
        }
        vector<int> window{mat[i], mat[(i + 1)], mat[(i + width)], mat[(i + 1 + width)]};
        shrunk_vec.push_back(*std::max_element(window.begin(), window.end()));
    }

    return &shrunk_vec[0];
}

extern "C"
int *reverse_array(const int *input_array, const int size) {
    int *rev_array = new int[size];
    for (int i = 0; i < size; i++) {
        rev_array[size - i - 1] = input_array[i];
    }
    return rev_array;
}

extern "C"
int *get_data(char *image_file_path) {
    string pic_file(image_file_path);
    const Mat frame = imread(pic_file, cv::IMREAD_COLOR); // BGR
    const size_t total_size = frame.u->size;
    int *pixel_ints = new int[total_size];
    for (size_t i = 0; i < total_size; i++) {
        uchar pixel = frame.u->data[i];
        pixel_ints[i] = pixel;
    }
    return pixel_ints;
}

int main(int argc, char *argv[]) {

    std::cout << "working\n";

    char *prog = argv[0];
    (void) prog;
    (void) argc;


    string pic_path = "/Users/Bhill/git/AI_From_Dirt/two.15x15.png";
    return 0;
}