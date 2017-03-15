type Frame{S}
    entities::Vector{S}
    nentities::Int
end
function Frame{S}(entries::Vector{S})
    return Frame{S}(entries, length(entries))
end
function Frame{S}(::Type{S}, nentries::Int=100)
    entities = Array(S, nentries)
    return Frame{S}(entities, 0)
end

Base.show{S}(io::IO, frame::Frame{S}) = @printf(io, "Frame{%s}(%d entries)", string(S), length(frame))

capacity(frame::Frame) = length(frame.entities)
Base.length(frame::Frame) = frame.nentries
Base.getindex(frame::Frame, i::Int) = frame.entries[i]
function Base.findfirst(frame::Frame, id::ID)
    for entity_index in 1 : frame.nentities
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
Base.endof(frame::Frame) = frame.nentries
Base.in(frame::Frame, id::ID) = findfirst(frame, id) != 0
function Base.setindex!{S}(frame::Frame{S}, entry::S, i::Int)
    frame.entries[i] = entry
    return frame
end
function Base.empty!(frame::Frame)
    frame.nentries = 0
    return frame
end
function Base.deleteat!(frame::Frame, entity_index::Int)
    entity_index > 0 || throw(DomainError())

    for i in entity_index : frame.nentries - 1
        copy!(frame.entries[i], frame.entries[i+1])
    end
    frame.nentries -= 1
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
Base.next(frame::Frame, i::Int) = (frame.entries[i], i+1)
