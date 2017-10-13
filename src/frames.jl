mutable struct Frame{E}
    entities::Vector{E} # NOTE: I tried StaticArrays; was not faster
    n::Int
end
function Frame{E}(arr::AbstractVector{E}; capacity::Int=length(arr))
    capacity ≥ length(arr) || error("capacity cannot be less than entitiy count! (N ≥ length(arr))")
    entities = Array{E}(capacity)
    copy!(entities, arr)
    return Frame{E}(entities, length(arr))
end
function Frame{E}(::Type{E}, capacity::Int=100)
    entities = Array{E}(capacity)
    return Frame{E}(entities, 0)
end

Base.show{E}(io::IO, frame::Frame{E}) = @printf(io, "Frame{%s}(%d entities)", string(E), length(frame))

capacity(frame::Frame) = length(frame.entities)
Base.length(frame::Frame) = frame.n
Base.getindex(frame::Frame, i::Int) = frame.entities[i]
Base.eltype{E}(frame::Frame{E}) = E

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

const EntityFrame{S,D,I} = Frame{Entity{S,D,I}}
EntityFrame{S,D,I}(::Type{S},::Type{D},::Type{I}) = Frame(Entity{S,D,I})
EntityFrame{S,D,I}(::Type{S},::Type{D},::Type{I},N::Int) = Frame(Entity{S,D,I}, N)

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
function id2index{S,D,I}(frame::EntityFrame{S,D,I}, id::I)
    entity_index = findfirst(frame, id)
    if entity_index == 0
        throw(BoundsError(frame, id))
    end
    return entity_index
end
get_by_id{S,D,I}(frame::EntityFrame{S,D,I}, id::I) = frame[id2index(frame, id)]
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

###

function Base.write{S,D,I}(io::IO, mime::MIME"text/plain", frames::Vector{EntityFrame{S,D,I}})
    println(io, length(frames))
    for frame in frames
        println(io, length(frame))
        for entity in frame
            write(io, mime, entity.state)
            print(io, "\n")
            write(io, mime, entity.def)
            print(io, "\n")
            write(io, mime, entity.id)
            print(io, "\n")
        end
    end
end
function Base.read{S,D,I}(io::IO, mime::MIME"text/plain", ::Type{Vector{EntityFrame{S,D,I}}})

    n = parse(Int, readline(io))
    frames = Array{EntityFrame{S,D,I}}(n)

    for i in 1 : n
        m = parse(Int, readline(io))
        frame = Frame(Entity{S,D,I}, m)
        for j in 1 : m
            state = read(io, mime, S)
            def = read(io, mime, D)
            id = read(io, mime, I)
            push!(frame, Entity(state,def,id))
        end
        frames[i] = frame
    end

    return frames
end