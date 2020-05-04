% saída: [ [a,b,c], [a,b,d] ]
expandirCaminhoEmLargura([a,b],Out).

% bad = 70, adb=80, abc = 110
caminhoMaisCurtoEntreVariosCaminhos( [  [a,d,b], [b,a,d], [a,b,c] ], X ).

% retorna lista com todos que tem final "b"
listaDeCaminhosComFinalX(b, [ [a,b],[a,d,b],[a,c,b], [a,d], [a,b,d] ], ListaFiltrada).

% retorna [b,d]
listaDeVerticesFinaisDeUmaListaDeCaminhos([[a,b],[a,d,b],[a,b,d], [a,c,b]], ListaDeVerticesFinais).

% retorna [[a,b],[a,d]] ([a,b] = 50 [a,d,b] = 80 [a,c,b] = 50, [a,d] =20 [a,b,d] = 110)
desambiguarListaDeCaminhos( [ [a,b],[a,d,b],[a,c,b], [a,d], [a,b,d] ], ListaDesambiguada).