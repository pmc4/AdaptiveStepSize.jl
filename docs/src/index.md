```@meta
CurrentModule = AdaptiveStepSize
```

# AdaptiveStepSize

[AdaptiveStepSize](https://github.com/pmc4/AdaptiveStepSize.jl) is a Julia package used to obtain the minimum amount of points needed for the interpolation of a function in the given interval within the desired tolerance.

Given a function $f(x)$, defined on the interval $[a, \,b]$, and an interpolation method, it subdivides the interval with the maximum spacing between points such that the interpolation has an error smaller than the given tolerance.

For the moment, only linear interpolation is implemented. Any contribution is welcomed to further implement other methods.

```@index
```

```@autodocs
Modules = [AdaptiveStepSize]
```
