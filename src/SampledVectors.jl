module SampledVectors

export SampledVector, sampled, sampledindexes, capacity, capacity!

mutable struct SampledVector{T, NT<:Integer} <: AbstractVector{T}
    vec::Vector{T}
    step::NT #sampling step
    length::NT #claimed length
    capacity::NT #maximum number of stored elements
end

function SampledVector{T}(capacity::NT, step=one(NT)) where {T, NT<:Integer}
    @assert capacity >= 2
    SampledVector(Vector{T}(), step, zero(NT), capacity)
end
function SampledVector(vec::AbstractVector, step=1)
    @assert length(vec) >= 2
    SampledVector(vec, step, length(vec)*step, length(vec))
end
SampledVector(args...) = SampledVector(Vector(args...))

mapindex(l::SampledVector, ind::Integer) = ceil(typeof(ind), (ind-1)/l.step) + 1
Base.size(l::SampledVector) = (l.length,)
Base.getindex(l::SampledVector, i::Integer) = getindex(l.vec, mapindex(l, i))
Base.setindex!(l::SampledVector, v, i::Integer) = setindex!(l.vec, v, mapindex(l, i))
Base.step(l::SampledVector) = l.step
capacity(l::SampledVector) = l.capacity #maximum number of stored elements
function capacity!(l::SampledVector, n)
    @assert n >= 2
    while length(l.vec) > n
        downsample!(l)
    end
    l.capacity = n
end
function downsample!(l::SampledVector)
    for i in 3:2:capacity(l)
        l.vec[i÷2+1] = l.vec[i]
    end
    l.step *= 2
    resize!(l.vec, (capacity(l)-1)÷2+1)
    return l
end

function Base.push!(l::SampledVector, item)
    ind = l.length + 1
    mi = mapindex(l, ind)
    if mi > capacity(l) #Excess capacity
        downsample!(l)
        push!(l.vec, item)
    elseif mi > length(l.vec)
        push!(l.vec, item)
    else
        l[ind] = item
    end
    l.length += 1
    return l
end

sampled(l::SampledVector) = l.vec
function sampledindexes(l::SampledVector)
    if (length(l)-1) % step(l) == 0
        return 1:step(l):length(l)
    else
        return Iterators.flatten((1:step(l):length(l), (length(l),)))
    end
end
end
