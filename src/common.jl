

Base.write(io::IO, ::MIME"text/plain", ::Void) = nothing
function Base.read(io::IO, ::MIME"text/plain", ::Type{Void})
    readline(io)
    return nothing
end

Base.write(io::IO, ::MIME"text/plain", i::Integer) = print(io, i)
Base.read{I<:Integer}(io::IO, ::MIME"text/plain", ::Type{I}) = parse(I, readline(io))
