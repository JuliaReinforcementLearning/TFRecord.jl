using TFRecord
using Test

@testset "no compression" begin

    n = 10
    f1 = rand(Bool, n)
    f2 = rand(1:5, n)
    f3 = rand(("cat", "dog", "chicken", "horse", "goat"), n)
    f4 = rand(Float32, n)
    f5 = rand(Float32, n,5)

    TFRecord.write(
        "example.tfrecord",
        (
            Dict(
                "feature1" => f1[i],
                "feature2" => f2[i],
                "feature3" => f3[i],
                "feature4" => f4[i],
                "feature5" => f5[i,:]
            )
            for i in 1:n
        )
    )

    reader = TFRecord.read("example.tfrecord")

    for (i, example) in enumerate(reader)
        @assert example.features.feature["feature1"].kind.value.value[1] == Int(f1[i])
        @assert example.features.feature["feature2"].kind.value.value[1] == f2[i]
        @assert String(example.features.feature["feature3"].kind.value.value[1]) == f3[i]
        @assert example.features.feature["feature4"].kind.value.value[1] == f4[i]
        @assert all(example.features.feature["feature5"].kind.value.value .== f5[i,:])
    end
    sleep(1)
    rm("example.tfrecord")
end

@testset "gzip" begin

    n = 10
    f1 = rand(Bool, n)
    f2 = rand(1:5, n)
    f3 = rand(("cat", "dog", "chicken", "horse", "goat"), n)
    f4 = rand(Float32, n)
    f5 = rand(Float32, n,5)

    TFRecord.write(
        "example.tfrecord",
        (
            Dict(
                "feature1" => f1[i],
                "feature2" => f2[i],
                "feature3" => f3[i],
                "feature4" => f4[i],
                "feature5" => f5[i,:]
            )
            for i in 1:n
        ),
        compression=:gzip
    )

    reader = TFRecord.read("example.tfrecord", compression=:gzip)

    for (i, example) in enumerate(reader)
        @assert example.features.feature["feature1"].kind.value.value[1] == Int(f1[i])
        @assert example.features.feature["feature2"].kind.value.value[1] == f2[i]
        @assert String(example.features.feature["feature3"].kind.value.value[1]) == f3[i]
        @assert example.features.feature["feature4"].kind.value.value[1] == f4[i]
        @assert all(example.features.feature["feature5"].kind.value.value .== f5[i,:])
    end
    sleep(1)
    rm("example.tfrecord")
end

@testset "zlib" begin

    n = 10
    f1 = rand(Bool, n)
    f2 = rand(1:5, n)
    f3 = rand(("cat", "dog", "chicken", "horse", "goat"), n)
    f4 = rand(Float32, n)
    f5 = rand(Float32, n,5)

    TFRecord.write(
        "example.tfrecord",
        (
            Dict(
                "feature1" => f1[i],
                "feature2" => f2[i],
                "feature3" => f3[i],
                "feature4" => f4[i],
                "feature5" => f5[i,:]
            )
            for i in 1:n
        ),
        compression=:zlib
    )

    reader = TFRecord.read("example.tfrecord", compression=:zlib)

    for (i, example) in enumerate(reader)
        @assert example.features.feature["feature1"].kind.value.value[1] == Int(f1[i])
        @assert example.features.feature["feature2"].kind.value.value[1] == f2[i]
        @assert String(example.features.feature["feature3"].kind.value.value[1]) == f3[i]
        @assert example.features.feature["feature4"].kind.value.value[1] == f4[i]
        @assert all(example.features.feature["feature5"].kind.value.value .== f5[i,:])
    end
    sleep(1)
    rm("example.tfrecord")
end
