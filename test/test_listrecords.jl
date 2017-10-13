
let
    rec = ListRecord(1.0, Float64, Bool, Int)
    @test get_statetype(rec) == Float64
    @test get_deftype(rec) == Bool
    @test get_idtype(rec) == Int

    append!(rec.frames, [RecordFrame(1,2), RecordFrame(3,4)])
    append!(rec.states, [RecordState(1.0,1),RecordState(2.0,2),RecordState(3.0,1),RecordState(4.0,3)])
    rec.defs[1] = true
    rec.defs[2] = true
    rec.defs[3] = false

    @test nframes(rec) == 2
    @test nstates(rec) == 4
    @test nids(rec) == 3

    @test sort!(get_ids(rec)) == [1,2,3]
    @test nth_id(rec, 1, 1) == 1
    @test nth_id(rec, 1, 2) == 2
    @test nth_id(rec, 2, 1) == 1
    @test nth_id(rec, 2, 2) == 3

    @test length(ListRecordStateByIdIterator(rec, 1)) == 2
    @test length(ListRecordStateByIdIterator(rec, 2)) == 1
    @test length(ListRecordStateByIdIterator(rec, 3)) == 1

    @test collect(ListRecordStateByIdIterator(rec, 1)) == [(1,1.0),(2,3.0)]
    @test collect(ListRecordStateByIdIterator(rec, 2)) == [(1,2.0)]
    @test collect(ListRecordStateByIdIterator(rec, 3)) == [(2,4.0)]

    @test get_time(rec, 1) == 0.0
    @test get_time(rec, 2) == 1.0
    @test get_time(rec, 3) == 2.0
    @test get_timestep(rec) == 1.0
    @test get_elapsed_time(rec, 1, 10) == 9*1.0

    @test findfirst_frame_with_id(rec, 1) == 1
    @test findfirst_frame_with_id(rec, 3) == 2
    @test findfirst_frame_with_id(rec, 4) == 0

    @test findlast_frame_with_id(rec, 2) == 1
    @test findlast_frame_with_id(rec, 3) == 2
    @test findlast_frame_with_id(rec, 4) == 0

    @test length(ListRecordFrameIterator(rec)) == 2
    len = 0
    for frame in ListRecordFrameIterator(rec)
        len += 1
    end
    @test len == 2

    subrec = get_subinterval(rec, 2, 2)
    @test nframes(subrec) == 1
    @test get(subrec, 1, 1) == Entity(3.0, true, 1)
    @test get(subrec, 3, 1) == Entity(4.0, false, 3)
end


let
    rec = ListRecord(1.0, Float64, Bool, Int)
    @test nframes(rec) == 0

    scene = EntityFrame(Float64, Bool, Int, 2)
    push!(scene, Entity(1.0, true, 1))
    push!(scene, Entity(2.0, true, 2))
    push!(rec, scene)

    @test nframes(rec) == 1

    empty!(scene)
    push!(scene, Entity(3.0, true, 1))
    push!(scene, Entity(4.0, false, 3))
    push!(rec, scene)
    @test nframes(rec) == 2

    @test get(rec, 1, 1) == Entity(1.0, true, 1)
    @test get(rec, 1, 2) == Entity(3.0, true, 1)
    @test get(rec, 2, 1) == Entity(2.0, true, 2)
    @test get(rec, 3, 2) == Entity(4.0, false, 3)
end