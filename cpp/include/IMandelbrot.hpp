#ifndef __IMANDELBROT_HPP__
#define __IMANDELBROT_HPP__
/**
 * @brief Configuration object for all Mandelbrot calculation algorithms.
 * 
 */
struct MandelbrotConfig{
    int height;
    int width;
    double reMin;
    double imMin;
    double reMax;
    double imMax;
    double maxSqr;
    int maxIter;
};




#endif