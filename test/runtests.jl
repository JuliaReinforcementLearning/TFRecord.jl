using TFRecord
using Test

@testset "TFRecord.jl" begin

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

    reader = TFRecord.read("example.tfrecord")

    for (i, example) in enumerate(reader)
        @test example.features.feature["feature1"].int64_list.value[] == Int(f1[i])
        @test example.features.feature["feature2"].int64_list.value[] == f2[i]
        @test String(example.features.feature["feature3"].bytes_list.value[]) == f3[i]
        @test example.features.feature["feature4"].float_list.value[] == f4[i]
    end
end
