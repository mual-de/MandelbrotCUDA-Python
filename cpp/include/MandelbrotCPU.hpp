/**
 * @file MandelbrotCPU.hpp
 * @author Alexander Mueller (dev@alexandermaxmueller.de)
 * @brief CPU implementation of Mandelbrot calculation.
 * @version 0.1
 * @date 2023-04-07
 * 
 * @copyright Copyright (c) 2023
 * 
 */
#ifndef __MANDELBROT_CPU_HPP__
#define __MANDELBROT_CPU_HPP__
#include "IMandelbrot.hpp"
#include <vector>
namespace MandelbrotCPU{
        /**
         * @brief Create a Mandelbrot Set with cpu multithreading.
         * 
         * @param config 
         * @return std::vector<int> 
         */
        std::vector<int> createMandelbrot(const MandelbrotConfig config);
        /**
         * @brief Internal run thread function.
         * 
         * @param config 
         * @param reValues 
         * @param imValues 
         * @param iterMap 
         * @param threadNumber 
         * @param numberOfThreads 
         */
        void runThread(const MandelbrotConfig config, const std::vector<double>& reValues, const std::vector<double>& imValues, std::vector<int>&iterMap, const int threadNumber, const int numberOfThreads);
        int calcJulia(double re, double im, const double maxSqr, const int maxIter);
};

#endif