#include "../cpp/include/IMandelbrot.hpp"

#include <pybind11/stl.h>
#include <pybind11/pybind11.h>

namespace py = pybind11;

void init_mandelbrotConfig(py::module &m)
{

    py::class_<MandelbrotConfig>(m, "MandelbrotConfig")
        .def(py::init<>())
        .def_readwrite("height", &MandelbrotConfig::height)
        .def_readwrite("width", &MandelbrotConfig::width)
        .def_readwrite("reMin", &MandelbrotConfig::reMin)
        .def_readwrite("imMin", &MandelbrotConfig::imMin)
        .def_readwrite("reMax", &MandelbrotConfig::reMax)
        .def_readwrite("imMax", &MandelbrotConfig::imMax)
        .def_readwrite("maxSqr", &MandelbrotConfig::maxSqr)
        .def_readwrite("maxIter", &MandelbrotConfig::maxIter);
}