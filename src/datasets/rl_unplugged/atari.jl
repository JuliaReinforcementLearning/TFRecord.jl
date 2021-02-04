export atari_dataset

using Base.Threads
using Printf:@sprintf
using Base.Iterators
using TFRecord
using ImageCore
using PNGFiles

"""
f = example.features.feature
o.bytes_list.value
"""
struct RLTransition
    state
    action
    reward
    terminal
    next_state
    next_action
    episode_id
    episode_return
end

function batch!(dest::RLTransition, src)
    for (i, src) in enumerate(src)
        batch!(dest, src, i)
    end
end

function batch!(dest::RLTransition, src::RLTransition, i::Int)
    for fn in fieldnames(RLTransition)
        xs = getfield(dest, fn)
        x = getfield(src, fn)
        selectdim(xs, ndims(xs), i) .= x
    end
end

function decode_frame(bytes)
    bytes |> IOBuffer |> PNGFiles.load |> channelview |> rawview
end

function decode_state(bytes)
    PermutedDimsArray(StackedView((decode_frame(x) for x in bytes)...), (2,3,1))
end

function RLTransition(example::TFRecord.Example)
    f = example.features.feature
    s = decode_state(f["o_t"].bytes_list.value)
    s′ = decode_state(f["o_tp1"].bytes_list.value)
    a = f["a_t"].int64_list.value[]
    a′ = f["a_tp1"].int64_list.value[]
    r = f["r_t"].float_list.value[]
    t = f["d_t"].float_list.value[] != 1.0
    episode_id = f["episode_id"].int64_list.value[]
    episode_return = f["episode_return"].float_list.value[]
    RLTransition(s, a, r, t, s′, a′, episode_id, episode_return)
end

function atari_dataset(;
    dir,
    game = "Pong",
    run = 1,
    num_shards = 100,
    shuffle_buffer_size = 100_000,
    tf_reader_bufsize = 10*1024*1024,
    tf_reader_sz = 10_000,
    batch_size = 256,
    n_preallocations = nthreads() * 8
)
    n = nthreads()
    @info "Loading the $run run of atari game ($game) from dir: $dir with $(n) threads"

    files = [
        joinpath(dir, game, @sprintf("run_%i-%05i-of-%05i", run, i, num_shards))
        for i in 0:num_shards-1
    ]

    ch_files = Channel{String}(length(files)) do ch
        for f in cycle(files)
            put!(ch, f)
        end
    end

    shuffled_files = buffered_shuffle(ch_files, length(files))

    ch_src = Channel{RLTransition}(n * tf_reader_sz) do ch
        for fs in partition(shuffled_files, n)
            Threads.foreach(
                TFRecord.read(
                    RLTransition,
                    fs;
                    compression=:gzip,
                    bufsize=tf_reader_bufsize,
                    channel_size=tf_reader_sz,
                    record_type=RLTransition
                );
                schedule=Threads.StaticSchedule()
            ) do x
                put!(ch, x)
            end
        end
    end

    transitions = buffered_shuffle(
        ch_src,
        shuffle_buffer_size
    )

    buffer = RLTransition(
        Array{UInt8, 4}(undef, 84, 84, 4, batch_size),
        Array{Int, 1}(undef, batch_size),
        Array{Float32, 1}(undef, batch_size),
        Array{Bool, 1}(undef, batch_size),
        Array{UInt8, 4}(undef, 84, 84, 4, batch_size),
        Array{Int, 1}(undef, batch_size),
        Array{Int, 1}(undef, batch_size),
        Array{Float32, 1}(undef, batch_size),
    )

    taskref = Ref{Task}()
    res = RingBuffer(buffer;taskref=taskref, sz=n_preallocations) do buff
        Threads.@threads for i in 1:batch_size
            batch!(buff, popfirst!(transitions), i)
        end
    end
    bind(ch_src, taskref[])
    bind(ch_files, taskref[])
    res
end