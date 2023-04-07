#include "../cpp/include/MandelbrotCUDA.hpp"
#include "../cpp/include/IMandelbrot.hpp"
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <pybind11/functional.h>
namespace py = pybind11;

void init_mandelbrotCUDA(py::module &m)
{

    m.def("colorizeMandelbrotThrust", &MandelbrotCUDA::colorizeMandelbrotThrust);
    m.def("createMandelbrotCUDA", &MandelbrotCUDA::createMandelbrotCUDA);
    m.def("createMandelbrotCUDAPitch", &MandelbrotCUDA::createMandelbrotCUDAPitch);
    m.def("createMandelbrotCUDAColorized", &MandelbrotCUDA::createMandelbrotCUDAColorized);
}