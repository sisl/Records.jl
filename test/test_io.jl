let
    lrec = ListRecord(1.0, Float64, Bool, Int)
    append!(lrec.frames, [RecordFrame(1,2), RecordFrame(3,4)])
    append!(lrec.states, [RecordState(1.0,1),RecordState(2.0,2),RecordState(3.0,1),RecordState(4.0,3)])
    lrec.defs[1] = true
    lrec.defs[2] = true
    lrec.defs[3] = false

    file = tempname()
    open(file, "w") do io
        write(io, MIME"text/plain"(), lrec)
    end

    lrec2 = open(file, "r") do io
        read(io, MIME"text/plain"(), ListRecord{Float64, Bool, Int})
    end
    @test nframes(lrec2) == 2
    @test lrec2.frames == [RecordFrame(1,2), RecordFrame(3,4)]
    @test lrec2.states == [RecordState(1.0,1),RecordState(2.0,2),RecordState(3.0,1),RecordState(4.0,3)]
    @test lrec2.defs[1] == true
    @test lrec2.defs[2] == true
    @test lrec2.defs[3] == false
    @test length(lrec2.defs) == 3

    rm(file)
end

let
    frames = [
            Frame([Entity(1.0,true,1), Entity(2.0, true,2)]),
            Frame([Entity(3.0,true,1), Entity(4.0,false,3)]),
            ]

    file = tempname()
    open(file, "w") do io
        write(io, MIME"text/plain"(), frames)
    end

    frames2 = open(file, "r") do io
        read(io, MIME"text/plain"(), Vector{Frame{Entity{Float64, Bool, Int}}})
    end
    @test frames2[1][1] == Entity(1.0,true,1)
    @test frames2[1][2] == Entity(2.0,true,2)
    @test frames2[2][1] == Entity(3.0,true,1)
    @test frames2[2][2] == Entity(4.0,false,3)
    @test length(frames2) == 2

    rm(file)
end

# let
#     qrec = QueueRecord(Entity{Float64, Bool, Int}, 2, 0.1)
#     @test nframes(qrec) == 0

#     update!(qrec, Frame([Entity(1.0,true,1), Entity(2.0,true,2)]))
#     update!(qrec, Frame([Entity(3.0,true,1), Entity(4.0,false,3)]))

#     file = tempname()
#     open(file, "w") do io
#         write(io, MIME"text/plain"(), qrec)
#     end

#     qrec2 = open(file, "r") do io
#         read(io, MIME"text/plain"(), QueueRecord{Entity{Float64, Bool, Int}})
#     end
#     @test qrec2[-1][1] == Entity(1.0,true,1)
#     @test qrec2[-1][2] == Entity(2.0,true,2)
#     @test qrec2[ 0][1] == Entity(3.0,true,1)
#     @test qrec2[ 0][2] == Entity(4.0,false,3)
#     @test nframes(qrec2) == 2

#     rm(file)
# end