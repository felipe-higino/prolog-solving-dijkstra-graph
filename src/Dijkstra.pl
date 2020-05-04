% % registro de arestas
% ar(a,b,50).
% ar(b,c,60).
% ar(b,d,60).
% ar(a,d,20).
% ar(a,c,0).

% ar(a,d,40).
% ar(a,c,70).
% ar(a,b,30).
% ar(b,c,50).
% ar(b,f,270).
% ar(d,c,20).
% ar(d,e,120).
% ar(c,e,80).
% ar(c,f,200).
% ar(e,f,70).

ar(a,b,140).
ar(a,d,85).
ar(b,h,0).
ar(b,f,26).
ar(b,j,0).
ar(c,i,126).
ar(c,f,12).
ar(c,d,19).
ar(d,e,39).
ar(e,i,150).
ar(e,g,30).
ar(f,h,100).
ar(f,l,65).
ar(f,m,67).
ar(g,i,74).
ar(h,l,70).
ar(h,j,0).
ar(i,m,30).
ar(j,n,61).
ar(l,p,31).
ar(m,p,110).
ar(n,p,70).

% consulta de aresta
aresta(X,Y,Z) :- ar(Y,X,Z) ; ar(X,Y,Z).

listaDeVerticesAdjacentes(X, ListaDeVerticesAdjacentes):-
    findall(Y, aresta(X,Y,_), ListaDeVerticesAdjacentes).

%expande em largura, verificando se não há retorno para nó já visitado nessa linha
expandirCaminhoEmLargura(CaminhoSendoExpandido, ListaDeNovosCaminhos):-
    last(CaminhoSendoExpandido, UltimoVertice),
    listaDeVerticesAdjacentes(UltimoVertice, ListaDeVerticesAdjacentes),
    maplist(
        {CaminhoSendoExpandido}/[VerticeAdjacente, NovoCaminho]>>
        (
            append(CaminhoSendoExpandido, [VerticeAdjacente], CaminhoEsticado),
            % tem vértice repetido?
            is_set(CaminhoEsticado) -> 
                NovoCaminho=CaminhoEsticado
                ;NovoCaminho = []
        )
    , ListaDeVerticesAdjacentes, ListaDeNovosCaminhosComVazios),
    exclude(
        [Element] >> ( Element == [] )
    , ListaDeNovosCaminhosComVazios, ListaDeNovosCaminhos).

tamanhoDoCaminho(ListaDeVertices, TamanhoDoCaminho):-
    foldl(
        {ListaDeVertices}/[VerticeDaLista, SaldoAnterior, Saida]>>
        (
            nextto(VerticeDaLista, ProximoVertice, ListaDeVertices)->
            (
                aresta(VerticeDaLista,ProximoVertice,Tamanho),
                Saida is Tamanho + SaldoAnterior
            ); Saida = SaldoAnterior
        )
    ,ListaDeVertices, 0, TamanhoDoCaminho).
    
caminhoMaisCurtoEntreVariosCaminhos(ListaDeCaminhos, MenorCaminho):-
    foldl(
        [CaminhoDaLista, CaminhoAnterior, Saida]>>
        (
            CaminhoAnterior == null ->
                Saida = CaminhoDaLista
            ;(
                tamanhoDoCaminho(CaminhoDaLista,  TamanhoDoCaminhoDaLista),
                tamanhoDoCaminho(CaminhoAnterior, TamanhoAnterior),
                TamanhoDoCaminhoDaLista < TamanhoAnterior ->
                    Saida = CaminhoDaLista ; Saida = CaminhoAnterior
            )
        )
    , ListaDeCaminhos, null, MenorCaminho).

%filtra lista e retorna ocorrências de caminhos com vértices finais iguais
listaDeCaminhosComFinalX(X, ListaDeCaminhos, ListaComOcorrenciasDeFinalX):-
    exclude(
        {X}/[Caminho] >> ( last(Caminho, UltimoVertice) , UltimoVertice \= X )
    , ListaDeCaminhos, ListaComOcorrenciasDeFinalX).

%retorna lista com todos os vértices finais sem repetir
listaDeVerticesFinaisDeUmaListaDeCaminhos(ListaDeCaminhos, ListaDeVerticesFinais):-
    maplist(
        [CaminhoDaLista, OutVertice] >>
        (
            last(CaminhoDaLista, OutVertice)
        )
    , ListaDeCaminhos, ListaDeVerticesFinaisCrua),
    sort(ListaDeVerticesFinaisCrua, ListaDeVerticesFinais).

% escolhe menhor caminho para todas as ocorrências ambíguas:
% retorna [[a,b],[a,d]] ([a,b] = 50 [a,d,b] = 80 [a,c,b] = 50, [a,d] =20 [a,b,d] = 110)
desambiguarListaDeCaminhos(ListaDeCaminhos, ListaDesambiguada):-
    listaDeVerticesFinaisDeUmaListaDeCaminhos(ListaDeCaminhos, ListaDeVerticesFinais),
    maplist(
        {ListaDeCaminhos}/[VerticeFinal, MenorCaminhoDesseVertice]>>
        (
            listaDeCaminhosComFinalX(VerticeFinal, ListaDeCaminhos, ListaDeCaminhosComMesmoFinal),
            caminhoMaisCurtoEntreVariosCaminhos(ListaDeCaminhosComMesmoFinal, MenorCaminhoDesseVertice)
        )
    , ListaDeVerticesFinais, ListaDesambiguada).

caminhoMaisCurtoEntreVariosCaminhosExcluindoLista(ListaDeVerticesExcluidos, ListaDeCaminhos, CaminhoMaisCurto):-
    maplist(
        {ListaDeVerticesExcluidos}/[CaminhoDaLista, NovoCaminho]>>
        (
            last(CaminhoDaLista, UltimoElementoDoCaminho),
            member(UltimoElementoDoCaminho, ListaDeVerticesExcluidos)->
                NovoCaminho = []
                ;NovoCaminho= CaminhoDaLista
        )
    ,ListaDeCaminhos, ListaComVazios),
    exclude( 
        [Element]>>(Element == [])
    , ListaComVazios, ListaParaAplicarFiltro),
    caminhoMaisCurtoEntreVariosCaminhos(ListaParaAplicarFiltro, CaminhoMaisCurto).

%ListaIterativa começa [ [V0] ]
%VerticeFechadoAtualmente começa = V0
%Não verifica existência de A,B
menorCaminhoDeAateB_Rec(
    V_destino,
    VerticeFechadoAtualmente,
    ListaDeVerticesFechados,
    ListaIterativa,
    ListaDeVerticesMenorCaminho):-
    
    VerticeFechadoAtualmente == V_destino ->
        (
            listaDeCaminhosComFinalX(V_destino, ListaIterativa, ListaComResposta),
            ListaComResposta = [ListaDeVerticesMenorCaminho|_]
        );
        (
            caminhoMaisCurtoEntreVariosCaminhosExcluindoLista(
                ListaDeVerticesFechados,%exclui-se os vertices ja fechados
                ListaIterativa,
                MenorCaminhoDaIteracao
            ),
            expandirCaminhoEmLargura(MenorCaminhoDaIteracao, ListaComCaminhosExpandidos),
            append(ListaIterativa, ListaComCaminhosExpandidos, NovaListaSemGarantias),
            desambiguarListaDeCaminhos(NovaListaSemGarantias, ListaDaIteracaoDesambiguada),
            last(MenorCaminhoDaIteracao, VerticeFechadoNaIteracao),
            append(ListaDeVerticesFechados, [VerticeFechadoNaIteracao], NovaListaDeVerticesFechados),
            menorCaminhoDeAateB_Rec(
                V_destino,
                VerticeFechadoNaIteracao,
                NovaListaDeVerticesFechados,
                ListaDaIteracaoDesambiguada,
                ListaDeVerticesMenorCaminho)
        ).

% menorCaminhoEntreAeB(a,f,X). [a,d,c,e,f]
menorCaminhoEntreAeB(A, B, MenorCaminho):-
    menorCaminhoDeAateB_Rec(B, A, [], [[A]], MenorCaminho).