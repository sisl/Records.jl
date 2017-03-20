__precompile__(true)

module Records

export
    Entity,
    Frame,
    RecordFrame,
    RecordState,
    ListRecord,
    QueueRecord,
    ListRecordIterator,

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
    get_ids,
    nth_id,
    get_state,
    get_def,
    get_time,
    get_timestep,
    get_elapsed_time,
    findfirst_stateindex_with_id,
    findfirst_frame_with_id,
    findlast_frame_with_id,
    push_back_records!,
    update!,
    get_first_available_id


include("common.jl")
include("frames.jl")
include("listrecords.jl")
include("queuerecords.jl")
include("conversions.jl")

end # module
