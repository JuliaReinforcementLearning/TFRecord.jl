using CRC32c
using Base.Threads
using CodecZlib
using BufferedStreams
using MacroTools: @forward
using ProtoBuf
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
# TODO check
function read_record(io::IO)
    n = Base.read(io, sizeof(UInt64))
    masked_crc32_n = Base.read(io, UInt32)
    @assert crc32c(n) == unmask(masked_crc32_n) "record corrupted, did you set the correct compression?"

    data = Base.read(io, Int(reinterpret(UInt64, n)[]))  # !!! watch https://github.com/JuliaIO/TranscodingStreams.jl/pull/104
    masked_crc32_data = Base.read(io, UInt32)
    @assert crc32c(data) == unmask(masked_crc32_data) "record corrupted, did you set the correct compression?"
    return data
end

"""
    read(s::Union{String,Vector{String}};kwargs...)

Read tensorflow records from file(s).

# Keyword Arguments

- `compression=nothing`. No compression by default. Optional values are `:zlib` and `:gzip`.
- `bufsize=10*1024*1024`. Set the buffer size of internal `BufferedOutputStream`. The default value is `10M`. Suggested value is between `1M`~`100M`.
- `channel_size=1000`. The number of pre-fetched elements.
- `record_type=Example`, see https://github.com/JuliaReinforcementLearning/TFRecord.jl/pull/11

!!! note

    To enable reading records from multiple files concurrently, remember to set the number of threads correctly (See [JULIA_NUM_THREADS](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_NUM_THREADS)).
"""
function read(
    files;
    compression = nothing,
    bufsize = 10 * 1024 * 1024,
    channel_size = 1_000,
    record_type = Example,

)
    file_itr(file::AbstractString) = [file]
    file_itr(files) = files
    Channel{record_type}(channel_size) do ch
        @threads for file_name in file_itr(files)
            open(decompressor_stream(compression), file_name, "r") do io
                buffered_io = BufferedInputStream(io, bufsize)
                while !eof(buffered_io)
                    buff = IOBuffer(read_record(buffered_io)) 
                    d = ProtoDecoder(buff)
                    instance = decode(d, record_type)
                    put!(ch, instance)
                # close(buffered_io)
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
        buffered_io = BufferedOutputStream(io, bufsize)
        write(buffered_io, x)
        close(buffered_io)
    end
end

function write(io::IO, xs)
    for x in xs
        write(io, convert(Example, x))
    end
end


function write(io::IO, x::Example)
    buff = IOBuffer()
    e = ProtoEncoder(buff)
    encode(e, x)

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

Base.convert(::Type{Feature}, x::Int) = Feature(OneOf(:int64_list,Int64List([x])))
Base.convert(::Type{Feature}, x::Bool) = Feature(OneOf(:int64_list,Int64List([Int(x)])))
Base.convert(::Type{Feature}, x::Float32) = Feature(OneOf(:float_list,FloatList([x])))
Base.convert(::Type{Feature}, x::AbstractString) = Feature(OneOf(:bytes_list,BytesList([unsafe_wrap(Vector{UInt8}, x)])))

Base.convert(::Type{Feature}, x::Vector{Int}) = Feature(OneOf(:int64_list,Int64List(x)))
Base.convert(::Type{Feature}, x::Vector{Bool}) = Feature(OneOf(:int64_list,Int64List(convert(Vector{Int}, x))))
Base.convert(::Type{Feature}, x::Vector{Float32}) = Feature(OneOf(:float_list,FloatList(x)))
Base.convert(::Type{Feature}, x::Vector{<:AbstractString}) = Feature(OneOf(:bytes_list,BytesList([unsafe_wrap(Vector{UInt8}, s) for s in x])))
Base.convert(::Type{Feature}, x::Vector{Array{UInt8,1}}) = Feature(OneOf(:bytes_list,BytesList(x)))

Base.convert(::Type{Features}, x::Dict) = Features(Dict(k=>convert(Feature, v) for (k, v) in x))

function Base.convert(::Type{Example}, x::Dict)
    return Example(convert(Features, x))
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