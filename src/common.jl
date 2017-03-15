immutable ID
    id::Int64
end
Base.show(io::IO, id::ID) = @printf(io, "ID(%d)", id.id)
Base.convert(::Type{Int}, id::ID) = convert(Int, id.id)