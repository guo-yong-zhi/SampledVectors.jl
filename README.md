# SampledVectors.jl
[![CI](https://github.com/guo-yong-zhi/SampledVectors.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/guo-yong-zhi/SampledVectors.jl/actions/workflows/ci.yml) [![CI-nightly](https://github.com/guo-yong-zhi/SampledVectors.jl/actions/workflows/ci-nightly.yml/badge.svg)](https://github.com/guo-yong-zhi/SampledVectors.jl/actions/workflows/ci-nightly.yml) [![codecov](https://codecov.io/gh/guo-yong-zhi/SampledVectors.jl/branch/main/graph/badge.svg?token=785ZNXGQKL)](https://codecov.io/gh/guo-yong-zhi/SampledVectors.jl)  
`SampledVector` is of limited capacity, but has unlimited logical length. If a new element pushed leads to the vector exceeding its maximum capacity, an automatical [downsampling](https://en.wikipedia.org/wiki/Downsampling_(signal_processing)) by an integer factor of *M* will be performed. That is, keep only every *Mth* sample. `SampledVector` can be used to record metrics, such as training loss curve in machine learning.
## Installation
```julia
import Pkg; Pkg.add("SampledVectors")
```
## Sampling and Interpolation
There are 1 exported type, `SampledVector`, and 3 important methods, `push!`, `sampled` and `sampledindexes`.
```julia
using Plots
y = [cos(x^2/900) for x in 1:100]
plot(y, label="original curve")

using SampledVectors
vector = SampledVector{Float64}(20) #20 is the capacity (maximum number of stored elements)
for yy in y
    push!(vector, yy)
end
# For visualization purposes, `sampled(vector)` would be enough when the vector is set at proper capacity. 
# And it runs fast.
plot!(collect(sampledindexes(vector)), sampled(vector), color="gray", label="sampling points") 
scatter!(collect(sampledindexes(vector)), sampled(vector), color="gray", label=nothing)
# `collect(vector)` can be seen as an interpolation result, but its length may be very large.
@assert length(collect(vector)) == length(y)
plot!(collect(vector), linestyle=:dash, label="basic interpolation")

# We can also use the package `Interpolations` to get a better result.
using Interpolations
sx = 1:step(vector):length(vector)
sy = sampled(vector)[1:length(sx)] #The last point may be lost
itp_cubic = CubicSplineInterpolation(sx, sy, extrapolation_bc=Line())
plot!(1:100, itp_cubic.(1:100), linestyle=:dash, label="better interpolation")
plot!(legend = :bottomleft)
```
![sampling and interpolation](sampling_and_interpolation.svg)
## Filtering
If the original signal contains high frequency components, an anti-aliasing filter may be required.
```julia
using Plots
y = [cos(x^2/90000)+0.6cos(0.75x) for x in 1:1000]
plot(y, label="original curve")

using SampledVectors
vector = SampledVector{Float64}(200)
for yy in y
    push!(vector, yy)
end
# Aliasing occurs
plot!(collect(sampledindexes(vector)), sampled(vector), color="gray", label="sampled & unfiltered") 
scatter!(collect(sampledindexes(vector)), sampled(vector), color="gray", label=nothing)

using DSP
using OnlineStats
# In order to prevent aliasing, the original signal should be removed of its high-frequency components before pushed.
# Here, a moving window is used to implement an online filter.
kernel = digitalfilter(Lowpass(0.1), FIRWindow(hanning(25)))
window = MovingWindow(Float64, length(kernel))
fit!(window, repeat([0.], length(kernel))) #zero padding
vector2 = SampledVector{Float64}(200)
for yy in y
    fit!(window, yy)
    push!(vector2, kernel'value(window))
end
plot!(collect(sampledindexes(vector2)), sampled(vector2), color="orange", label="sampled & online filtered") 
scatter!(collect(sampledindexes(vector2)), sampled(vector2), color="orange", label=nothing)

# Let's plot the output of the offline filter for comparison.
plot!(filt(kernel, y), color="red", label="unsampled & filtered")
plot!(legend = :bottomleft)
```
![unfiltered vs filtered](unfiltered_vs_filtered.svg)
