#include "../include/MandelbrotCUDA.hpp"
#include <iostream>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/copy.h>
#include <thrust/transform.h>
#include <thrust/functional.h>
#include <thrust/system/system_error.h>
#include <thrust/iterator/counting_iterator.h>

using namespace MandelbrotCUDA;
std::vector<std::vector<unsigned char>> colorizeMandelbrotThrustDev(const thrust::device_vector<int> devValues, const int maxIter);

std::vector<int> MandelbrotCUDA::createMandelbrotThrust(const MandelbrotConfig config){
    return std::vector<int>(1);
}


__global__
void createMandelbrotCUDADevice(const int width, const int height, const int maxIter, const size_t pitch, const double maxSqr, const double* xVals, const double* yVals, int* results){
    int posX = blockIdx.x*blockDim.x + threadIdx.x;
    int posY = blockIdx.y*blockDim.y + threadIdx.y;
    if(posX >= width || posY >= height){
        return;
    }
    const double re = xVals[posX];
    const double im = yVals[posY];
    int remainIter = maxIter;
    double reSqr = re * re;
    double imSqr = im * im;
    double reIm = re * im;
    double max2 = reSqr + imSqr;
    while ((max2 <= maxSqr) && (remainIter > 0))
    {
        remainIter--;
        double xBetween = reSqr - imSqr + re;
        double yBetween = reIm + reIm + im;
        reSqr = xBetween * xBetween;
        imSqr = yBetween * yBetween;
        reIm = xBetween * yBetween;
        max2 = reSqr + imSqr;
    }
    results[posX+posY*pitch] = maxIter - remainIter;

}

void calculatePositionVectors(thrust::device_vector<double>& xVals, thrust::device_vector<double>& yVals, const MandelbrotConfig config){
    double reRef = (config.reMax - config.reMin) / static_cast<double>(config.width);
    double imRef = (config.imMax - config.imMin) / static_cast<double>(config.height);
    thrust::device_vector<double> tempX(xVals.size());
    thrust::counting_iterator<int> startX(0);
    thrust::counting_iterator<int> endX = startX + xVals.size();
    thrust::device_vector<double> tempY(yVals.size());
    thrust::counting_iterator<int> startY(0);
    thrust::counting_iterator<int> endY = startY + yVals.size();
    // Precalculate positions in image regarding re/im values
    thrust::fill(xVals.begin(), xVals.end(), config.reMin);
    thrust::fill(tempX.begin(), tempX.end(), reRef);
    thrust::transform(startX, endX, tempX.begin(), tempX.begin(), thrust::multiplies<double>());
    thrust::transform(tempX.begin(), tempX.end(), xVals.begin(), xVals.begin(), thrust::plus<double>());
    thrust::fill(yVals.begin(), yVals.end(), config.imMin);
    thrust::fill(tempY.begin(), tempY.end(), imRef);
    thrust::transform(startY, endY, tempY.begin(), tempY.begin(), thrust::multiplies<double>());
    thrust::transform(tempY.begin(), tempY.end(), yVals.begin(), yVals.begin(), thrust::plus<double>());
}

std::vector<int> MandelbrotCUDA::createMandelbrotCUDAPitch(const MandelbrotConfig config){
    int* calcMem = 0;
    thrust::device_vector<double> xVals(config.width);
    thrust::device_vector<double> yVals(config.height);
    size_t memPitch;
    cudaError_t err;
    err = cudaMallocPitch((void **)&calcMem, &memPitch, static_cast<size_t>(config.width * sizeof(int)), static_cast<size_t>(config.height));
    if(err != cudaSuccess){
        return std::vector<int>(1);
    }
    
    calculatePositionVectors(xVals, yVals, config);
    
    double*   xValsPtr = thrust::raw_pointer_cast(xVals.data());
    double*  yValsPtr = thrust::raw_pointer_cast(yVals.data());
    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks(config.width / threadsPerBlock.x, config.height / threadsPerBlock.y);
    createMandelbrotCUDADevice<<<numBlocks, threadsPerBlock>>>(config.width, config.height, config.maxIter,memPitch/sizeof(int), config.maxSqr, xValsPtr, yValsPtr, calcMem);
    err = cudaDeviceSynchronize();

    std::vector<int> ret(config.height*config.width);
    err = cudaMemcpy2D(ret.data(), config.width*sizeof(int), calcMem, memPitch, config.width * sizeof(int), config.height, cudaMemcpyDeviceToHost);
    cudaFree(calcMem);
    return ret;
}

std::vector<int> MandelbrotCUDA::createMandelbrotCUDA(const MandelbrotConfig config){
    int* calcMem = 0;
    thrust::device_vector<double> xVals(config.width);
    thrust::device_vector<double> yVals(config.height);
    size_t memPitch = config.width*sizeof(int);
    cudaError_t err;
    err = cudaMalloc((void **)&calcMem, static_cast<size_t>(config.width * sizeof(int)*config.height));
    if(err != cudaSuccess){
        return std::vector<int>(1);
    }
    
    calculatePositionVectors(xVals, yVals, config);
    
    double*   xValsPtr = thrust::raw_pointer_cast(xVals.data());
    double*  yValsPtr = thrust::raw_pointer_cast(yVals.data());
    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks(config.width / threadsPerBlock.x, config.height / threadsPerBlock.y);
    createMandelbrotCUDADevice<<<numBlocks, threadsPerBlock>>>(config.width, config.height, config.maxIter,config.width, config.maxSqr, xValsPtr, yValsPtr, calcMem);
    err = cudaDeviceSynchronize();

    std::vector<int> ret(config.height*config.width);
    err = cudaMemcpy2D(ret.data(), config.width*sizeof(int), calcMem, memPitch, config.width * sizeof(int), config.height, cudaMemcpyDeviceToHost);
    cudaFree(calcMem);
    return ret;
}


std::vector<std::vector<unsigned char>> MandelbrotCUDA::createMandelbrotCUDAColorized(const MandelbrotConfig config){
    thrust::device_vector<int> calcMem(config.width * config.height);
    thrust::device_vector<double> xVals(config.width);
    thrust::device_vector<double> yVals(config.height);
    size_t memPitch = config.width*sizeof(int);
    cudaError_t err;

    
    calculatePositionVectors(xVals, yVals, config);

    double*   xValsPtr = thrust::raw_pointer_cast(xVals.data());
    double*  yValsPtr = thrust::raw_pointer_cast(yVals.data());
    int* calcMemPtr = thrust::raw_pointer_cast(calcMem.data());
    
    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks(config.width / threadsPerBlock.x, config.height / threadsPerBlock.y);
    createMandelbrotCUDADevice<<<numBlocks, threadsPerBlock>>>(config.width, config.height, config.maxIter,config.width, config.maxSqr, xValsPtr, yValsPtr, calcMemPtr);
    err = cudaDeviceSynchronize();
    return colorizeMandelbrotThrustDev(calcMem, config.maxIter);
}


/**
 * @brief set red color amount
 * 
 * Colors from: https://stackoverflow.com/questions/16500656/which-color-gradient-is-used-to-color-mandelbrot-in-wikipedia
 * Special thanks to q9f for reverse engineering!
 */
struct color_red : public thrust::unary_function<int, unsigned char>
{
    const unsigned char colorVals[16] = {   66,25,9,4,0,12,24,57,134,211,241,248,255,204,153,106};
    const int max;
    color_red(int _max) : max(_max) {}

    __host__ __device__
        unsigned char operator()(const int& x) const {
            if(x == 0 || x == max){
                return 0;
            }
            int i = x % 16;
            return colorVals[i];
        }
};

/**
 * @brief set green color amount
 * 
 * Colors from: https://stackoverflow.com/questions/16500656/which-color-gradient-is-used-to-color-mandelbrot-in-wikipedia
 * Special thanks to q9f for reverse engineering!
 */
struct color_green : public thrust::unary_function<int, unsigned char>
{
    const unsigned char colorVals[16] = { 30,7,1,4,7,44,82,125,181,236,233,201,170,128,87,52 };
    const int max;
    color_green(int _max) : max(_max) {}

    __host__ __device__
        unsigned char operator()(const int& x) const {
            if(x == 0 || x == max){
                return 0;
            }
            int i = x % 16;
            return colorVals[i];
        }
};

/**
 * @brief set blue color amount
 * 
 * Colors from: https://stackoverflow.com/questions/16500656/which-color-gradient-is-used-to-color-mandelbrot-in-wikipedia
 * Special thanks to q9f for reverse engineering!
 */
struct color_blue : public thrust::unary_function<int, unsigned char>
{
    const unsigned char colorVals[16] = { 15,26,47,73,100,138,177,209,229,248,191,95,0,0,0,3 };
    const int max;
    color_blue(int _max) : max(_max) {}

    __host__ __device__
        unsigned char operator()(const int& x) const {
            if(x == 0 || x == max){
                return 0;
            }
            int i = x % 16;
            return colorVals[i];
        }
};

/**
 * @brief Colorize all pixels based on the red, green and blue color function.
 * 
 * @param devValues device_vector containing result from cuda based calculation.
 * @param maxIter maximum iteration count
 * @return std::vector<std::vector<unsigned char>> r,g,b values
 */
std::vector<std::vector<unsigned char>> colorizeMandelbrotThrustDev(const thrust::device_vector<int> devValues, const int maxIter){
    thrust::device_vector<unsigned char> devRed(devValues.size());
    thrust::device_vector<unsigned char> devGreen(devValues.size());
    thrust::device_vector<unsigned char> devBlue(devValues.size());
    thrust::transform(devValues.begin(), devValues.end(), devRed.begin(), color_red(maxIter));
    thrust::transform(devValues.begin(), devValues.end(), devGreen.begin(), color_green(maxIter));
    thrust::transform(devValues.begin(), devValues.end(), devBlue.begin(), color_blue(maxIter));
    std::vector<std::vector<unsigned char>> result(3, std::vector<unsigned char>(devValues.size()));
    thrust::copy(devRed.begin(), devRed.end(), result[0].begin());
    thrust::copy(devGreen.begin(), devGreen.end(), result[1].begin());
    thrust::copy(devBlue.begin(), devBlue.end(), result[2].begin());
    return result;
}

/**
 * @brief Colorize mandelbrot results.
 * 
 * @param values mandelbrot calculation results as std::vector
 * @param maxIter maximum iteration
 * @return std::vector<std::vector<unsigned char>> r,g,b color vectors.
 */
std::vector<std::vector<unsigned char>> MandelbrotCUDA::colorizeMandelbrotThrust(const std::vector<int> values, const int maxIter){
    thrust::device_vector<int> devValues(values.begin(), values.end());
    thrust::device_vector<unsigned char> devRed(values.size());
    thrust::device_vector<unsigned char> devGreen(values.size());
    thrust::device_vector<unsigned char> devBlue(values.size());
    thrust::transform(devValues.begin(), devValues.end(), devRed.begin(), color_red(maxIter));
    thrust::transform(devValues.begin(), devValues.end(), devGreen.begin(), color_green(maxIter));
    thrust::transform(devValues.begin(), devValues.end(), devBlue.begin(), color_blue(maxIter));
    //thrust::copy(devRes.begin(), devRes.end(), hstRes.begin());
    //thrust::copy(hstRes.begin(), hstRes.end(), result.begin());
    // why error? thrust::copy(devValues.begin(), devValues.end(), result.begin());
    std::vector<std::vector<unsigned char>> result(3, std::vector<unsigned char>(values.size()));
    thrust::copy(devRed.begin(), devRed.end(), result[0].begin());
    thrust::copy(devGreen.begin(), devGreen.end(), result[1].begin());
    thrust::copy(devBlue.begin(), devBlue.end(), result[2].begin());
    return result;
}