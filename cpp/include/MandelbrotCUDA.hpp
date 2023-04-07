/**
 * @file MandelbrotCUDA.hpp
 * @author Alexander Mueller (dev@alexandermaxmueller.de)
 * @brief CUDA/Thrust based implementation of mandelbrot calculation. 
 * @version 0.1
 * @date 2023-04-07
 * 
 * @copyright Copyright (c) 2023
 * 
 */
#ifndef __MANDELBROT_CUDA_HPP__
#define __MANDELBROT_CUDA_HPP__
#include "IMandelbrot.hpp"
#include <vector>
#include "vector_types.h"

namespace MandelbrotCUDA
{
    /**
     * @brief Create a mandelbrot set with nvidia thrust library
     *
     * @param config
     * @return std::vector<int>
     */
    std::vector<int> createMandelbrotThrust(const MandelbrotConfig config);
    /**
     * @brief Create a mandelbrot set with a selfwritten cuda function
     *
     * @param config
     * @return std::vector<int>
     */
    std::vector<int> createMandelbrotCUDA(const MandelbrotConfig config);
    /**
     * @brief Create a mandelbrot set with a selfwritten cuda function and a pitched memory alignment
     * 
     * @param config 
     * @return std::vector<int> 
     */
    std::vector<int> createMandelbrotCUDAPitch(const MandelbrotConfig config);

    /**
     * @brief Create a mandelbrot set with a selfwritten cuda function and colorize the result.
     * 
     * @param config 
     * @return std::vector<std::vector<unsigned char>>
     */
    std::vector<std::vector<unsigned char>> createMandelbrotCUDAColorized(const MandelbrotConfig config);


    /**
     * @brief colorize a mandelbrot set using nvidia thrust library
     *
     * @param values
     * @return std::vector<std::vector<unsigned char>>
     */
    std::vector<std::vector<unsigned char>> colorizeMandelbrotThrust(const std::vector<int> values, const int maxIter);
    

};

#endif