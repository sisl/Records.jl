
let
    rec = ListRecord(1.0, Float64, Bool, Int)
    append!(rec.frames, [RecordFrame(1,2), RecordFrame(3,4)])
    append!(rec.states, [RecordState(1.0,1),RecordState(2.0,2),RecordState(3.0,1),RecordState(4.0,3)])
    rec.defs[1] = true
    rec.defs[2] = true
    rec.defs[3] = false

    @test length(ListRecordStateByIdIterator(rec, 1)) == 2
    @test length(ListRecordStateByIdIterator(rec, 2)) == 1
    @test length(ListRecordStateByIdIterator(rec, 3)) == 1

    @test collect(ListRecordStateByIdIterator(rec, 1)) == [(1,1.0),(2,3.0)]
    @test collect(ListRecordStateByIdIterator(rec, 2)) == [(1,2.0)]
    @test collect(ListRecordStateByIdIterator(rec, 3)) == [(2,4.0)]

    @test length(ListRecordFrameIterator(rec)) == 2
    len = 0
    for frame in ListRecordFrameIterator(rec)
        len += 1
    end
    @test len == 2
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