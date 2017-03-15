immutable RecordFrame
    lo::Int
    hi::Int
    t::Float64 # time
end
Base.length(frame::RecordFrame) = frame.hi - frame.lo + 1 # number of objects in the frame

immutable RecordState{S}
    id::ID
    state::S
end

type ListRecord{S,D} # State, Definition
    frames::Vector{RecordFrame}
    states::Vector{RecordState{S}}
    defs::Dict{ID, D}
end
ListRecord{S,D}(::Type{S}, ::Type{D}) = ListRecord(RecordFrame[], RecordState{S}[], Dict{ID,D}())

Base.show{S,D}(io::IO, rec::ListRecord{S,D}) = @printf(io, "ListRecord{%s, %s}(%d frames)", string(S), string(D), nframes(rec))

get_statetype{S,D}(rec::ListRecord{S,D}) = S
get_deftype{S,D}(rec::ListRecord{S,D}) = D

nframes(rec::ListRecord) = length(rec.frames)
frame_inbounds(rec::ListRecord, frame_index::Int) = 1 ≤ frame_index ≤ nframes(rec)
n_objects_in_frame(rec::ListRecord, frame_index::Int) = length(rec.frames[frame_index])

get_ids(rec::ListRecord) = collect(keys(rec.defs))
nth_id(rec::ListRecord, frame_index::Int, n::Int=1) = rec.states[rec.frames[frame_index].lo + n-1].id

get_time(rec::ListRecord, frame_index::Int) = rec.frames[frame_index].t
get_elapsed_time(rec::ListRecord, frame_lo::Int, frame_hi::Int) = rec.frames[frame_hi].t - rec.frames[frame_lo].t
get_mean_timestep(rec::ListRecord) = (rec.frames[end].t - rec.frames[1].t) / (nframes(rec)-1)

function findfirst_stateindex_with_id(rec::ListRecord, id::ID, frame_index::Int)
    recframe = rec.frames[frame_index]
    for i in recframe.lo : recframe.hi
        if rec.states[i].id == id
            return i
        end
    end
    return 0
end
function findfirst_frame_with_id(rec::ListRecord, id::ID)
    for frame in 1:length(rec.frames)
        if findfirst_stateindex_with_id(rec, id, frame) != -1
            return frame
        end
    end
    return 0
end
function findlast_frame_with_id(rec::ListRecord, id::Int)
    for frame in reverse(1:length(rec.frames))
        if findfirst_stateindex_with_id(rec, id, frame) != -1
            return frame
        end
    end
    return 0
end

Base.in(id::ID, rec::ListRecord, frame_index::Int) = findfirst_stateindex_with_id(rec, id, frame_index) != -1
get_state(rec::ListRecord, id::ID, frame_index::Int) = rec.states[findfirst_stateindex_with_id(rec, id, frame_index)].state
get_def(rec::ListRecord, id::ID) = rec.defs[id]
Base.get(rec::ListRecord, id::ID, frame_index::Int) = (get_state(rec, id, frame_index), get_def(rec,id))
function Base.get(rec::ListRecord, stateindex::Int)
    recstate = rec.states[stateindex]
    return (recstate.state, get_def(rec, recstate.id))
end

#################################

function Base.get!{T,S,D}(frame::Frame{T}, rec::ListRecord{S,D}, frame_index::Int)

    frame.nentries = 0

    if frame_inbounds(rec, frame_index)
        recframe = rec.frames[frame_index]
        for stateindex in recframe.lo : recframe.hi
            frame.nentries += 1
            frame.entries[frame.nentries] = convert(T, get(rec, stateindex))
        end
    end

    return frame
end
function Base.push!{S,D,T}(rec::ListRecord{S,D}, frame::Frame{T}, time::Float64)
    error("NOT YET IMPLEMENTED")
end

#################################

immutable ListRecordIterator{S,D}
    rec::ListRecord{S,D}
    id::ID
end
Base.length(iter::ListRecordIterator) = sum(frame->in(iter.id, iter.rec, frame), 1:nframes(iter.rec))
function Base.start(iter::ListRecordIterator)
    frame = 1
    while frame < nframes(iter.rec) &&
          !in(iter.id, iter.rec, frame)

        frame += 1
    end
    frame
end
Base.done(iter::ListRecordIterator, frame_index::Int) = frame_index > nframes(iter.rec)
function Base.next(iter::ListRecordIterator, frame_index::Int)
    item = (frame_index, get(iter.rec, iter.id, frame_index))
    frame_index += 1
    while frame_index < nframes(iter.rec) &&
          !in(iter.id, iter.rec, frame_index)

        frame_index += 1
    end
    (item, frame_index)
end