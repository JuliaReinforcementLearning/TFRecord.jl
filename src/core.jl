using CRC32c

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
function read_record(io::IOStream)
    n = read(io, sizeof(UInt64))
    masked_crc32_n = read(io, UInt32)
    crc32c(n) == unmask(masked_crc32_n) || error("record corrupted")

    data = read(io, reinterpret(UInt64, n)[])
    masked_crc32_data = read(io, UInt32)
    crc32c(data) == unmask(masked_crc32_data) || error("record corrupted")
    data
end