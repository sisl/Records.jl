immutable RecordFrame
    lo::Int
    hi::Int
end
Base.length(recframe::RecordFrame) = recframe.hi - recframe.lo + 1 # number of objects in the frame
Base.write(io::IO, ::MIME"text/plain", recframe::RecordFrame) = @printf(io, "%d %d", recframe.lo, recframe.hi)
function Base.read(io::IO, ::MIME"text/plain", ::Type{RecordFrame})
    tokens = split(strip(readline(io)), ' ')
    lo = parse(Int, tokens[1])
    hi = parse(Int, tokens[2])
    return RecordFrame(lo, hi)
end

immutable RecordState{S,I}
    state::S
    id::I
end

type ListRecord{S,D,I} # State, Definition, Identification
    timestep::Float64
    frames::Vector{RecordFrame}
    states::Vector{RecordState{S}}
    defs::Dict{I, D}
end
ListRecord{S,D,I}(timestep::Float64, ::Type{S}, ::Type{D}, ::Type{I}=Int) = ListRecord(timestep, RecordFrame[], RecordState{S}[], Dict{I,D}())

Base.show{S,D,I}(io::IO, rec::ListRecord{S,D,I}) = @printf(io, "ListRecord{%s, %s, %s}(%d frames)", string(S), string(D), string(I), nframes(rec))
function Base.write(io::IO, ::MIME"text/plain", rec::ListRecord)
    textmime = MIME"text/plain"()

    show(io, rec)
    print(io, "\n")
    @printf(io, "%.16e\n", rec.timestep)

    # defs
    println(io, length(rec.defs))
    for (id,def) in rec.defs
        write(io, textmime, id)
        print(io, "\n")
        write(io, textmime, def)
        print(io, "\n")
    end

    # ids & states
    println(io, length(rec.states))
    for recstate in rec.states
        write(io, textmime, recstate.id)
        print(io, "\n")
        write(io, textmime, recstate.state)
        print(io, "\n")
    end

    # frames
    println(io, nframes(rec))
    for recframe in rec.frames
        write(io, textmime, recframe)
        print(io, "\n")
    end
end
function Base.read{S,D,I}(io::IO, ::MIME"text/plain", ::Type{ListRecord{S,D,I}})
    readline(io) # skip first line

    textmime = MIME"text/plain"()

    timestep = parse(Float64, readline(io))

    n = parse(Int, readline(io))
    defs = Dict{I,D}()
    for i in 1 : n
        id = read(io, textmime, I)
        defs[id] = read(io, textmime, D)
    end

    n = parse(Int, readline(io))
    states = Array(RecordState{S,I}, n)
    for i in 1 : n
        id = read(io, textmime, I)
        state = read(io, textmime, S)
        states[i] = RecordState{S,I}(state, id)
    end

    n = parse(Int, readline(io))
    frames = Array(RecordFrame, n)
    for i in 1 : n
        frames[i] = read(io, textmime, RecordFrame)
    end

    return ListRecord{S,D,I}(timestep, frames, states, defs)
end


get_statetype{S,D,I}(rec::ListRecord{S,D,I}) = S
get_deftype{S,D,I}(rec::ListRecord{S,D,I}) = D
get_idtype{S,D,I}(rec::ListRecord{S,D,I}) = I

nframes(rec::ListRecord) = length(rec.frames)
nstates(rec::ListRecord) = length(rec.states)
nids(rec::ListRecord) = length(keys(rec.defs))

frame_inbounds(rec::ListRecord, frame_index::Int) = 1 ≤ frame_index ≤ nframes(rec)
n_objects_in_frame(rec::ListRecord, frame_index::Int) = length(rec.frames[frame_index])

get_ids(rec::ListRecord) = collect(keys(rec.defs))
nth_id(rec::ListRecord, frame_index::Int, n::Int=1) = rec.states[rec.frames[frame_index].lo + n-1].id

get_time(rec::ListRecord, frame_index::Int) = rec.timestep * (frame_index-1)
get_timestep(rec::ListRecord) = rec.timestep
get_elapsed_time(rec::ListRecord, frame_lo::Int, frame_hi::Int) = rec.timestep * (frame_hi - frame_lo)

function findfirst_stateindex_with_id{S,D,I}(rec::ListRecord{S,D,I}, id::I, frame_index::Int)
    recframe = rec.frames[frame_index]
    for i in recframe.lo : recframe.hi
        if rec.states[i].id == id
            return i
        end
    end
    return 0
end
function findfirst_frame_with_id{S,D,I}(rec::ListRecord{S,D,I}, id::I)
    for frame in 1:length(rec.frames)
        if findfirst_stateindex_with_id(rec, id, frame) != -1
            return frame
        end
    end
    return 0
end
function findlast_frame_with_id{S,D,I}(rec::ListRecord{S,D,I}, id::Int)
    for frame in reverse(1:length(rec.frames))
        if findfirst_stateindex_with_id(rec, id, frame) != -1
            return frame
        end
    end
    return 0
end

Base.in{S,D,I}(id::I, rec::ListRecord{S,D,I}, frame_index::Int) = findfirst_stateindex_with_id(rec, id, frame_index) != -1
get_state{S,D,I}(rec::ListRecord{S,D,I}, id::I, frame_index::Int) = rec.states[findfirst_stateindex_with_id(rec, id, frame_index)].state
get_def{S,D,I}(rec::ListRecord{S,D,I}, id::I) = rec.defs[id]
Base.get{S,D,I}(rec::ListRecord{S,D,I}, id::I, frame_index::Int) = (get_state(rec, id, frame_index), get_def(rec,id))
function Base.get(rec::ListRecord, stateindex::Int)
    recstate = rec.states[stateindex]
    return (recstate.state, get_def(rec, recstate.id))
end

#################################

function Base.get!{T,S,D,I}(frame::Frame{T}, rec::ListRecord{S,D,I}, frame_index::Int)

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
function Base.push!{S,D,T,I}(rec::ListRecord{S,D,I}, frame::Frame{T}, time::Float64)
    error("NOT YET IMPLEMENTED")
end

#################################

immutable ListRecordIterator{S,D,I}
    rec::ListRecord{S,D,I}
    id::I
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