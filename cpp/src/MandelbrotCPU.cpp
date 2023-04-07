#include "../include/MandelbrotCPU.hpp"
#include <thread>
#include <iostream>


std::vector<int> MandelbrotCPU::createMandelbrot(MandelbrotConfig config)
{
    std::vector<int> iterMap(config.height * config.width);
    std::vector<double> imValues(config.height);
    std::vector<double> reValues(config.width);
    double reRef = (config.reMax - config.reMin) / static_cast<double>(config.width);
    double imRef = (config.imMax - config.imMin) / static_cast<double>(config.height);
    double reVal = config.reMin;
    double imVal = config.imMin;
    int numberOfThreads = static_cast<char>(std::thread::hardware_concurrency());
    for (int i = 0; i < config.width; i++)
    {
        reValues[i] = reVal;
        reVal += reRef;
    }
    for (int i = 0; i < config.height; i++)
    {
        imValues[i] = imVal;
        imVal += imRef;
    }
    std::vector<std::thread> threads(numberOfThreads);
    for(int i = 0; i< numberOfThreads; i++){
        threads[i] = std::thread(runThread, std::ref(config), std::ref(reValues), std::ref(imValues), std::ref(iterMap), i, numberOfThreads);
    }
    for(auto& e : threads){
        e.join();
    }
    return iterMap;
}

void MandelbrotCPU::runThread(const MandelbrotConfig config, const std::vector<double> &reValues, const std::vector<double> &imValues, std::vector<int> &iterMap, const int threadNumber, const int numberOfThreads)
{
    for (int yIter = 0; yIter < config.height; yIter++)
    {
        for (int xIter = threadNumber; xIter < config.width; xIter = xIter + numberOfThreads)
        {
            //std::cout << "x: " << xIter << "\t re: " << reValues[xIter] << "\t y: " << yIter  << "\t im: "  << imValues[yIter] << std::endl;
            iterMap[xIter + yIter * config.width] = calcJulia(reValues[xIter], imValues[yIter], config.maxSqr, config.maxIter);
        }
    }
}

int MandelbrotCPU::calcJulia(const double re, const double im, const double maxSqr, const int maxIter)
{
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
    return maxIter - remainIter;
}
