using .Threads
using BenchmarkTools

using .Threads
a = zeros(10)
@threads for i = 1:10
    a[i] = threadid()
end
println(a)

function sqrt_array(A)
    B = similar(A)
    for i in eachindex(A)
        @inbounds B[i] = sqrt(A[i])
    end
    B
end

function threaded_sqrt_array(A)
    B = similar(A)
    @threads for i in eachindex(A)
        @inbounds B[i] = sqrt(A[i])
    end
    B
end

A = rand(10^4, 10^4)
@btime sqrt_array(A);
@btime threaded_sqrt_array(A);

# make sure we're getting the correct value
sqrt_array(A) ≈ threaded_sqrt_array(A)