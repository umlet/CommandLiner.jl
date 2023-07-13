#!/usr/bin/env julia


# for now, call with:
# julia --project=. src/_test.jl


using Test
using Base.Iterators
using OrderedCollections


include("CommandLiner.jl")
using .CommandLiner




# helpers
addone(x) = x + 1
struct IntWrapper  i::Int64  end



@testset "Str" begin
    @test iscomment("#abc") == true

    @test splitind1("abcd", 3) == "ab"
    @test splitind2("abcd", 3) == "d"
    
    @test jn("abc", "x") == "axbxc"
    @test ["ab", "cd"] |> jn("x") == "abxcd"

    @test ext("f.txt") == "txt"  # TODO move to Filesys
    @test ext("f.") == ""
    @test ext(".conf") === nothing
    @test ext(".") === nothing
end


@testset "Iter" begin
    @test fl(isodd, [1, 2, 3]) == [1, 3]
    @test [1, 2, 3] |> fl(isodd) == [1, 3]
    @test [1,2] |> fl_(()->true) != [1,2]

    @test [1,2] |> mp(IntWrapper) |> second == IntWrapper(2)

    @test tk([1,2,3], 2) == [1,2]
    @test [1,2,3] |> tk(2) == [1,2]
    @test [1,1,1,1,1,  1,1,1,1,1, 1,1] |> tk == [1,1,1,1,1, 1,1,1,1,1]

    @test [1,2,3,4] |> cn(x->x>=3) == 2

    @test [1,2,3,"kjh"] |> fl(is(Int64)) |> length == 3

    @test Dict(1=>3, 2=>9) |> flbyval(x->x==9) |> is(AbstractDict) == true

    @test OrderedDict(1=>9, 2=>3) |> sortbyval |> first == (2=>3)

    @test (1,2,3) |> second == 2
    @test [1,2,3] |> second == 2
    @test 1:3 |> second == 2
end


@testset "Exe" begin
    @test exe("ls").outs |> length > -1
    @test exebash("ls -a").outs |> fl(==("..")) |> length == 1
end


@testset "Group" begin
    @test group([1,2,2,5,5,5];  freduce=length, Treduce=Int64, fhaving=x->x<=2) |> values |> sum == 3
end


@testset "Convert" begin
    @test isint("1") == true
    @test isint("1.1") == false

    @test 1.22 |> tostr2 == "1.22"
end