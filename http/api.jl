# Load required packages
using JuliaWebAPI

# Define functions testfn1 and testfn2 that we shall expose
function calcula_distancia(x1,y1,x2,y2; norma="2")
    ponto1 = [parse(Float64, x1), parse(Float64, y1)]
    ponto2 = [parse(Float64, x2), parse(Float64, y2)]
    diferencas = ponto1 - ponto2

    if norma == "2"
        distancia = sqrt( sum( diferencas .^2)  )
        distancia
    elseif norma == "1"
        distancia = sum( abs.(diferencas))
    else 
        distancia = Nothing
    end
    distancia
end


# Expose testfn1 and testfn2 via a ZMQ listener
process(
    JuliaWebAPI.create_responder([
        (calcula_distancia, true), 
    ], "tcp://127.0.0.1:9999", true, "")
)