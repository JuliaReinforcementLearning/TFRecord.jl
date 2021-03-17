module Datasets

export buffered_shuffle

using Random
using Base.Iterators
using ProgressMeter

#####
#  BufferedShuffle
#####

struct BufferedShuffle{T, R<:AbstractRNG} <: AbstractChannel{T}
    src::Channel{T}
    buffer::Vector{T}
    rng::R
end

function buffered_shuffle(src::Channel{T}, buffer_size;rng=Random.GLOBAL_RNG) where T
    buffer = Array{T}(undef, buffer_size)
    p = Progress(buffer_size)
    Threads.@threads for i in 1:buffer_size
        buffer[i] = take!(src)
        next!(p)
    end
    BufferedShuffle(src, buffer, rng)
end

Base.close(b::BufferedShuffle) = close(b.src)

function Base.take!(b::BufferedShuffle)
    if length(b.buffer) == 0
        throw(InvalidStateException("buffer is empty", :empty))
    else
        i = rand(b.rng, 1:length(b.buffer))
        res = b.buffer[i]
        if isopen(b.src)
            b.buffer[i] = popfirst!(b.src)
        else
            deleteat!(b.buffer, i)
        end
        res
    end
end

function Base.iterate(b::BufferedShuffle, state=nothing)
    try
        return (popfirst!(b), nothing)
    catch e
        if isa(e, InvalidStateException) && e.state === :empty
            return nothing
        else
            rethrow()
        end
    end
end

#####
# RingBuffer
#####

mutable struct RingBuffer{T} <: AbstractChannel{T}
    buffers::Channel{T}
    current::T
    results::Channel{T}
end

Base.close(b::RingBuffer) = close(b.buffers) # will propergate to b.results

function RingBuffer(f!, buffer::T; sz = Threads.nthreads(), taskref = nothing) where {T}
    buffers = Channel{T}(sz)
    for _ in 1:sz
        put!(buffers, deepcopy(buffer))
    end
    results = Channel{T}(sz, spawn = true, taskref = taskref) do ch
        Threads.@threads :static for x in buffers
            f!(x)
            put!(ch, x)
        end
    end
    RingBuffer(buffers, buffer, results)
end

function Base.take!(b::RingBuffer)
    put!(b.buffers, b.current)
    b.current = take!(b.results)
    b.current
end

include("rl_unplugged/rl_unplugged.jl")

end
