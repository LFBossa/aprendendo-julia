using JSON
using Graphs
using GraphPlot

include("DSatur.jl")

# carrega os dados
dados = open("brazil_data.json", "r") do f
    JSON.parse(f)
end
 

adjacencia = [ x in dados[y]["vizinhos"] for x=keys(dados), y=keys(dados)]
g = SimpleGraph(adjacencia)
label = [x for x=keys(dados) ]
y_postion = [ -dados[x]["coordenadas"][1] for x=keys(dados) ]
x_postion = [ dados[x]["coordenadas"][2] for x=keys(dados) ] 

CORES = ["red", "green", "blue", "yellow"]
cores = dsatur(g) 
coloracao = fill("", nv(g))
for i ∈ 1:nv(g)
    coloracao[i] = CORES[cores[i]]
end 
gplot(g, x_postion, y_postion, nodelabel=label, nodefillc=coloracao) #, nodesize=nodesize)

 