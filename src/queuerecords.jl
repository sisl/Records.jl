type QueueRecord{S}
    frames::Vector{Frame{S}}
    timestep::Float64
    nframes::Int # number of active Frames
end
function QueueRecord{S}(::Type{S}, capacity::Int, timestep::Float64, frame_capacity::Int=100)
    frames = Array(Frame{S}, capacity)
    for i in 1 : length(frames)
        frames[i] = Frame(S, frame_capacity)
    end
    QueueRecord{S}(frames, timestep, 0)
end

Base.show(io::IO, rec::QueueRecord) = print(io, "QueueRecord(nframes=", rec.nframes, ")")

capacity(rec::QueueRecord) = length(rec.frames)
Base.length(rec::QueueRecord) = rec.nframes
function Base.deepcopy(rec::QueueRecord)
    retval = QueueRecord(capacity(rec), rec.timestep, capacity(rec.frames[1]))
    for i in 1 : rec.nframes
        copy!(retval.frames[i], rec.frames[i])
    end
    retval
end

pastframe_inbounds(rec::QueueRecord, pastframe::Int) = 1 ≤ 1-pastframe ≤ rec.nframes
Base.getindex(rec::QueueRecord, pastframe::Int) = rec.frames[1 - pastframe]
get_elapsed_time(rec::QueueRecord, pastframe::Int) = (1-pastframe)*rec.timestep
function get_elapsed_time(
    rec::QueueRecord,
    pastframe_farthest_back::Int,
    pastframe_most_recent::Int,
    )

    (pastframe_most_recent - pastframe_farthest_back)*rec.timestep
end

function Base.empty!(rec::QueueRecord)
    rec.nframes = 0
    return rec
end

function push_back_records!(rec::QueueRecord)
    for i in min(rec.nframes+1, length(rec.frames)) : -1 : 2
        copy!(rec.frames[i], rec.frames[i-1])
    end
    return rec
end
function Base.insert!{S}(rec::QueueRecord{S}, frame::Frame{S}, pastframe::Int=0)
    copy!(rec[pastframe], frame)
    return rec
end
function Base.get!{S}(frame::Frame{S}, rec::QueueRecord{S}, pastframe::Int=0)
    copy!(frame, rec[pastframe])
    frame
end
function update!{S}(rec::QueueRecord{S}, frame::Frame{S})
    push_back_records!(rec)
    insert!(rec, frame, 0)
    rec.nframes = min(rec.nframes+1, capacity(rec))
    return rec
end

