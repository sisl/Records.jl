let
    lrec = ListRecord(1.0, Float64, Bool, Int)
    append!(lrec.frames, [RecordFrame(1,2), RecordFrame(3,4)])
    append!(lrec.states, [RecordState(1.0,1),RecordState(2.0,2),RecordState(3.0,1),RecordState(4.0,3)])
    lrec.defs[1] = true
    lrec.defs[2] = true
    lrec.defs[3] = false

    sparsemat, id_lookup = get_sparse_lookup(lrec)
    @test sparsemat[1,1] == 1.0
    @test sparsemat[2,1] == 3.0
    @test sparsemat[1,2] == 2.0
    @test sparsemat[2,2] == 0.0
    @test sparsemat[1,3] == 0.0
    @test sparsemat[2,3] == 4.0
    @test id_lookup == Dict(2=>2,3=>3,1=>1)

    qrec = convert(QueueRecord{Entity{Float64, Bool, Int}}, lrec)
    @test qrec[-1][1] == Entity(1.0,true,1)
    @test qrec[-1][2] == Entity(2.0,true,2)
    @test qrec[ 0][1] == Entity(3.0,true,1)
    @test qrec[ 0][2] == Entity(4.0,false,3)
    @test nframes(qrec) == 2
end

let
    qrec = QueueRecord(Entity{Float64, Bool, Int}, 2, 0.1)
    @test nframes(qrec) == 0

    update!(qrec, Frame([Entity(1.0,true,1), Entity(2.0,true,2)]))
    update!(qrec, Frame([Entity(3.0,true,1), Entity(4.0,false,3)]))

    @test nframes(qrec) == 2

    lrec = convert(ListRecord{Float64, Bool, Int}, qrec)
    @test nframes(lrec) == 2
    @test lrec.frames == [RecordFrame(1,2), RecordFrame(3,4)]
    @test lrec.states == [RecordState(1.0,1),RecordState(2.0,2),RecordState(3.0,1),RecordState(4.0,3)]
    @test lrec.defs[1] == true
    @test lrec.defs[2] == true
    @test lrec.defs[3] == false
    @test length(lrec.defs) == 3
end

