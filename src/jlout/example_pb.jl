# syntax: proto3
using ProtoBuf
import ProtoBuf.meta

mutable struct BytesList <: ProtoType
    value::Base.Vector{Array{UInt8,1}}
    BytesList(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct BytesList

mutable struct FloatList <: ProtoType
    value::Base.Vector{Float32}
    FloatList(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct FloatList
const __pack_FloatList = Symbol[:value]
meta(t::Type{FloatList}) = meta(t, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, __pack_FloatList, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Int64List <: ProtoType
    value::Base.Vector{Int64}
    Int64List(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Int64List
const __pack_Int64List = Symbol[:value]
meta(t::Type{Int64List}) = meta(t, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, __pack_Int64List, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Feature <: ProtoType
    bytes_list::BytesList
    float_list::FloatList
    int64_list::Int64List
    Feature(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Feature
const __oneofs_Feature = Int[1,1,1]
const __oneof_names_Feature = [Symbol("kind")]
meta(t::Type{Feature}) = meta(t, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, __oneofs_Feature, __oneof_names_Feature, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Features_FeatureEntry <: ProtoType
    key::AbstractString
    value::Feature
    Features_FeatureEntry(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Features_FeatureEntry (mapentry)

mutable struct Features <: ProtoType
    feature::Base.Dict{AbstractString,Feature} # map entry
    Features(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Features

mutable struct Example <: ProtoType
    features::Features
    Example(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Example

mutable struct FeatureList <: ProtoType
    feature::Base.Vector{Feature}
    FeatureList(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct FeatureList

mutable struct FeatureLists_FeatureListEntry <: ProtoType
    key::AbstractString
    value::FeatureList
    FeatureLists_FeatureListEntry(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct FeatureLists_FeatureListEntry (mapentry)

mutable struct FeatureLists <: ProtoType
    feature_list::Base.Dict{AbstractString,FeatureList} # map entry
    FeatureLists(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct FeatureLists

mutable struct SequenceExample <: ProtoType
    context::Features
    feature_lists::FeatureLists
    SequenceExample(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct SequenceExample

export Example, SequenceExample, BytesList, FloatList, Int64List, Feature, Features_FeatureEntry, Features, FeatureList, FeatureLists_FeatureListEntry, FeatureLists
# mapentries: "FeatureLists_FeatureListEntry" => ("AbstractString", "FeatureList"), "Features_FeatureEntry" => ("AbstractString", "Feature")
