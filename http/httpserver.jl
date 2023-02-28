using JuliaWebAPI 

const apiclnt = APIInvoker("tcp://127.0.0.1:9999")
PORT = 1236
@info("Abra http://localhost:$(PORT)/calcula_distancia/x1/y1/x2/y2?norma=[2]|1 no navegador para usar a API")
@info("Exemplo: http://localhost:$(PORT)/calcula_distancia/0/1/2/3?norma=2 calcula a distancia (0,1) até (2,3) na norma Euclideana")

run_http(apiclnt, PORT)