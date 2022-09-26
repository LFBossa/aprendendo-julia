using Graphs
using SparseArrays
# Usando a referência origial dos cara
# https://dl.acm.org/doi/pdf/10.1145/359094.359101


function transfer!(SetA, element, SetB)
	x = pop!(SetA, element)
	push!(SetB, x)
end

"""
    dsatur( g :: Graph; get_order :: Bool = false )
Aplica o algoritmo Dsatur para coloração do grafo g. 
Retorna uma lista de inteiros, cada um representando uma cor diferente para os vértices de g. 
Se `get_order = true`, retorna uma tupla com a primeira entrada representando a lista de cores, e a segunda entrada representando a ordem de coloração.
"""
function dsatur(g :: Graph; get_order:: Bool = false )
    N = nv(g) # número de vértices do grafo
    cores = spzeros(N,N) # cria uma matriz em que as linhas representam os vértices
    # e as colunas representam as cores
    # Conjuntos de vértices pintados e não pintados
    Não_Pintados  = Set(1:N)
    Pintados = Array([])
    # Vetor auxiliar que serve para calcular o grau dos vértices não-pintados
    vector_np = ones(N)
    # Matriz esparça de adjacencia
    A = sparse(g)
    # Passo inicial
    # Calcula os graus dos vértices (como ninguém foi pintado)
    graus_vertices = A*vector_np
    # seleciona o vértice de maior grau
    vertice_inicial = argmax(graus_vertices)  
    # coloca a cor 1 no vértice de maior grau
    cores[vertice_inicial,1] = 1 
    # Tira o indice do conjunto Não Pintados e coloca no Pintados
    transfer!(Não_Pintados, vertice_inicial, Pintados)
    # Zera a entrada no vetor de não-pintados
    vector_np[vertice_inicial] = 0
    for i=2:N
        # Calcula a saturacao de todos os vértices
        saturacao = reshape(sum(A*cores, dims=2), N)
        # Vamos pegar a saturação máxima dentre dos vértices não pintados 
        saturação_máxima = maximum(saturacao[CartesianIndex.(Não_Pintados)])
        # Agora pegamos os índices 
        mais_saturados_idx = findall(saturacao .== saturação_máxima) 
        if length(mais_saturados_idx) > 1
            # Vamos calcular os graus do subgrafo induzido pelos não-pintados
            graus_nao_pintados = A*vector_np
            # Os candidatos são os de maior saturacao e que não foram pintados
            candidatos = [x for x ∈ mais_saturados_idx ∩ Não_Pintados]
            # Vamos selecionar o cara de maior grau 
            idx_proximo = argmax(graus_nao_pintados[CartesianIndex.(candidatos)])
            proximo_a_colorir = candidatos[idx_proximo]
        else
            proximo_a_colorir = mais_saturados_idx[1]
        end
        # Calculamos agora as cores dos vizinhos do vértice
        cores_adjacentes = reshape(A[proximo_a_colorir,:]'*cores, N)
        # Vamos encontrar a menor cor não utilizada nos vizinhos
        proxima_cor = argmin(cores_adjacentes)
        cores[proximo_a_colorir, proxima_cor] = 1 
        transfer!(Não_Pintados, proximo_a_colorir, Pintados)
        vector_np[proximo_a_colorir] = 0
    end
    # encontra os não-zeros da matriz
    I, J, V = findnz(cores)
    lista = fill(0,N)
    for i = 1:N
        lista[I[i]] = J[i]
    end
    if get_order
        return lista, Pintados
    else
        return lista
    end
end