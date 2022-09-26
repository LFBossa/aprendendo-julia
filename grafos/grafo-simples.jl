using Graphs
using GraphPlot
include("DSatur.jl")


A = [0 0 0 1 0 0;
     0 0 1 1 0 0;
     0 1 0 1 0 0;
     1 1 1 0 1 0;
     0 0 0 1 0 1;
     0 0 0 0 1 0]



g = SimpleGraph(A)

CORES = ["red", "green", "blue", "yellow"]
lista, ordem = dsatur(g, get_order=true)
coloracao = fill("", nv(g))
for i ∈ 1:nv(g)
    coloracao[i] = CORES[lista[i]]
end
gplot(g, nodefillc=coloracao)
println(ordem)
