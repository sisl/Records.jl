__precompile__()

module Records

export
    Entity,
    Frame,
    EntityFrame,
    RecordFrame,
    RecordState,
    ListRecord,
    QueueRecord,
    EntityQueueRecord,

    ListRecordFrameIterator,
    ListRecordStateByIdIterator,

    get_statetype,
    get_deftype,
    get_idtype,

    capacity,
    nframes,
    nstates,
    nids,
    frame_inbounds,
    pastframe_inbounds,
    n_objects_in_frame,
    id2index,
    get_ids,
    nth_id,
    get_state,
    get_def,
    get_time,
    get_timestep,
    get_elapsed_time,
    get_subinterval,
    get_by_id,
    findfirst_stateindex_with_id,
    findfirst_frame_with_id,
    findlast_frame_with_id,
    get_first_available_id,
    push_back_records!,
    update!,
    allocate_frame,
    get_sparse_lookup


include("common.jl")
include("entities.jl")
include("frames.jl")
include("listrecords.jl")
include("queuerecords.jl")
include("conversions.jl")

end # module
