__precompile__(true)

module Records

using StaticArrays

export
    ID,

    Frame,
    RecordFrame,
    RecordState,
    ListRecord,
    QueueRecord,
    ListRecordIterator,

    get_statetype,
    get_deftype,

    capacity,
    nframes,
    frame_inbounds,
    pastframe_inbounds,
    n_objects_in_frame,
    get_ids,
    nth_id,
    get_time,
    get_state,
    get_def,
    get_elapsed_time,
    get_mean_timestep,
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

end # module
