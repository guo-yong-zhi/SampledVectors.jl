module SampledVectors

export SampledVector, sampled, sampledindexes

mutable struct SampledVector{T, NT<:Integer} <: AbstractVector{T}
    vec::Vector{T}
    step::NT #sampling step
    length::NT #claimed length
    maxlength::NT #maximum actual length in memory
    filter
end

function SampledVector{T}(maxlength::NT, step=one(NT); filter=identity) where {T, NT<:Integer}
    @assert maxlength >= 2
    SampledVector(Vector{T}(), step, zero(NT), maxlength, filter)
end
function SampledVector(vec::AbstractVector, step=1, filter=identity)
    @assert length(vec) >= 2
    SampledVector(vec, step, length(vec)*step, length(vec), filter)
end
SampledVector(args...) = SampledVector(Vector(args...))

mapindex(l::SampledVector, ind::Integer) = ceil(typeof(ind), (ind-1)/l.step) + 1
Base.size(l::SampledVector) = (l.length,)
Base.getindex(l::SampledVector, i::Integer) = getindex(l.vec, mapindex(l, i))
Base.setindex!(l::SampledVector, v, i::Integer) = setindex!(l.vec, v, mapindex(l, i))
Base.step(l::SampledVector) = l.step

maxlength(l::SampledVector) = l.maxlength #max actual length in memory

function downsample!(l::SampledVector)
    l.vec = l.filter(l.vec)
    for i in 3:2:maxlength(l)
        l.vec[i÷2+1] = l.vec[i]
    end
    l.step *= 2
    resize!(l.vec, maxlength(l)÷2+1)
    return l
end

function Base.push!(l::SampledVector, item)
    ind = l.length + 1
    if mapindex(l, ind) > maxlength(l) #Excess capacity
        downsample!(l)
        return push!(l, item)
    else
        if mapindex(l, ind) > length(l.vec)
            push!(l.vec, item)
        else
            l[ind] = item
        end
        l.length += 1
        return l
    end
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
