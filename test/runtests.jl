using SampledVectors
using Test

@testset "SampledVectors.jl" begin
    l = SampledVector{Int}(23)
    for i in 1:1234
        @test sampledindexes(l)|>collect == sampled(l)
        push!(l, i)
    end
    @test sampled(l) == [1, 65, 129, 193, 257, 321, 385, 449, 513, 577, 641, 705, 769, 833, 897, 961, 1025, 1089, 1153, 1217, 1234]
    
    l = SampledVector{Int}(BigInt(2))
    for i in 1:27
        push!(l, i)
    end
    @test sampled(l) == [1, 27]
    @test step(l) == 32
    
    l = SampledVector([1,2,3])
    for i in 4:7
        push!(l, i)
    end
    @test sampled(l) == [1, 5, 7]
    @test capacity(l) == 3

    capacity!(l, 5)
    @test capacity(l) == 5
    foreach(x->push!(l, x), 8:16)
    l2 = SampledVector{Int}(5)
    foreach(x->push!(l2, x), 1:16)
    @test sampled(l) == sampled(l2)
    @test sampledindexes(l)|>collect == sampled(l)
    @test step(l) == step(l2)
    capacity!(l, 4)
    @test capacity(l) == 4
    @test sampled(l) == [1, 9, 16]
    @test sampledindexes(l)|>collect == sampled(l)
end
