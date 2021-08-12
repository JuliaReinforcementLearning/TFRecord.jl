using CRC32c
using Base.Threads
using CodecZlib
using BufferedStreams
using MacroTools: @forward
using ProtoBuf: ProtoType
using TranscodingStreams: NoopStream

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
    read(s::Union{String,Vector{String}};kwargs...)

Read tensorflow records from file(s).

# Keyword Arguments

- `f=Example`. Changes the type of the elements in the channel to the type specified by `f` if provided.
- `compression=nothing`. No compression by default. Optional values are `:zlib` and `:gzip`.
- `bufsize=10*1024*1024`. Set the buffer size of internal `BufferedOutputStream`. The default value is `10M`. Suggested value is between `1M`~`100M`.
- `channel_size=1000`. The number of pre-fetched elements.
- `record_type=Example`. The type of value being read from the `file/files` that are provided.

!!! note

    To enable reading records from multiple files concurrently, remember to set the number of threads correctly (See [JULIA_NUM_THREADS](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_NUM_THREADS)).
"""
read(s; kw...) = read(s; kw...)

function read(
    files;
    f = Example,
    compression = nothing,
    bufsize = 10 * 1024 * 1024,
    channel_size = 1_000,
    record_type = Example,
)

    file_itr(file::AbstractString) = [file]
    file_itr(files) = files

    Channel{f}(channel_size) do ch
        @threads for file_name in file_itr(files)
            open(decompressor_stream(compression), file_name, "r") do io
                buffered_io = BufferedInputStream(io, bufsize)
                while !eof(buffered_io)
                    instance = readproto(IOBuffer(read_record(buffered_io)), record_type())
                    put!(ch, f(instance))
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
function write(s::AbstractString, x; compression=nothing, bufsize=1024*1024)
    open(compressor_stream(compression), s, "w") do io
        buffered_io = BufferedOutputStream(open(s, "w"), bufsize)
        write(buffered_io, x)
    end
end

function write(io::IO, xs)
    for x in xs
        write(io, convert(Example, x))
    end
end

function write(io::IO, x::ProtoType)
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

# (De)compression

function compressor_stream(compression)
    if isnothing(compression)
        NoopStream
    elseif compression === :gzip
        GzipCompressorStream
    elseif compression === :zlib
        ZlibCompressorStream
    else
        throw(ArgumentError("Unsupported compression method: $compression"))
    end
end

function decompressor_stream(compression)
    if isnothing(compression)
        NoopStream
    elseif compression === :gzip
        GzipDecompressorStream
    elseif compression === :zlib
        ZlibDecompressorStream
    else
        throw(ArgumentError("Unsupported decompression method: $compression"))
    end
end
