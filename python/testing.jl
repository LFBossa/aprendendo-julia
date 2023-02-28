
lista = collect(1:10)

fitrado = [ x^2 for x ∈ lista if x % 3 == 2 ]

duplo_filtro = [ (x % 3 == 1 ) ? x^2 : x - 1  for x ∈ lista  ]