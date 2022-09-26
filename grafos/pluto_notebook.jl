### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ d6ac5c74-3b6d-11ed-019b-6d71f51d8c89
begin
	using Graphs
	using GraphPlot
	using SparseArrays
	using PlutoUI
	using JSON
end

# ╔═╡ 657f749c-2af6-45f4-835b-8f08dba91ad8
md"""
Matriz de adjacência do grafo.
"""

# ╔═╡ b219406a-5057-45ec-9c36-224674af68e5
A = [0 0 0 1 0 0;
     0 0 1 1 0 0;
     0 1 0 1 0 0;
     1 1 1 0 1 0;
     0 0 0 1 0 1;
     0 0 0 0 1 0];

# ╔═╡ beae047a-10f8-4882-b87b-b99bcc0aab1d
g = SimpleGraph(A)

# ╔═╡ 72e61c8b-b53c-45c3-9a17-1115b6e3cbc1
CORES = ["red", "green", "blue", "yellow"]

# ╔═╡ 86a4eeb7-0daf-40e5-a630-af4e2285b082
@bind x Slider(1:nv(g), show_value=true)

# ╔═╡ 34550ef6-994c-438a-a343-86bb43536d2c
begin
dados = open("brazil_data.json", "r") do f
    JSON.parse(f)
end
 

adjacencia = [ x in dados[y]["vizinhos"] for x=keys(dados), y=keys(dados)]
brazil = SimpleGraph(adjacencia)
end

# ╔═╡ fcfe2ea4-78fb-4a48-b6ee-ce02e967da80
begin
label = [x for x=keys(dados) ];
y_postion = [ -dados[x]["coordenadas"][1] for x=keys(dados) ];
x_postion = [ dados[x]["coordenadas"][2] for x=keys(dados) ];
end

# ╔═╡ 355d516e-c2ad-471b-a2b8-2cac53464316
@bind y Clock(max_value=nv(brazil))

# ╔═╡ 1edef0d6-f790-401b-ad52-a15e281b9f5f
md"""
# Apêndice
"""

# ╔═╡ eeec7732-8519-46ff-95e1-39fe4b5d4ccb

function transfer!(SetA, element, SetB)
	x = pop!(SetA, element)
	push!(SetB, x)
end



# ╔═╡ 13c86ba1-5be3-4419-9c1d-37ca597384e5

function dsatur(g :: Graph )
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
    cores, Pintados
end

# ╔═╡ 3b250ff2-ca00-4de6-b955-7005df060289
begin
	matrix, order = dsatur(g)
	I, J, V = findnz(matrix)
	coloracao = fill("", nv(g))
	for i ∈ 1:nv(g)
	    coloracao[I[i]] = CORES[J[i]]
	end
end

# ╔═╡ fd00eb44-e369-4d8d-99a6-06cf46d69f7a
order

# ╔═╡ 6308f06e-c188-4752-aa79-c34beb477d09
function cor_parcial(i)
	colores = ["gray" for i ∈ 1:nv(g)]
	for i ∈ 1:i
		colores[order[i]] = CORES[J[i]]
	end
	colores
end

# ╔═╡ d9af0fdf-f81d-482e-9266-c34195d37b91
gplot(g, linetype="curve", layout=circular_layout, nodefillc=cor_parcial(x))

# ╔═╡ 3c80594c-3c30-48a0-b475-6566b14cccec
begin
	matrixb, orderb = dsatur(brazil)
	Ib, Jb, Vb = findnz(matrixb)
	coloracaob = fill("", nv(brazil))
	for i ∈ 1:nv(brazil)
	    coloracaob[Ib[i]] = CORES[Jb[i]]
	end
end

# ╔═╡ 0a752d63-29bd-4c74-97a5-1b424b01a2de
function cor_parcial_b(i)
	colores = ["gray" for k ∈ 1:nv(brazil)]
	for j ∈ 1:i
		colores[orderb[j]] = coloracaob[orderb[j]]
	end
	colores
end

# ╔═╡ d2b15af9-c0d3-44bd-b701-ba0470f091dc
gplot(brazil, x_postion, y_postion, nodelabel=label, nodefillc=cor_parcial_b(y))  

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
GraphPlot = "a2cc645c-3eea-5389-862e-a155d0052231"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[compat]
GraphPlot = "~0.5.2"
Graphs = "~1.7.3"
JSON = "~0.21.3"
PlutoUI = "~0.7.43"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.1"
manifest_format = "2.0"
project_hash = "d5071ab43f68787c158e1e65c12ecb67c6db65c2"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "5856d3031cdb1f3b2b6340dfdc66b6d9a149a374"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.2.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "d853e57661ba3a57abcdaa201f4c9917a93487a2"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.GraphPlot]]
deps = ["ArnoldiMethod", "ColorTypes", "Colors", "Compose", "DelimitedFiles", "Graphs", "LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "5cd479730a0cb01f880eff119e9803c13f214cab"
uuid = "a2cc645c-3eea-5389-862e-a155d0052231"
version = "0.5.2"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "d2b1968d27b23926df4a156745935950568e4659"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.7.3"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "3d5bf43e3e8b412656404ed9466f1dcbf7c50269"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "2777a5c2c91b3145f5aa75b61bb4c2eb38797136"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.43"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "2189eb2c1f25cb3f43e5807f26aa864052e50c17"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.8"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═d6ac5c74-3b6d-11ed-019b-6d71f51d8c89
# ╟─657f749c-2af6-45f4-835b-8f08dba91ad8
# ╠═b219406a-5057-45ec-9c36-224674af68e5
# ╠═beae047a-10f8-4882-b87b-b99bcc0aab1d
# ╠═72e61c8b-b53c-45c3-9a17-1115b6e3cbc1
# ╠═3b250ff2-ca00-4de6-b955-7005df060289
# ╠═fd00eb44-e369-4d8d-99a6-06cf46d69f7a
# ╠═86a4eeb7-0daf-40e5-a630-af4e2285b082
# ╠═6308f06e-c188-4752-aa79-c34beb477d09
# ╠═d9af0fdf-f81d-482e-9266-c34195d37b91
# ╠═34550ef6-994c-438a-a343-86bb43536d2c
# ╠═fcfe2ea4-78fb-4a48-b6ee-ce02e967da80
# ╠═3c80594c-3c30-48a0-b475-6566b14cccec
# ╠═355d516e-c2ad-471b-a2b8-2cac53464316
# ╠═0a752d63-29bd-4c74-97a5-1b424b01a2de
# ╠═d2b15af9-c0d3-44bd-b701-ba0470f091dc
# ╟─1edef0d6-f790-401b-ad52-a15e281b9f5f
# ╟─eeec7732-8519-46ff-95e1-39fe4b5d4ccb
# ╟─13c86ba1-5be3-4419-9c1d-37ca597384e5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
