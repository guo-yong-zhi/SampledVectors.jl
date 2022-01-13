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
end
