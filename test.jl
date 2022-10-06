# using ProtoBuf
using ProtoBuf
# protojl("test.proto", ".", ".")
#%%
using Pkg
ENV["JULIA_REVISE_POLL"]=1
using Revise
Pkg.activate(".")
using TFRecord
#%%
n = 10
f1 = rand(Bool, n)
f2 = rand(1:5, n)
f3 = rand(("cat", "dog", "chicken", "horse", "goat"), n)
f4 = rand(Float32, n)

@run TFRecord.write(
    "example.tfrecord",
    [
        Dict(
            "feature1" => f1[i],
            "feature2" => f2[i],
            "feature3" => f3[i],
            "feature4" => f4[i],
        )
        for i in 1:n
    ]
)

ex = convert(TFRecord.Example, Dict(
    "feature1" => f1[1],
    "feature2" => f2[1],
    "feature3" => f3[1],
    "feature4" => f4[1],
))

ex

# TFRecord.example_pb.Int64List <: 
TFRecord.example_pb.Int64List <: ProtoBuf.OneOf{<:Union{TFRecord.example_pb.BytesList, TFRecord.example_pb.FloatList, TFRecord.example_pb.Int64List}}

TFRecord.Feature(TFRecord.Int64List([1,2,3]))
ft = TFRecord.Feature(nothing)

struct MyMessage
    oneof_field::Union{Nothing,OneOf{<:Union{Int32,String}}}
 end

OneOf(:option1, 42).name

MyMessage(option1= 42)