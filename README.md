# AdaptiveStepSize

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://pmc4.github.io/AdaptiveStepSize.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://pmc4.github.io/AdaptiveStepSize.jl/dev/)
[![Build Status](https://github.com/pmc4/AdaptiveStepSize.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/pmc4/AdaptiveStepSize.jl/actions/workflows/CI.yml?query=branch%3Amain)

AdaptiveStepSize is a Julia package used to obtain the minimum amount of points needed for the interpolation of a function in the given interval within the desired tolerance.

Given a function $f(x)$, defined on the interval $[a, b]$, and an interpolation method, it subdivides the interval with the maximum spacing between points such that the interpolation has an error smaller than the given tolerance.

## Aim of this package

This package is useful if you have a function that takes a bit of time to execute (less than a second per call, for example) and you need to interpolate it to reduce the execution time. This is a possible use case when such function must be called hundreds or thousands of times.

If your function takes a lot of time to execute, it may not be worth to use the package, since it computes the value of the function a lot of times in the given interval.

## Installation and usage

Open Julia in a terminal and enter into Pkg mode by pressing `[` and then write

```julia
add AdaptiveStepSize
```

[Read the docs](https://pmc4.github.io/AdaptiveStepSize.jl/stable/) to know how to use it.

## Showcase

For the moment, only linear interpolation is implemented. Any contribution is welcomed to further implement other methods.

An example of the points generated for a piecewise function with a tolerance of 5e-3 using linear interpolation is:
![Piecewise function with linear interpolation](/assets/example_plot_piecewise.png)
