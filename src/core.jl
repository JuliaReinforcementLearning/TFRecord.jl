using CRC32c
using Base.Threads
using CodecZlib
using BufferedStreams
using MacroTools: @forward

# Ref: https://github.com/tensorflow/tensorflow/blob/295ad2781683835be974faba0a191528d8079768/tensorflow/core/lib/hash/crc32c.h#L50-L59

const MASK_DELTA = 0xa282ead8

mask(crc::UInt32) = ((crc >> 15) | (crc << 17)) + MASK_DELTA

function unmask(masked_crc::UInt32)
    rot = masked_crc - MASK_DELTA
    ((rot >> 17) | (rot << 15))
end

"""

Ref: https://github.com/tensorflow/tensorflow/blob/295ad2781683835be974faba0a191528d8079768/tensorflow/core/lib/io/record_reader.cc#L164-L199

Each record is stored in the following format:

```
uint64 n
uint32 masked_crc32_of_n
byte   data[n]
uint32 masked_crc32_of_data
```
"""
function read_record(io::IO)
    n = Base.read(io, sizeof(UInt64))
    masked_crc32_n = Base.read(io, UInt32)
    crc32c(n) == unmask(masked_crc32_n) || error("record corrupted, did you set the correct compression?")

    data = Base.read(io, Int(reinterpret(UInt64, n)[]))  # !!! watch https://github.com/JuliaIO/TranscodingStreams.jl/pull/104
    masked_crc32_data = Base.read(io, UInt32)
    crc32c(data) == unmask(masked_crc32_data) || error("record corrupted, did you set the correct compression?")
    data
end

"""
    read([f=identity], s::Union{String,Vector{String}};kwargs...)

Read tensorflow records from file(s). 

# Keyword Arguments

- `compression=nothing`. No compression by default. Optional values are `:zlib` and `:gzip`.
- `bufsize=10*1024*1024`. Set the buffer size of internal `BufferedOutputStream`. The default value is `10M`. Suggested value is between `1M`~`100M`.
- `channel_size=1000`. The number of pre-fetched elements.
- `eltype=Example`. Change it to the type of result `f(::Example)` if `f` is provided.

!!! note

    To enable reading records from multiple files concurrently, remember to set the number of threads correctly (See [JULIA_NUM_THREADS](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_NUM_THREADS)).
"""
read(s::String; kw...) = read(identity, [s]; kw...)
read(fs::Vector; kw...) = read(identity, fs; kw...)
read(f, s::String; kwargs...) = read(f, [s]; kw...)

function read(
    f,
    files::Vector;
    compression=nothing,
    bufsize=10*1024*1024,
    channel_size=1_000,
    record_type=Example
)
    Channel{record_type}(channel_size) do ch
        @threads for file_name in files
            open(file_name, "r") do io

                io = BufferedInputStream(io, bufsize)
                if compression == :gzip
                    io = GzipDecompressorStream(io)
                elseif compression == :zlib
                    io = ZlibDecompressorStream(io)
                else
                    isnothing(compression) || throw(ArgumentError("unsupported compression method: $compression"))
                end

                while !eof(io)
                    example = readproto(IOBuffer(read_record(io)), Example())
                    put!(ch, f(example))
                end
            end
        end
    end
end

#####
# TFRecordWriter
#####

struct TFRecordWriter{X<:IO}
    io::X
end

"""
    write(file_name, xs;compression=nothing, bufsize=1024*1024)

`xs` is assumed to be an iterator. Its element must support converting to an `Example`.

Supported `compression` methods are: `:gzip` or `:zlib`.
Default value is `nothing`, which means do not do compression.
`bufsize` is used to set the size of buffer used by an internal
`BufferedOutputStream`, the default value is `1M` (1024*1024).
You may want to change it to a larger value when writing large datasets,
for example `100M`.
"""
function write(s::AbstractString, x;compression=nothing, bufsize=1024*1024)
    io = BufferedOutputStream(open(s, "w"), bufsize)
    if compression == :gzip
        io = GzipCompressorStream(io)
    elseif compression == :zlib
        io = ZlibCompressorStream(io)
    else
        isnothing(compression) || throw(ArgumentError("unsupported compression method: $compression"))
    end
    write(io, x)
    close(io)
end

function write(io::IO, xs)
    for x in xs
        write(io, convert(Example, x))
    end
end

function write(io::IO, x::Example)
    buff = IOBuffer()
    writeproto(buff, x)

    data_crc = mask(crc32c(seekstart(buff)))
    data = take!(seekstart(buff))
    n = length(data)

    buff = IOBuffer()
    Base.write(buff, n)
    n_crc = mask(crc32c(seekstart(buff)))

    Base.write(io, n)
    Base.write(io, n_crc)
    Base.write(io, data)
    Base.write(io, data_crc)
end

#####
# convert
#####

Base.convert(::Type{Feature}, x::Int) = Feature(;int64_list=Int64List(value=[x]))
Base.convert(::Type{Feature}, x::Bool) = Feature(;int64_list=Int64List(value=[Int(x)]))
Base.convert(::Type{Feature}, x::Float32) = Feature(;float_list=FloatList(value=[x]))
Base.convert(::Type{Feature}, x::AbstractString) = Feature(;bytes_list=BytesList(value=[unsafe_wrap(Vector{UInt8}, x)]))

Base.convert(::Type{Feature}, x::Vector{Int}) = Feature(;int64_list=Int64List(value=x))
Base.convert(::Type{Feature}, x::Vector{Bool}) = Feature(;int64_list=Int64List(value=convert(Vector{Int}, x)))
Base.convert(::Type{Feature}, x::Vector{Float32}) = Feature(;float_list=FloatList(value=x))
Base.convert(::Type{Feature}, x::Vector{<:AbstractString}) = Feature(;bytes_list=BytesList(value=[unsafe_wrap(Vector{UInt8}, s) for s in x]))
Base.convert(::Type{Feature}, x::Vector{Array{UInt8,1}}) = Feature(;bytes_list=BytesList(value=x))

Base.convert(::Type{Features}, x::Dict) = Features(;feature=Dict(k=>convert(Feature, v) for (k, v) in x))

function Base.convert(::Type{Example}, x::Dict)
    d = Example()
    d.features = convert(Features, x)
    d
end
