type Frame{S,N}
    entities::MVector{N,S}
    n::Int
end
function Frame{S}(arr::AbstractVector{S}, N::Int=length(arr))
    N ≥ length(arr) || error("capacity cannot be less than entitiy count! (N ≥ length(arr))")
    entities = convert(MVector{N,S}, arr)
    return Frame{S,N}(entities, N)
end
function Frame{S}(::Type{S}, N::Int=100)
    entities = MVector{N,S}()
    return Frame{S,N}(entities, 0)
end

Base.show{S}(io::IO, frame::Frame{S}) = @printf(io, "Frame{%s}(%d entities)", string(S), length(frame))

capacity(frame::Frame) = length(frame.entities)
Base.length(frame::Frame) = frame.n
Base.getindex(frame::Frame, i::Int) = frame.entities[i]
function Base.findfirst(frame::Frame, id::ID)
    for entity_index in 1 : frame.n
        entity = frame.entities[entity_index]
        if get_id(entity) == id
            return entity_index
        end
    end
    return 0
end
function Base.getindex(frame::Frame, id::ID)
    entity_index = findfirst(frame, id)
    if entity_index == 0
        throw(BoundsError(frame, id))
    end
    return frame[entity_index]
end
Base.endof(frame::Frame) = frame.n
Base.in(frame::Frame, id::ID) = findfirst(frame, id) != 0
function Base.setindex!{S}(frame::Frame{S}, entry::S, i::Int)
    frame.entities[i] = entry
    return frame
end
function Base.empty!(frame::Frame)
    frame.n = 0
    return frame
end
function Base.deleteat!(frame::Frame, entity_index::Int)
    entity_index > 0 || throw(DomainError())

    for i in entity_index : frame.n - 1
        frame.entities[i] = frame.entities[i+1]
    end
    frame.n -= 1
    frame
end
Base.delete!{S}(frame::Frame{S}, entry::S) = deleteat!(frame, get_index_of_first_vehicle_with_id(frame, veh.def.id))
function Base.delete!(frame::Frame, id::ID)
    entity_index = findfirst(frame, id)
    if entity_index != 0
        deleteat!(frame, entity_index)
    end
    return frame
end

Base.start(frame::Frame) = 1
Base.done(frame::Frame, i::Int) = i > length(frame)
Base.next(frame::Frame, i::Int) = (frame.entities[i], i+1)

function Base.copy!{S}(dest::Frame{S}, src::Frame{S})
    for i in 1 : src.n
        dest.entities[i] = src.entities[i]
    end
    dest.n = src.n
    return dest
end
Base.copy{S}(frame::Frame{S}) = copy!(Frame(S, capacity(frame)), frame)

function Base.push!{S}(frame::Frame{S}, entity::S)
    frame.n += 1
    frame.entities[frame.n] = entity
    return frame
end

function get_first_available_id(frame::Frame)
    ids = Set{ID}([get_id(entity) for entity in frame])
    id = ID(1)
    while id ∈ ids
        id = ID(id.id + 1)
    end
    return id
end


