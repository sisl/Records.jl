using Base.Test
using Records

rec = ListRecord(1.0, Float64, Bool, Int)
append!(rec.frames, [RecordFrame(1,2), RecordFrame(3,4)])
append!(rec.states, [RecordState(1.0,1),RecordState(2.0,2),RecordState(3.0,1),RecordState(4.0,3)])
rec.defs[1] = true
rec.defs[2] = true
rec.defs[3] = false

sparsemat, id_lookup = get_sparse_lookup(rec)
@test sparsemat[1,1] == 1.0
@test sparsemat[2,1] == 3.0
@test sparsemat[1,2] == 2.0
@test sparsemat[2,2] == 0.0
@test sparsemat[1,3] == 0.0
@test sparsemat[2,3] == 4.0
@test id_lookup == Dict(2=>2,3=>3,1=>1)