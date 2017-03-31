type Frame{E}
    entities::Vector{E} # NOTE: I tried StaticArrays; was not faster
    n::Int
end
function Frame{E}(arr::AbstractVector{E}, N::Int=length(arr))
    N ≥ length(arr) || error("capacity cannot be less than entitiy count! (N ≥ length(arr))")
    entities = convert(Vector{E}, arr)
    return Frame{E}(entities, N)
end
function Frame{E}(::Type{E}, N::Int=100)
    entities = Array(E, N)
    return Frame{E}(entities, 0)
end

Base.show{E}(io::IO, frame::Frame{E}) = @printf(io, "Frame{%s}(%d entities)", string(E), length(frame))

capacity(frame::Frame) = length(frame.entities)
Base.length(frame::Frame) = frame.n
Base.getindex(frame::Frame, i::Int) = frame.entities[i]

Base.endof(frame::Frame) = frame.n
function Base.setindex!{E}(frame::Frame{E}, entity::E, i::Int)
    frame.entities[i] = entity
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

Base.start(frame::Frame) = 1
Base.done(frame::Frame, i::Int) = i > length(frame)
Base.next(frame::Frame, i::Int) = (frame.entities[i], i+1)

function Base.copy!{E}(dest::Frame{E}, src::Frame{E})
    for i in 1 : src.n
        dest.entities[i] = src.entities[i]
    end
    dest.n = src.n
    return dest
end
Base.copy{E}(frame::Frame{E}) = copy!(Frame(E, capacity(frame)), frame)

function Base.push!{E}(frame::Frame{E}, entity::E)
    frame.n += 1
    frame.entities[frame.n] = entity
    return frame
end


####

typealias EntityFrame{S,D,I} Frame{Entity{S,D,I}}

Base.in{S,D,I}(frame::EntityFrame{S,D,I}, id::I) = findfirst(frame, id) != 0
function Base.findfirst{S,D,I}(frame::EntityFrame{S,D,I}, id::I)
    for entity_index in 1 : frame.n
        entity = frame.entities[entity_index]
        if entity.id == id
            return entity_index
        end
    end
    return 0
end
function get_by_id{S,D,I}(frame::EntityFrame{S,D,I}, id::I)
    entity_index = findfirst(frame, id)
    if entity_index == 0
        throw(BoundsError(frame, id))
    end
    return frame[entity_index]
end
function get_first_available_id{S,D,I}(frame::EntityFrame{S,D,I})
    ids = Set{I}(entity.id for entity in frame)
    id_one = one(I)
    id = id_one
    while id ∈ ids
        id += id_one
    end
    return id
end
function Base.push!{S,D,I}(frame::EntityFrame{S,D,I}, s::S)
    id = get_first_available_id(frame)
    entity = Entity{S,D,I}(s, D(), id)
    push!(frame, entity)
end

Base.delete!{S,D,I}(frame::EntityFrame{S,D,I}, entity::Entity{S,D,I}) = deleteat!(frame, findfirst(frame, entity.id))
function Base.delete!{S,D,I}(frame::EntityFrame{S,D,I}, id::I)
    entity_index = findfirst(frame, id)
    if entity_index != 0
        deleteat!(frame, entity_index)
    end
    return frame
end


