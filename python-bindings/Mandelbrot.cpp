
#include "../cpp/include/MandelbrotCPU.hpp"
#include "../cpp/include/IMandelbrot.hpp"
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <pybind11/functional.h>

namespace py = pybind11;

void init_mandelbrotConfig(py::module &);
void init_mandelbrotCUDA(py::module &);
namespace mcl
{

    PYBIND11_MODULE(MandelbrotCUDA, m)
    {
        // Optional docstring
        m.doc() = "MandelbrotCalculationLib";

        init_mandelbrotConfig(m);
        init_mandelbrotCUDA(m);
        m.def("createMandelbrotCPU", &MandelbrotCPU::createMandelbrot);
        m.def("calcJuliaCPU", &MandelbrotCPU::calcJulia);
    }
}