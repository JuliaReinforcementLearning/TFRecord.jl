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

n = 10
f1 = rand(Bool, n)
f2 = rand(1:5, n)
f3 = rand(("cat", "dog", "chicken", "horse", "goat"), n)
f4 = rand(Float32, n)

TFRecord.write(
    "example.tfrecord",
    (
        Dict(
            "feature1" => f1[i],
            "feature2" => f2[i],
            "feature3" => f3[i],
            "feature4" => f4[i],
        )
        for i in 1:n
    )
)
```

Here we write `10` observations into the file `example.tfrecord`. Internally each dictionary is converted into a `TFRecord.Example` first, which is a known prototype by TensorFlow. Note that the type of key must be `AbstractString` and the type of value can be one of the following types:

- `Bool`, `Int64`, `Float32`, `AbstractString`
- `Vector` of the above types

For customized data types, you need to convert it into `TFRecord.Example` first.

### Read TFRecord

```julia
for example in TFRecord.read("example.tfrecord")
    println(example)
end
```

For more fine-grained control, please read the doc:

```julia
julia> ? TFRecord.reade

julia> ? TFRecord.write
```
