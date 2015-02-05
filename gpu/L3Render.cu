#include <stdint.h>

// Define parameters
#define cfa_size      4
#define num_filter    5
#define patch_size    9
#define border_size   4
#define image_width   720
#define image_height  1280
#define voltage_max   0.9734
#define lum_list_size 20
#define num_out       3
#define low           0.95
#define high          1.15

/* Cuda function - L3Render

  Compute mean for each channel

  Inputs:
    out_image       - pre-allocated space for output (xyz) image
    image           - original image
    cfa             - cfa pattern, should be 0-indexed
    lum_list        - luminance list
    sat_list        - saturation list
    flat_filters    - filters for flat regions
    texture_filters - filters for texture regions
*/
__global__
void L3Render(float* const out_image,
                 float  const * const image,
                 unsigned short const * const cfa,
                 float  const * const lum_list,
                 float  const * const sat_list,
                 float  const * const flat_filters,
                 float  const * const texture_filters,
                 float  const * const flat_threshold_list)
{
    // Find pixel position
    const int row = blockIdx.x;
    const int col = threadIdx.x;
    
    // Check pixel range
    if ((row < border_size) || 
        (row >= image_height - border_size) ||
        (col < border_size) ||
        (col >= image_width - border_size))
        return;
    
    // Compute patch type
    const unsigned short patch_type[] = {row % cfa_size, col % cfa_size};
    
    // Compute mean for each channel
    float channel_mean[num_filter] = {0.0};
    unsigned short channel_count[num_filter] = {0};
    unsigned short cfa_index[patch_size * patch_size];

    for (short ii = -border_size; ii <= border_size; ii++){
        for (short jj = -border_size; jj <= border_size; jj++){
            unsigned short index = ii + border_size + (jj + border_size) * patch_size;
            cfa_index[index] = ((row + ii) % cfa_size) +
                               ((col + jj) % cfa_size) * cfa_size;
            channel_count[cfa[cfa_index[index]]] += 1;
            channel_mean[cfa[cfa_index[index]]] += image[row + ii + (col + jj) * image_height];
        }
    }

    // Compute channel mean and luminance
    float lum_mean = 0;
    size_t pixel_index = row + col * image_height;
    for (int ii = 0; ii < num_filter; ii++) {
        channel_mean[ii] /= channel_count[ii];
        lum_mean += channel_mean[ii];
    }
    lum_mean /= num_filter;
    
    // Convert luminance to luminance index
    // Binary search will be faster, but, we just use linear search for simplicity
    unsigned short lum_index = lum_list_size - 1;
    for (int ii = 0; ii < lum_list_size; ii++) {
        if (lum_mean < lum_list[ii]) {
            lum_index = ii;
            break;
        }
    }
    
    // Compute saturation type
    unsigned short sat_type = 0; // sat_type is the encoded saturation type
    unsigned short sat_index;    // sat_index is the number found with sat_list
    const unsigned short sat_list_size = (1 << num_filter);
    for (int ii = num_filter - 1; ii >= 0; ii --)
        sat_type = sat_type << 1 + (channel_mean[ii] > voltage_max);
    
    const float *cur_sat_list = sat_list + (patch_type[1] * cfa_size + patch_type[0]) * sat_list_size;
    sat_index = cur_sat_list[sat_type];
    
    // Find nearest sat_type for missing ones
    if (sat_index == 0){
        float min_cost = 10000; // Init min cost to some arbitrarily large value
        for (int ii = 0; ii < sat_list_size; ii++) {
            if (cur_sat_list[ii] == 0) continue;
            // compute cost
            float cur_cost = 0;
            for (int jj = 0; jj < num_filter; jj++) {
                if (((ii ^ sat_type) & (1 << jj)) > 0) {
                    float dist_to_max = channel_mean[jj] - voltage_max;
                    cur_cost += (dist_to_max > 0 ? dist_to_max : -dist_to_max);
                }
            }
            if (cur_cost < min_cost) {
                min_cost = cur_cost;
                sat_index = cur_sat_list[ii];
            }
        }
    }
    sat_index--; // make sat_index 0-indexed

    // Compute image contrast
    // Assume image_contrast array has been allocated as zeros
    float image_contrast = 0;
    for (int ii = -border_size; ii <= border_size; ii++){
        for (int jj = -border_size; jj <= border_size; jj++){
            unsigned short index = ii + border_size + (jj + border_size) * patch_size;
            size_t cur_pixel_index = row + ii + (col + jj) * image_height;
            float dist_to_mean = image[cur_pixel_index] - channel_mean[cfa[cfa_index[index]]];
            if (dist_to_mean > 0)
                image_contrast += dist_to_mean;
            else
                image_contrast -= dist_to_mean;
        }
    }
    image_contrast /= num_filter;
    
    // Determine flat or texture
    int threshold_index  = ((sat_index * lum_list_size + lum_index) 
                            * cfa_size + patch_type[1]) * cfa_size + patch_type[0];
    float flat_threshold = flat_threshold_list[threshold_index];
    
    // Apply filter to patch
    const float *filter;
    if (image_contrast < flat_threshold * low) { // flat region
        filter = flat_filters + threshold_index * num_out * patch_size * patch_size;
        for (int ii = -border_size; ii <= border_size; ii++){
            for (int jj = -border_size; jj <= border_size; jj++){
                unsigned short index = (ii + border_size + (jj + border_size) * patch_size)*3;
                size_t cur_pixel_index = row + ii + (col + jj) * image_height;
                out_image[pixel_index] += image[cur_pixel_index] * filter[index];
                out_image[pixel_index + image_width * image_height] += image[cur_pixel_index] * filter[index + 1];
                out_image[pixel_index + 2 * image_width * image_height] += image[cur_pixel_index] * filter[index + 2];
            }
        }
    }
    else if (image_contrast > flat_threshold * high) { // texture region
        filter = texture_filters + threshold_index * num_out * patch_size * patch_size;
        for (int ii = -border_size; ii <= border_size; ii++){
            for (int jj = -border_size; jj <= border_size; jj++){
                unsigned short index = (ii + border_size + (jj + border_size) * patch_size)*3;
                size_t cur_pixel_index = row + ii + (col + jj) * image_height;
                out_image[pixel_index] += image[cur_pixel_index] * filter[index];
                out_image[pixel_index + image_width * image_height] += image[cur_pixel_index] * filter[index + 1];
                out_image[pixel_index + 2 * image_width * image_height] += image[cur_pixel_index] * filter[index + 2];
            }
        }
    } 
    else { // transition region
        const float weights = (image_contrast / flat_threshold - low) / (high - low);
        filter = flat_filters + threshold_index * num_out * patch_size * patch_size;
        const float* filter_texture = texture_filters + threshold_index * num_out * patch_size * patch_size;
        for (int ii = -border_size; ii <= border_size; ii++){
            for (int jj = -border_size; jj <= border_size; jj++){
                unsigned short index = (ii + border_size + (jj + border_size) * patch_size) * 3;
                size_t cur_pixel_index = row + ii + (col + jj) * image_height;
                out_image[pixel_index] += image[cur_pixel_index] * (filter[index] * weights + filter_texture[index] * (1 - weights));
                out_image[pixel_index + image_width * image_height] += image[cur_pixel_index] * (filter[index + 1] * weights + filter_texture[index + 1]*(1-weights));
                out_image[pixel_index + 2 * image_width * image_height] += image[cur_pixel_index] * (filter[index + 2]*weights + filter_texture[index+2]*(1-weights));
            }
        }
    }
}