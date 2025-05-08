# Linear interpolation

To compute the points of a linear interpolation for a given function $f(x)$, we can use the [`points_linear`](@ref) function.

```@docs
points_linear
```

For example, let us apply this function to $f(x) = \sqrt{2x}$ on the interval $[0,\, 2]$ with a tolerance of $10^{-2}$.

```@repl
using AdaptiveStepSize
f(x) = 2 * sqrt(x)
domain = (0.0, 2.0)
tol = 1e-2
xs, ys = points_linear(f, domain, tol; scan_step = 1e-4)
```

The returned `xs` and `ys` contain the points needed for the linear interpolation with an error smaller than the given tolerance. When calling the function, we have set a `scan_step` of $10^{-4}$. By default this value is computed such that the domain is divided in 100 steps. It is recommeneded to not set a very small value of the scan step. Depending on the desired tolerance, between 100 and 1e4 maximum possible subintervals is desired, otherwise, the execution time will be very small. It is recommendended to set the `scan_step` value as

```@repl
domain = (0.0, 2.0)
scan_step_value = (domain[end] - domain[begin]) / 1e4
```

where the `1e4` can be the maximum number of points you want.

```@setup sqrt_example
using AdaptiveStepSize, CairoMakie
f(x) = 2 * sqrt(x)
domain = (0.0, 2.0)
tol = 1e-2
xs, ys = points_linear(f, domain, tol; scan_step = 1e-4)

plot_xs = collect(range(domain[begin], domain[end], 200))
plot_ys = f.(plot_xs)

fig = Figure()
ax = Axis(fig[1,1], xlabel = "x", ylabel = "f(x) = sqrt(2x)")
lines!(ax, plot_xs, plot_ys)
scatter!(ax, xs, ys)
```

We can plot the points `xs` and `ys` on top of the function and observe that when $f(x)$ varies more, the points are closer, whereas the get further away when they are more linear.

```@example sqrt_example
fig # hide
```

Note that even though the second derivative of our function $f(x) = \sqrt{2x}$ is not defined at $x = 0$ (therefore is not continuous), there is no problem. The function [`points_linear`](@ref) will never evaluate the second derivative at the boundaries defined by the `domain` parameter.

## Singularities

A singularity is a point at which the function is not defined or is not well-behaved. A typical example is $|x|$, in which the function is continuous at $x = 0$ but not differentiable (the derivative is not continuous at that point). For these kind of functions, we can use [`points_linear_singular`](@ref). The only difference between this function and [`points_linear`](@ref) is that here we need to pass an extra parameter called `singularities`. This must be a `Vector{T}` where `T<:Real` containing all those singular points. The algorithm will compute the points for each subinterval delimited by this `singularities` vector.

```@docs
points_linear_singular
```

Hence, let us compute the `xs` and `ys` points for the absolute value function $f(x) = |x|$.

```@repl
using AdaptiveStepSize
f(x) = abs(x)
domain = (-1.0, 1.0)
tol = 1e-2
singularities = [0.0,]
xs, ys = points_linear_singular(f, domain, singularities, tol; scan_step = 1e-4)
```

Since this is a simple function made of two lines that intersect at $x = 0$, we get the expected points. Note that if you call `points_linear` instead of `points_linear_singular` you will not get the point $(0.0, 0.0)$ in the results. It is very unlikely to exactly compute a certain point when doing the scan. That is why passing explicitly the `singularities` to the former method is preferred. We can plot the results to see how it looks like.

```@setup abs_example
using AdaptiveStepSize, CairoMakie
f(x) = abs(x);
domain = (-1.0, 1.0);
tol = 1e-2;
singularities = [0.0,]
xs, ys = points_linear_singular(f, domain, singularities, tol; scan_step = 1e-4)

plot_xs = collect(range(domain[begin], domain[end], 200))
plot_ys = f.(plot_xs)

fig = Figure()
ax = Axis(fig[1,1], xlabel = "x", ylabel = "f(x) = |x|")
lines!(ax, plot_xs, plot_ys)
scatter!(ax, xs, ys)
```

```@example abs_example
fig # hide
```

## Piecewise functions

If we have a piecewise function instead, it is more convenient to call [`points_linear`](@ref) at each interval of the function instead of [`points_linear_singular`](@ref) and passing the `singularities` vector with each case point. This is because the result contains just one big pair `xs` and `ys` vectors and it is not aware of the points where piecewise function is not continuous, hence producing undesiderable results in the interpolation.

To see this in action, let us consider the following piecewise function

```math
f(x) = \begin{cases}
    \sin(x) &\text{if } x < 2\pi \\
    (x - 8)^2 &\text{if } 2\pi \leq x \leq 10 \\
    \sqrt{x} - 3 &\text{if } x > 10
\end{cases}
```

We will consider the domain $[0,\, 20]$. First, we will make use of the `points_linear_singular` and see why is not convenient. In Julia, we can write this as

```@repl
using AdaptiveStepSize

function f(x)
    if x < 2π
        return sin(x)
    elseif x <= 10.0
        return (x - 8)^2
    else
        return sqrt(x) - 3
    end
end

domain = (0.0, 20.0)
tol = 1e-2
singularities = [2π, 10.0]
xs, ys = points_linear_singular(f, domain, singularities, tol; scan_step = 1e-4)
```

```@setup piecewise_example
using AdaptiveStepSize, CairoMakie

function f(x)
    if x < 2π
        return sin(x)
    elseif x <= 10.0
        return (x - 8)^2
    else
        return sqrt(x) - 3
    end
end


function plot()
    domain = (0.0, 20.0);
    tol = 1e-2;
    singularities = [2π, 10.0]
    xs, ys = points_linear_singular(f, domain, singularities, tol; scan_step = 1e-4)

    plot_xs1 = collect(range(domain[begin], singularities[1] - 1e-15, 100))
    plot_xs2 = collect(range(singularities[1], singularities[2], 100))
    plot_xs3 = collect(range(singularities[2] + 1e-15, domain[end], 100))

    plot_ys1 = f.(plot_xs1)
    plot_ys2 = f.(plot_xs2)
    plot_ys3 = f.(plot_xs3)

    fig = Figure()
    ax = Axis(
        fig[1,1], xlabel = "x", ylabel = "f(x)",
        title = "Using `points_linear_singular`"
    )
    ylims!(ax, -1.2, 5.2)
    lines!(ax, plot_xs1, plot_ys1)
    lines!(ax, plot_xs2, plot_ys2)
    lines!(ax, plot_xs3, plot_ys3)

    scatter!(ax, xs, ys)

    fig
end

function plot2()
    domain1 = (0.0, 2π - 1e-15)
    domain2 = (2π, 10.0)
    domain3 = (10.0 + 1e-15, 20.0)

    tol = 1e-2;
    xs1, ys1 = points_linear(f, domain1, tol; scan_step = 1e-4)
    xs2, ys2 = points_linear(f, domain2, tol; scan_step = 1e-4)
    xs3, ys3 = points_linear(f, domain3, tol; scan_step = 1e-4)


    plot_xs1 = collect(range(domain1[begin], domain1[end] - 1e-15, 100))
    plot_xs2 = collect(range(domain2[begin], domain2[end], 100))
    plot_xs3 = collect(range(domain3[begin] + 1e-15, domain3[end], 100))


    plot_ys1 = f.(plot_xs1)
    plot_ys2 = f.(plot_xs2)
    plot_ys3 = f.(plot_xs3)

    fig = Figure()
    ax = Axis(
        fig[1,1], xlabel = "x", ylabel = "f(x)",
        title = "Using `points_linear` three times"
    )
    ylims!(ax, -1.2, 5.2)
    lines!(ax, plot_xs1, plot_ys1)
    lines!(ax, plot_xs2, plot_ys2)
    lines!(ax, plot_xs3, plot_ys3)

    scatter!(ax, xs1, ys1)
    scatter!(ax, xs2, ys2)
    scatter!(ax, xs3, ys3)


    fig
end
```

If we plot now the result over the piecewise $f(x)$ function, we get:

```@example piecewise_example
plot() # hide
```

What is happening here is that the endpoints of each segment of the piecewise function do not always have a point (blue circle). If we apply linear interpolation to the whole result, we will get wrong results near those endpoints. This is because [`points_linear_singular`](@ref) is suitable only for continuous functions. To fix this, we have to call [`points_linear`](@ref) once for each segment:

```@repl
using AdaptiveStepSize

function f(x)
    if x < 2π
        return sin(x)
    elseif x <= 10.0
        return (x - 8)^2
    else
        return sqrt(x) - 3
    end
end

domain1 = (0.0, 2π - 1e-15)
domain2 = (2π, 10.0)
domain3 = (10.0 + 1e-15, 20.0)

tol = 1e-2;
xs1, ys1 = points_linear(f, domain1, tol; scan_step = 1e-4)
xs2, ys2 = points_linear(f, domain2, tol; scan_step = 1e-4)
xs3, ys3 = points_linear(f, domain3, tol; scan_step = 1e-4)
```

When we plot the results we explicitly get the endpoints.

```@example piecewise_example
plot2() # hide
```

We can now apply a linear interpolation to each segment and the result will be correct.

!!! note "Use the desired tolerance"
    In all of these examples we are using a high tolerance of `tol = 1e-2` for the sake of clarity on the figures. If you want something more precise like `tol = 1e-6` you can do it, bear in mind that when visualizing it, you have a bunch of points close together that you cannot distinguish them individually from the plot.
