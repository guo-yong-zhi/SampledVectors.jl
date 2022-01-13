# SampledVectors.jl
[![CI](https://github.com/guo-yong-zhi/SampledVectors.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/guo-yong-zhi/SampledVectors.jl/actions/workflows/ci.yml) [![CI-nightly](https://github.com/guo-yong-zhi/SampledVectors.jl/actions/workflows/ci-nightly.yml/badge.svg)](https://github.com/guo-yong-zhi/SampledVectors.jl/actions/workflows/ci-nightly.yml) [![codecov](https://codecov.io/gh/guo-yong-zhi/SampledVectors.jl/branch/main/graph/badge.svg?token=785ZNXGQKL)](https://codecov.io/gh/guo-yong-zhi/SampledVectors.jl)  
`SampledVector` is a vector of finite length, but can push elements into it infinitely. When you push in a new element and exceed the maximum length limit, it will be automatically downsampled. `SampledVector` can be used to record metrics, such as training loss curve in machine learning.
```julia
using Plots
y = [cos(x^2/900) for x in 1:100]
plot(y, label="original curve")

using SampledVectors
vector = SampledVector{Float64}(20) #20 is the actual maximum length in memory
for yy in y
    push!(vector, yy)
end
# For visualization purposes, it is generally enough to plot `sampled(vector)` with proper maximum length.
# And that approach would be very fast.
plot!(collect(sampledindexes(vector)), sampled(vector), color="gray", label="sampling points") 
scatter!(collect(sampledindexes(vector)), sampled(vector), color="gray", label=nothing)
# `collect(vector)` can be used as an interpolation result, but its length may be very large.
@assert length(collect(vector)) == length(y)
plot!(collect(vector), linestyle=:dash, label="basic interpolation")

# We can also use the package `Interpolations` to get a better interpolation result.
using Interpolations
sx = 1:step(vector):length(vector)
sy = sampled(vector)[1:length(sx)] #The last point may be lost
itp_cubic = CubicSplineInterpolation(sx, sy, extrapolation_bc=Line())
plot!(1:100, itp_cubic.(1:100), linestyle=:dash, label="better interpolation")
plot!(legend = :bottomleft)
```
![sampling and interpolation](sampling_and_interpolation.svg)
```julia
# If there are high frequency components in the original signal, an anti-aliasing filter may be helpful.
using Plots
y = [cos(x^2/90000)+0.6cos(0.75x) for x in 1:1000]
plot(y, label="original curve")

using SampledVectors
vector = SampledVector{Float64}(200)
for yy in y
    push!(vector, yy)
end
# Aliasing occurs
plot!(collect(sampledindexes(vector)), sampled(vector), color="gray", label="unfiltered") 
scatter!(collect(sampledindexes(vector)), sampled(vector), color="gray", label=nothing)

using DSP
# Set a half-band filter (lowpass filter at 0.5 HZ) for the internal downsampling by a factor 2.
# The filter can reduce the aliasing at the beginning of the curve, but the problem is not fundamentally solved.
filter = s->filt(digitalfilter(Lowpass(0.5), FIRWindow(hanning(9))), s)
vector2 = SampledVector{Float64}(200, filter=filter)
for yy in y
    push!(vector2, yy)
end
plot!(collect(sampledindexes(vector2)), sampled(vector2), color="orange", label="filtered") 
scatter!(collect(sampledindexes(vector2)), sampled(vector2), color="orange", label=nothing)
plot!(legend = :bottomleft)
```
![unfiltered vs filtered](unfiltered_vs_filtered.svg)
