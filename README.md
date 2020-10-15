# TFRecord

[![Build Status](https://travis-ci.com/JuliaReinforcementLearning/TFRecord.jl.svg?branch=master)](https://travis-ci.com/JuliaReinforcementLearning/TFRecord.jl)

## Usage

### Install

```julia
julia> ] add TFRecord
```

### Write TFRecord

```julia
using TFRecord

writer = TFRecordWriter("example.tfrecord")

for i in 1:10
    write(writer, Dict(
        "feature1" => rand(Bool),
        "feature2" => rand(1:5),
        "feature3" => rand(("cat", "dog", "chicken", "horse", "goat")),
        "feature4" => randn(Float32),
    ))
end

close(writer)
```

Here we write `10` observations into the file `example.tfrecord`. Internally each dictionary is converted into a `TFRecord.Example` first, which is a known prototype by TensorFlow. Note that the type of key must be `AbstractString` and the type of value can be one of the following types:

- `Bool`, `Int64`, `Float32`, `AbstractString`
- `Vector` of the above types

For customized data types, you need to convert it into `TFRecord.Example` first.

### Read TFRecord

```julia
reader = TFRecordReader("example.tfrecord")

for example in reader
    println(example)
end
```

For more fine-grained control, please read the doc:

```julia
julia> ? TFRecordReader

julia> ? TFRecordWriter
```
