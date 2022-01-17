using SampledVectors
using Test

@testset "SampledVectors.jl" begin
    #basic
    l = SampledVector{Int}(23)
    for i in 1:1234
        @test sampledindexes(l)|>collect == sampled(l)
        push!(l, i)
    end
    @test sampled(l) == [1, 65, 129, 193, 257, 321, 385, 449, 513, 577, 641, 705, 769, 833, 897, 961, 1025, 1089, 1153, 1217, 1234]
    
    #empty!
    @test empty!(l) === l
    @test length(l) == 0
    @test collect(l) |> isempty
    @test step(l) == 1
    @test sampledindexes(l)|>collect |> isempty
    @test sampled(l)|>collect |> isempty

    # edge case: capacity=2
    l = SampledVector{Int}(BigInt(2))
    for i in 1:27
        push!(l, i)
    end
    @test sampled(l) == [1, 27]
    @test step(l) == 32
    
    # vector init
    l = SampledVector([1,2,3])
    for i in 4:7
        push!(l, i)
    end
    @test sampled(l) == [1, 5, 7]
    @test capacity(l) == 3

    #setcapacity!
    setcapacity!(l, 5) #larger 
    @test capacity(l) == 5
    foreach(x->push!(l, x), 8:16)
    l2 = SampledVector{Int}(5)
    foreach(x->push!(l2, x), 1:16)
    @test sampled(l) == sampled(l2)
    @test sampledindexes(l)|>collect == sampled(l)
    @test step(l) == step(l2)
    setcapacity!(l, 4) #smaller
    @test capacity(l) == 4
    @test sampled(l) == [1, 9, 16]
    @test sampledindexes(l)|>collect == sampled(l)
    push!(l, 17)
    push!(l, 18) #has remains; sampled(l) has even length
    @test sampled(l) == [1, 9, 17, 18]
    setcapacity!(l, 3)
    @test capacity(l) == 3
    @test sampled(l) == [1, 17, 18]
    @test sampledindexes(l)|>collect == sampled(l)
    setcapacity!(l, 2)
    @test capacity(l) == 2
    @test sampled(l) == [1, 18]
    @test sampledindexes(l)|>collect == sampled(l)

    #factor=3
    l = SampledVector{Int}(15, factor=3)
    for i in 1:48
        @test sampledindexes(l)|>collect == sampled(l)
        push!(l, i)
    end
    @test sampled(l) == [1, 10, 19, 28, 37, 46, 48]
    @test factor(l) == 3
    @test step(l) == 9

    #set factor
    setfactor!(l, 4)
    for i in 49:200
        @test sampledindexes(l)|>collect == sampled(l)
        push!(l, i)
    end
    @test sampled(l) == [1, 37, 73, 109, 145, 181, 200]
    @test factor(l) == 4
    @test step(l) == 4*9
end
