"""
Main module for `AdaptiveStepSize.jl`, a Julia package used to obtain the minimum amount of points needed for the interpolation of a function in the given interval within the desired tolerance.

Only linear interpolation methods are implemented for now. Any contribution is wecolmed to further implement other methods.

Check the docs for more information.
"""
module AdaptiveStepSize

using Enzyme

export points_linear, points_linear_singular

"Direction of the derivative. Derivate w.r.t. positive x in 1 dimension."
const _DIRECTION_1D_X = [1.0,]
"Smallest value for the Float64 type."
const _MIN_FLOAT::Float64 = -floatmin(Float64)


"""
    points_linear(f, domain, tol::T; scan_step = (domain[end] - domain[begin]) / 100) where T <: Real

Computes points used for a linear interpolation of the function `f` in the given `domain`
within a tolerance `tol`.

See also [`points_linear_singular`](@ref) for managing singular points.

# Arguments
- `f`: The function used for the linear interpolation. It must be of the form of f(x), where `x` is a number.
- `domain`: a tuple or array representing the interpolation domain, e.g., the tuple (a, b).
- `tol::T where T <: Real`: the desired tolerance of the points. The real value of the function at any point xᵢ minus the aproximation will be smaller than `tol`, i.e., |f(xᵢ) - yᵢ| < tol.

# Keywords
- `scan_step`: Minimum step size that will be used to scan the whole domain. The returned points will have at least a spacing of `scan_step`. Very small values will produce a very long execution time. By default it will divide the domain in 100 intervals.

# Returns
- `(xs, ys)`: A tuple containing two arrays of points, `xs` for the independent variable and `ys` for the computed values of the function.

# Notes
The function `f` must have a continuous second derivative in order to compute the linear
interpolation error. This second derivative is computed using `Enzyme`'s automatic
differentiation.

If the returned `(xs, ys)` contains just the endpoints, try decreasing the `scan_step` size
and/or increasing the tolerance `tol`.

If the execution time of a single call to the function `f` is quite long, this adaptive method
might not be suitable.
"""
function points_linear(f, domain, tol::T; scan_step = (domain[end] - domain[begin]) / 100) where T<:Real
    # Enzyme calls a vector function for inplace operations
    fun(x) = f(x[1])
    # Homogenize the type of the domain and unpack it
    domain = promote(domain...)
    a, b = domain
    NUMBER_TYPE = typeof(a)
    # Store results for inplace derivation
    hes = Vector{NUMBER_TYPE}(undef, 1)
    grad = Vector{NUMBER_TYPE}(undef, 1)
    # Point where the derivative will be evaluated
    point = Vector{NUMBER_TYPE}(undef, 1)
    # Points used for the linear interpolation
    xs = Vector{NUMBER_TYPE}()
    ys = Vector{NUMBER_TYPE}()
    # Preallocate 200 elements for better performance
    sizehint!(xs, 200)
    sizehint!(ys, 200)
    # Avoid infinite loops
    MAX_ITER = floor((b - a) / scan_step)
    current_iter = 0

    # First iteration
    x0 = a
    x1 = x0 + scan_step
    y0 = f(x0)
    max_fpp = _MIN_FLOAT

    # Note that x1 will never be equal to b. This avoids computing the second derivative at the endpoints.
    while x1 < b && current_iter < MAX_ITER
        # Compute second derivative at the next point x1
        y1 = f(x1)
        h = x1 - x0 # Interval size
        point[begin] = x1
        hvp_and_gradient!(hes, grad, fun, point, _DIRECTION_1D_X)
        abs_fpp = abs(hes[1]) # Absolute value of the second derivative

        if abs_fpp > max_fpp
            max_fpp = abs_fpp
        end

        # Linear interpolation error upper bound
        error_upper_bound = h^2 * max_fpp / 8

        # Continue scanning if the error is smaller than the tolerance
        if error_upper_bound < tol
            x1 += scan_step
        # If not, save the previous point and start again
        else
            push!(xs, x0)
            push!(ys, y0)

            x0 = x1
            y0 = y1
            x1 = x0 + scan_step
            max_fpp = _MIN_FLOAT
        end

        current_iter += 1
    end

    # If f is a linear function, the while loop will never add a point, since error_upper_bound
    # will always be smaller than the tolerance. `a` must always be the first point
    if isempty(xs) && isempty(ys)
        push!(xs, a)
        push!(ys, f(a))
    end

    # Make the last point to be always b
    if last(xs) < b
        push!(xs, b)
        push!(ys, f(b))
    end

    return xs, ys
end


"""
    points_linear_singular(f, domain, singularities::Vector{T}, tol::T; scan_step = (domain[end] - domain[begin]) / 100) where T <: Real

Computes points used for a linear interpolation of the function `f` in the given `domain`
within a tolerance `tol`. Manages singular points though the array `singularities`.

See [`points_linear`](@ref) for an in depth description of the arguments. This function needs
the additional argument `singularities`. This must be a `Vector{T}` where `T<:Real` that
contains each singular point.

A singularity in this case is a point at which the function is not well-behaved, like `abs(x)` at x = 0, where the function is continuous but not differentiable.

If the function has several singularities, we can write those in the `singularities` vector. The function `points_linear` will be applied at each subinterval. In addition,
the second derivative will never be computed at those endpoints, i.e., at the `singularities`
and the `domain` points. Note that `f` **will be** evaluated at the endpoints and it should
handle those discontinuities properly. It is the user responsability to do so.

## Notes
If you have a piecewise function, it might be convenient to apply [`points_linear`](@ref) at each interval of the function, instead of passing the `singularities` vector here. The reason is that the result contains just one big pair `xs` and `ys` vectors and it is not aware of the points where piecewise function is not continuous, hence producing undesiderable results in the interpolation.

The safest bet here is linearly interpolate each region of the piecewise function separately.
"""
function points_linear_singular(f, domain, singularities::Vector{T}, tol::T; scan_step = (domain[end] - domain[begin]) / 100) where T<:Real
    # Add the domain to the singularities. These are the new bounds for each step
    new_bounds = [domain[begin]; singularities; domain[end]]
    # Homogenize the type of the bounds
    new_bounds = promote(new_bounds...)
    NUMBER_TYPE = typeof(new_bounds[begin])

    # Points used for the linear interpolation
    xs = Vector{NUMBER_TYPE}()
    ys = Vector{NUMBER_TYPE}()
    # Preallocate 200 elements for better performance
    sizehint!(xs, 200)
    sizehint!(ys, 200)

    for i in eachindex(new_bounds[begin:end-1])
        new_a = new_bounds[i]
        new_b = new_bounds[i+1]
        aux_xs, aux_ys = points_linear(f, (new_a, new_b), tol; scan_step = scan_step)

        # If we are not in the first pair of bounds, remove the first point to avoid duplicates
        # since new_a of the current iteration = new_b of the previous one
        if !isempty(xs) && !isempty(ys)
            popfirst!(aux_xs)
            popfirst!(aux_ys)
        end

        append!(xs, aux_xs)
        append!(ys, aux_ys)
    end

    return xs, ys
end

end
