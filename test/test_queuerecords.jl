@testset "records_iterator" begin
    q = QueueRecord(Int64, 100, 1., 10)
    data = [[1,2,3],[4,5,6],[7,8,9]]
    for d in data
        update!(q, Frame(d))
    end
    @test all([data[i] == [x[1], x[2], x[3]] for (i, x) in enumerate(q)])
    @test iterate(q,1) === nothing
end
