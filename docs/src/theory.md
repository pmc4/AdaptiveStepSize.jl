# Theory

In this page we briefly describe each interpolation method and how the error estimation is computed. For usage of the methods, go to the [Interpolation methods section](@ref "Linear interpolation").

## [Linear interpolation](@id theory_linear_interpolation)

Given a function $f(x)$ defined on a domain $X \in \mathbb{R}$, and given two points $(x_0,\, y_0)$ and $(x_1,\, y_1)$ where $x_i \in X$ and $y_i \equiv f(x_i)$, we can approximate the function in the interval $[x_0,\, x_1]$ with the following second order polynomial:

```math
    p(x) = f(x_0) + \dfrac{f(x_1) - f(x0)}{x_1 - x_0} (x - x_0)\, .
```

The error of the approximation is defined as

```math
    R_T(x) = f(x) - p(x)\, .
```

If $f$ has a continuous second derivative, i.e., is a function of class $C^2$, then error is bounded by

```math
    \left|R_T\right| \leq \dfrac{(x_1 - x_0)^2}{8} \max_{x_0\, \leq\, x\, \leq\, x_1} \left|f^{\prime\prime}(x)\right|\, .
```

We can further divide $f(x)$ in several subintervals, delimited by $\lbrace x_i \rbrace_{i=0}^{n}$ and apply a linear interpolation to each of the subintervals.

If the function does not have a continuous second derivative, we cannot use the previous equation to estimate the error bound. However, if the discontinuities are *removable discontinuities* or *jump discontinuities* at different points $d_i$, we can locally apply the linear interpolation at the open intervals $(d_{i-1},\, d_i)$.
