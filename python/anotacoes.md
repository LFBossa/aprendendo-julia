# Pequeno dicionário de python para julia

## Condicionais

Operador ternário
```julia
Condição ? "Condição verdadeira" : "Condição falsa"
```

## Loops

```julia
# loop duplo, externo em j interno em i 
# faz j=1, percorre todo i, depois faz j=2 e percorre todo i
for j ∈ 1:2, i ∈ 1:20
    println("($i,\t $j)")
end
```

## Funções
Podemos usar despacho múltiplo para alterar o comportamento de funções. 
```julia
f(x) = 2*x + 1
f(n::Int) = n > 0 ? n*f(n-1) : 1 # fatorial nos inteiros
```
A mesma função $f$ assume valores diferentes se fornecermos um argumento inteiro ou float. 
```julia-repl
julia> f(4.0) 
9.0
julia> f(4)
24
```

## Texto
Concatenação com `*`, string literals com `$()`

```julia-repl
julia> a = 2;
julia> "O valor de a é $a" * " e seu dobro é $(2*a)"
"O valor de a é 2 e seu dobro é 4"
```


## Listas

```julia
# criando uma lista através de um AbstractRange
lista = collect(1:10)
# digitando \in e pressionando <tab>, gera o símbolo
quadrados = [x^2 for x ∈ lista]
# podemos usar o símbolo de igual
cubo = [x^3 for x=lista]
# podemos aplicar um mapa à uma lista
metade = map(x-> x/2, lista)
# podemos utilizar o operador ternário na list compreension
collatz = [ n % 2 == 0 ? n/2 : 3*n+1 for n in lista]
```

## Matrizes
```julia-repl
julia> matriz = [x*y for x∈1:5, y∈1:4]

5×4 Matrix{Int64}:
 1   2   3   4
 2   4   6   8
 3   6   9  12
 4   8  12  16
 5  10  15  20
```

## Arquivos



## Referências

1. [julia for data science](https://www.juliafordatascience.com/quickstart/)
1. [julia language: a concise tutorial](https://syl1.gitbook.io/julia-language-a-concise-tutorial/)
1. [Introduction to Scientific Programming and Machine Learning with Julia](https://sylvaticus.github.io/SPMLJ/stable/)