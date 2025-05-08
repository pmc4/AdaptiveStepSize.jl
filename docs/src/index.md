```@meta
CurrentModule = AdaptiveStepSize
```

# AdaptiveStepSize

[AdaptiveStepSize](https://github.com/pmc4/AdaptiveStepSize.jl) is a Julia package used to obtain the minimum amount of points needed for the interpolation of a function in the given interval within the desired tolerance.

Given a function $f(x)$, defined on the interval $[a, \,b]$, and an interpolation method, it subdivides the interval with the maximum spacing between points such that the interpolation has an error smaller than the given tolerance.

For the moment, only linear interpolation is implemented. Any contribution is welcomed to further implement other methods.

## Aim of this package

This package is useful if you have a function that takes a bit of time to execute (less than a second per call, for example) and you need to interpolate it to reduce the execution time. This is a possible use case when such function must be called hundreds or thousands of times.

If your function takes a lot of time to execute, it may not be worth to use the package, since it computes the value of the function a lot of times in the given interval.

## Contents

- Check the [Usage](@ref "Linear interpolation") section to see the available options and instructions.
- The [Theory](@ref) section contains a brief explanation on how the interpolation method works and how the error is estimated.
