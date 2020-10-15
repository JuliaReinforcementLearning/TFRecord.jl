export TFRecordReader, TFRecordWriter

using CRC32c
using Glob
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
    n = read(io, sizeof(UInt64))
    masked_crc32_n = read(io, UInt32)
    crc32c(n) == unmask(masked_crc32_n) || error("record corrupted")

    data = read(io, reinterpret(UInt64, n)[])
    masked_crc32_data = read(io, UInt32)
    crc32c(data) == unmask(masked_crc32_data) || error("record corrupted")
    data
end

#####
# TFRecordReader
#####

"""
    TFRecordReader(s;kwargs...)

# Keyword Arguments

- `compression_type=nothing`. No compression by default. Optional values are `:zlib` and `:gzip`.
- `bufsize=1024*1024`. Set the buffer size of internal `BufferedOutputStream`. The default value is `1M`. Suggested value is between `1M`~`100M`.
- `channel_size=1000`. The number of pre-fetched elements.

!!!note
    To enable reading records from multiple files concurrently, remember to set the number of threads correctly. (See [JULIA_NUM_THREADS](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_NUM_THREADS))

"""
struct TFRecordReader{T}
    ch::Channel
end

@forward TFRecordReader.ch Base.close, Base.iterate, Base.isopen, Base.take!

TFRecordReader(s::String;kwargs...) = TFRecordReader{Example}(identity, s;kwargs...)

function TFRecordReader{T}(f, s;compression=nothing,bufsize=1024*1024, channel_size=1000) where T
    chnl = Channel{T}(channel_size) do ch
        @threads for file_name in glob(s)
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
    TFRecordReader{T}(chnl)
end

#####
# TFRecordWriter
#####

struct TFRecordWriter{X<:IO}
    io::X
end

"""
    TFRecordWriter(s;compression=nothing, bufsize=1024*1024)

Supported `compression` methods are: `:gzip` or `:zlib`.
Default value is `nothing`, which means do not do compression.
`bufsize` is used to set the size of buffer used by an internal
`BufferedOutputStream`, the default value is `1M` (1024*1024).
You may want to change it to a larger value when writing large datasets,
for example `100M`.
"""
function TFRecordWriter(s::AbstractString;compression=nothing, bufsize=1024*1024)
    io = BufferedOutputStream(open(s, "w"), bufsize)
    if compression == :gzip
        io = GzipCompressorStream(io)
    elseif compression == :zlib
        io = ZlibCompressorStream(io)
    else
        isnothing(compression) || throw(ArgumentError("unsupported compression method: $compression"))
    end
    TFRecordWriter(io)
end

Base.close(w::TFRecordWriter) = close(w.io)

Base.write(w::TFRecordWriter, x) = write(w, convert(Example, x))

function Base.write(w::TFRecordWriter, x::Example)
    buff = IOBuffer()
    writeproto(buff, x)

    data_crc = mask(crc32c(seekstart(buff)))
    data = take!(seekstart(buff))
    n = length(data)

    buff = IOBuffer()
    write(buff, n)
    n_crc = mask(crc32c(seekstart(buff)))

    write(w.io, n)
    write(w.io, n_crc)
    write(w.io, data)
    write(w.io, data_crc)
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
