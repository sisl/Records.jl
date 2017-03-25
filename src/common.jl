immutable Entity{S,D,I} # state, definition, identification
    state::S
    def::D
    id::I
end

# overwrite one(I) for get_first_available_id



Base.write(io::IO, ::MIME"text/plain", ::Void) = nothing
function Base.read(io::IO, ::MIME"text/plain", ::Type{Void})
    readline(io)
    return nothing
end

Base.write(io::IO, ::MIME"text/plain", i::Integer) = print(io, i)
Base.read{I<:Integer}(io::IO, ::MIME"text/plain", ::Type{I}) = parse(I, readline(io))
