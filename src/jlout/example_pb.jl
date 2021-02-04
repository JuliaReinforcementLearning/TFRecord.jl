# syntax: proto3
using ProtoBuf
import ProtoBuf.meta

mutable struct BytesList <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function BytesList(; kwargs...)
        obj = new(meta(BytesList), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct BytesList
const __meta_BytesList = Ref{ProtoMeta}()
function meta(::Type{BytesList})
    ProtoBuf.metalock() do
        if !isassigned(__meta_BytesList)
            __meta_BytesList[] = target = ProtoMeta(BytesList)
            allflds = Pair{Symbol,Union{Type,String}}[:value => Base.Vector{Array{UInt8,1}}]
            meta(target, BytesList, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_BytesList[]
    end
end
function Base.getproperty(obj::BytesList, name::Symbol)
    if name === :value
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Array{UInt8,1}}
    else
        getfield(obj, name)
    end
end

mutable struct FloatList <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function FloatList(; kwargs...)
        obj = new(meta(FloatList), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct FloatList
const __meta_FloatList = Ref{ProtoMeta}()
function meta(::Type{FloatList})
    ProtoBuf.metalock() do
        if !isassigned(__meta_FloatList)
            __meta_FloatList[] = target = ProtoMeta(FloatList)
            pack = Symbol[:value]
            allflds = Pair{Symbol,Union{Type,String}}[:value => Base.Vector{Float32}]
            meta(target, FloatList, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, pack, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_FloatList[]
    end
end
function Base.getproperty(obj::FloatList, name::Symbol)
    if name === :value
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Float32}
    else
        getfield(obj, name)
    end
end

mutable struct Int64List <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Int64List(; kwargs...)
        obj = new(meta(Int64List), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct Int64List
const __meta_Int64List = Ref{ProtoMeta}()
function meta(::Type{Int64List})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Int64List)
            __meta_Int64List[] = target = ProtoMeta(Int64List)
            pack = Symbol[:value]
            allflds = Pair{Symbol,Union{Type,String}}[:value => Base.Vector{Int64}]
            meta(target, Int64List, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, pack, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_Int64List[]
    end
end
function Base.getproperty(obj::Int64List, name::Symbol)
    if name === :value
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Int64}
    else
        getfield(obj, name)
    end
end

mutable struct Feature <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Feature(; kwargs...)
        obj = new(meta(Feature), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct Feature
const __meta_Feature = Ref{ProtoMeta}()
function meta(::Type{Feature})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Feature)
            __meta_Feature[] = target = ProtoMeta(Feature)
            allflds = Pair{Symbol,Union{Type,String}}[:bytes_list => BytesList, :float_list => FloatList, :int64_list => Int64List]
            oneofs = Int[1,1,1]
            oneof_names = Symbol[Symbol("kind")]
            meta(target, Feature, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, oneofs, oneof_names)
        end
        __meta_Feature[]
    end
end
function Base.getproperty(obj::Feature, name::Symbol)
    if name === :bytes_list
        return (obj.__protobuf_jl_internal_values[name])::BytesList
    elseif name === :float_list
        return (obj.__protobuf_jl_internal_values[name])::FloatList
    elseif name === :int64_list
        return (obj.__protobuf_jl_internal_values[name])::Int64List
    else
        getfield(obj, name)
    end
end

mutable struct Features_FeatureEntry <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Features_FeatureEntry(; kwargs...)
        obj = new(meta(Features_FeatureEntry), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct Features_FeatureEntry (mapentry)
const __meta_Features_FeatureEntry = Ref{ProtoMeta}()
function meta(::Type{Features_FeatureEntry})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Features_FeatureEntry)
            __meta_Features_FeatureEntry[] = target = ProtoMeta(Features_FeatureEntry)
            allflds = Pair{Symbol,Union{Type,String}}[:key => AbstractString, :value => Feature]
            meta(target, Features_FeatureEntry, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_Features_FeatureEntry[]
    end
end
function Base.getproperty(obj::Features_FeatureEntry, name::Symbol)
    if name === :key
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :value
        return (obj.__protobuf_jl_internal_values[name])::Feature
    else
        getfield(obj, name)
    end
end

mutable struct Features <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Features(; kwargs...)
        obj = new(meta(Features), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct Features
const __meta_Features = Ref{ProtoMeta}()
function meta(::Type{Features})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Features)
            __meta_Features[] = target = ProtoMeta(Features)
            allflds = Pair{Symbol,Union{Type,String}}[:feature => Base.Dict{AbstractString,Feature}]
            meta(target, Features, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_Features[]
    end
end
function Base.getproperty(obj::Features, name::Symbol)
    if name === :feature
        return (obj.__protobuf_jl_internal_values[name])::Base.Dict{AbstractString,Feature}
    else
        getfield(obj, name)
    end
end

mutable struct Example <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Example(; kwargs...)
        obj = new(meta(Example), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct Example
const __meta_Example = Ref{ProtoMeta}()
function meta(::Type{Example})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Example)
            __meta_Example[] = target = ProtoMeta(Example)
            allflds = Pair{Symbol,Union{Type,String}}[:features => Features]
            meta(target, Example, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_Example[]
    end
end
function Base.getproperty(obj::Example, name::Symbol)
    if name === :features
        return (obj.__protobuf_jl_internal_values[name])::Features
    else
        getfield(obj, name)
    end
end

mutable struct FeatureList <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function FeatureList(; kwargs...)
        obj = new(meta(FeatureList), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct FeatureList
const __meta_FeatureList = Ref{ProtoMeta}()
function meta(::Type{FeatureList})
    ProtoBuf.metalock() do
        if !isassigned(__meta_FeatureList)
            __meta_FeatureList[] = target = ProtoMeta(FeatureList)
            allflds = Pair{Symbol,Union{Type,String}}[:feature => Base.Vector{Feature}]
            meta(target, FeatureList, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_FeatureList[]
    end
end
function Base.getproperty(obj::FeatureList, name::Symbol)
    if name === :feature
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Feature}
    else
        getfield(obj, name)
    end
end

mutable struct FeatureLists_FeatureListEntry <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function FeatureLists_FeatureListEntry(; kwargs...)
        obj = new(meta(FeatureLists_FeatureListEntry), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct FeatureLists_FeatureListEntry (mapentry)
const __meta_FeatureLists_FeatureListEntry = Ref{ProtoMeta}()
function meta(::Type{FeatureLists_FeatureListEntry})
    ProtoBuf.metalock() do
        if !isassigned(__meta_FeatureLists_FeatureListEntry)
            __meta_FeatureLists_FeatureListEntry[] = target = ProtoMeta(FeatureLists_FeatureListEntry)
            allflds = Pair{Symbol,Union{Type,String}}[:key => AbstractString, :value => FeatureList]
            meta(target, FeatureLists_FeatureListEntry, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_FeatureLists_FeatureListEntry[]
    end
end
function Base.getproperty(obj::FeatureLists_FeatureListEntry, name::Symbol)
    if name === :key
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :value
        return (obj.__protobuf_jl_internal_values[name])::FeatureList
    else
        getfield(obj, name)
    end
end

mutable struct FeatureLists <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function FeatureLists(; kwargs...)
        obj = new(meta(FeatureLists), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct FeatureLists
const __meta_FeatureLists = Ref{ProtoMeta}()
function meta(::Type{FeatureLists})
    ProtoBuf.metalock() do
        if !isassigned(__meta_FeatureLists)
            __meta_FeatureLists[] = target = ProtoMeta(FeatureLists)
            allflds = Pair{Symbol,Union{Type,String}}[:feature_list => Base.Dict{AbstractString,FeatureList}]
            meta(target, FeatureLists, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_FeatureLists[]
    end
end
function Base.getproperty(obj::FeatureLists, name::Symbol)
    if name === :feature_list
        return (obj.__protobuf_jl_internal_values[name])::Base.Dict{AbstractString,FeatureList}
    else
        getfield(obj, name)
    end
end

mutable struct SequenceExample <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function SequenceExample(; kwargs...)
        obj = new(meta(SequenceExample), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
        end
        obj
    end
end # mutable struct SequenceExample
const __meta_SequenceExample = Ref{ProtoMeta}()
function meta(::Type{SequenceExample})
    ProtoBuf.metalock() do
        if !isassigned(__meta_SequenceExample)
            __meta_SequenceExample[] = target = ProtoMeta(SequenceExample)
            allflds = Pair{Symbol,Union{Type,String}}[:context => Features, :feature_lists => FeatureLists]
            meta(target, SequenceExample, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_SequenceExample[]
    end
end
function Base.getproperty(obj::SequenceExample, name::Symbol)
    if name === :context
        return (obj.__protobuf_jl_internal_values[name])::Features
    elseif name === :feature_lists
        return (obj.__protobuf_jl_internal_values[name])::FeatureLists
    else
        getfield(obj, name)
    end
end

export Example, SequenceExample, BytesList, FloatList, Int64List, Feature, Features_FeatureEntry, Features, FeatureList, FeatureLists_FeatureListEntry, FeatureLists
# mapentries: "FeatureLists_FeatureListEntry" => ("AbstractString", "FeatureList"), "Features_FeatureEntry" => ("AbstractString", "Feature")
