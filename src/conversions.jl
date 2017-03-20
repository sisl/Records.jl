"""
    convert(ListRecord, qrec::QueueRecord{E})

Converts a QueueRecord into the corresponding ListRecord.
"""
function Base.convert{S,D,I}(::Type{ListRecord{S,D,I}}, qrec::QueueRecord{Entity{S,D,I}})

    frames = Array(RecordFrame, length(qrec))
    states = Array(RecordState{S,I}, nstates(qrec))
    defs = Dict{I, D}()

    lo = 1
    for (i,pastframe) in enumerate(1-length(qrec) : 0)
        frame = qrec[pastframe]

        hi = lo
        for entity in frame
            defs[entity.id] = entity.def
            states[hi] = RecordState{S,I}(entity.state, entity.id)
            hi += 1
        end

        frames[i] = RecordFrame(lo, hi)
        lo = hi
    end

    return ListRecord{S,D,I}(get_timestep(qrec), frames, states, defs)
end
Base.convert{S,D,I}(::Type{ListRecord}, qrec::QueueRecord{Entity{S,D,I}}) = convert(ListRecord{S,D,I}, qrec)

"""
    convert(QueueRecord, lrec::ListRecord)

Converts a ListRecord into the corresponding QueueRecord{Entity{S,D,I}}.
Note that the timesteps for a ListRecord are not necessarily constant timesteps.
"""
function Base.convert{S,D,I}(::Type{QueueRecord{Entity{S,D,I}}}, lrec::ListRecord{S,D,I})

    N = nframes(lrec)
    M = maximum(n_objects_in_frame(lrec, i) for i in 1 : N)
    retval = QueueRecord(Entity{S,D,I}, N, get_mean_timestep(lrec), M)

    frame = Frame(Entity{S,D,I}, M)
    for i in 1 : N
        get!(frame, lrec, i)
        update!(retval, frame)
    end

    return retval
end
