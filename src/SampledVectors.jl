module SampledVectors

export SampledVector, sampled, sampledindexes, capacity, setcapacity!, factor, setfactor!, downsample!

mutable struct SampledVector{T, ST<:Integer, LT<:Integer, CT<:Integer, FT<:Integer} <: AbstractVector{T}
    vec::Vector{T}
    step::ST #sampling step
    length::LT #claimed length
    capacity::CT #maximum number of stored elements
    factor::FT #factor that decrease the sample rate by 
end

function SampledVector{T}(capacity::CT; step=one(CT), length=zero(CT), factor=2one(CT)) where {T, CT<:Integer}
    @assert capacity >= 2
    @assert factor >= 2
    vec = Vector{T}()
    sizehint!(vec, capacity)
    SampledVector(vec, step, length, capacity, factor)
end
function SampledVector(vec::AbstractVector; step=1, capacity=length(vec), length=capacity*step, factor=2)
    @assert capacity >= 2
    @assert factor >= 2
    SampledVector(vec, step, length, capacity, factor)
end
SampledVector(args...; kargs...) = SampledVector(Vector(args...); kargs...)

mapindex(l::SampledVector, ind::Integer) = ceil(typeof(ind), (ind-1)/l.step) + 1
Base.size(l::SampledVector) = (l.length,)
Base.getindex(l::SampledVector, i::Integer) = getindex(l.vec, mapindex(l, i))
Base.setindex!(l::SampledVector, v, i::Integer) = setindex!(l.vec, v, mapindex(l, i))
Base.step(l::SampledVector) = l.step
function Base.empty!(l::SampledVector)
    empty!(l.vec)
    l.step = 1
    l.length = 0
    l
end
capacity(l::SampledVector) = l.capacity
function setcapacity!(l::SampledVector, n)
    @assert n >= 2
    while length(l.vec) > n
        downsample!(l)
    end
    sizehint!(l.vec, n)
    l.capacity = n
end
factor(l::SampledVector) = l.factor
function setfactor!(l::SampledVector, n)
    @assert n >= 2
    l.factor = n
end
function downsample!(l::SampledVector, factor=l.factor, truncate=false)
    lv = length(l.vec)
    for i in (1+factor):factor:lv
        l.vec[i÷factor+1] = l.vec[i] #i÷factor+1 == (i-1)÷factor+1 when factor >= 2
    end
    l.step *= factor
    last = l.vec[end]
    resize!(l.vec, (lv-1)÷factor+1)
    # @assert length(l.vec) < capacity(l)
    if !truncate && (lv-1) % factor != 0
        push!(l.vec, last)
    end
    return l
end

function Base.push!(l::SampledVector, item)
    ind = l.length + 1
    mi = mapindex(l, ind)
    if mi > capacity(l) #Excess capacity
        downsample!(l, l.factor, true)
        push!(l.vec, item) #if truncated, there always be a blank
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
