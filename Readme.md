# MandelbrotCUDA-Python

A small application to demonstrate the combination of pybind11, cpp and CUDA.

Calculate the mandelbrot set via cpu and gpu. Makes it accessable via python3.

## Installation
Run './build.sh' to build whole system.

## Usage
See 'TestMandelbrot.py' for demonstration.

To generate a mandelbrot image, create a MandelbrotConfig object and set parameters.
This object can be used for 'MandelbrotCUDA.createMandelbrotCUDA(config)' or 'MandelbrotCUDA.createMandelbrotCPU(config)'. This allows an easy comparison between execution speed.

