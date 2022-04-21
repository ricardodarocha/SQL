drop type if exists es;
create type es as enum('entrada', 'saida', 'none');

drop table if exists Plano cascade;
create table Plano(
         id serial, 
        pai integer, 
  descricao text, 
       tipo es not null default 'entrada', 
      ordem integer not null, 
      nivel integer not null default 1, 
     outros integer);

drop table if exists Lanca cascade;
create table Lanca(id serial, Plano integer, data date, valor numeric(15,2));

alter table plano add constraint pkplano primary key (id);
alter table Lanca add constraint fkplano foreign key(plano) references plano(id);

    delete from PLANO where true;
  
   insert into plano(
     id,     ordem,     descricao,                                  pai,   nivel) 
   values 
        --              RECEITAS
     ( 1,    1,         'RECEITA'                                   ,  null, 1 ), 
     ----------------------------------------------------------------------------
     ( 2,    1,         'RECEITA OPERACIONAL'                       , 1,    2 ),
     ( 3,       1,            'VENDA DE MERCADORIAS'                , 2,    3 ),
     ( 4,       2,            'PRESTACAO DE SERVICOS'               , 2,    3 ),
     ----------------------------------------------------------------------------
     ( 5,    2,         'RECEITA FINANCEIRA'                        , 1,    2 ),
     ( 6,       1,            'JUROS E MULTAS'                      , 5,    3 ),
     ( 7,       2,            'INVESTIMENTOS'                       , 5,    3 ),
     ----------------------------------------------------------------------------
     (150,   3,         'OUTRAS RECEITAS'                           , 1,    2 ),
     --========================================================================== 
        --              DESPESAS                
     ( 8,   2,          'DESPESA'                                   , null,  1 ),
     ----------------------------------------------------------------------------
     ( 9,   1,          'DESPESA COMERCIAL'                         , 8,     2 ),
     (10,       1,             'COMISSOES'                          , 9,     3 ),
     (11,       2,             'FRETES'                             , 9,     3 ),
     (12,       3,             'EMBALAGEM'                          , 9,     3 ),
     (13,       4,             'PUBLICIDADE'                        , 9,     3 ),
     (14,       5,             'DEVEDORES/COBRANCAS'                , 9,     3 ),
     ----------------------------------------------------------------------------
     (15,   2,          'DESPESA ADMINISTRATIVA'                    , 8 ,    2 ), /*Nao associadas aos processos de vendas*/
     (16,       1,             'ALUGUEL'                            , 15,    3 ),
     (17,       2,             'ENERGIA'                            , 15,    3 ),
     (18,       3,             'AGUA'                               , 15,    3 ),
     ----------------------------------------------------------------------------
     (19,   3,          'TERCEIROS'                                 , 8 ,    2 ),/*Contratos com terceiros, honorários e softwares*/
     (20,       1,             'ADVOGADOS'                          , 19,    3 ),
     (21,       2,             'CONTABILIDADE'                      , 19,    3 ),
     (22,       3,             'SOFTWARE'                           , 19,    3 ),
     (23,       4,             'OUTROS HONORARIOS'                  , 19,    3 ),
     ----------------------------------------------------------------------------
     (24,   4,          'SALARIOS'                                  , 8,     2 ), 
     (25,       1,             'SALARIO DE FUNCIONARIOS             ',24,    3 ), 
     (26,             1,           'SALARIO'                        , 25,    4 ), 
     (27,             2,           'FERIAS'                         , 25,    4 ), 
     (28,             3,           'DECIMO TERCEIRO'                , 25,    4 ), 
     ----------------------------------------------------------------------------
     (29,         2,            'RETIRADAS'                         , 24,    3 ), 
     (30,             1,             'RETIRADA DOS SOCIOS'          , 29,    4 ), 
     (31,             2,             'PARTICIPACACAO NOS LUCROS'    , 29,    4 ),  
     ----------------------------------------------------------------------------
     (32,     5,             'DEPARTAMENTO'                         , 8 ,    2 ),  
     (33,         1,             'RECURSOS HUMANOS'                 , 32,    3 ),  
     (34,             1,             'NOVAS CONTRATACOES'           , 33,    4 ),  
     (35,             2,             'TREINAMENTO'                  , 33,    4 ),  
     (36,             3,             'RETENCAO'                     , 33,    4 ),  
     (37,             4,             'DESLIGAMENTO'                 , 33,    4 ),
     /*38..74 OUTROS DEPARTAMENTOS*/
     --ESCRITORIO
     --DEPARTAMENTO COMERCIAL
     --DEPARTAMENTO FINANCEIRO
     --ESTOQUE
     --PRODUCAO
     --ENGENHARIA
     --TI
     --DESENVOLVIMENTO
     --PESQUISA
     --DESIGN
     --CONTABILIDADE
     --QUALIDADE
     --------------------------------------------------------------------------
     (75,     6,             'IMPOSTOS'                        , 8   , 2 ),
     (76,         1,             'ICMS'                        , 75  , 3 ),
     (77,         1,             'IPI'                         , 75  , 3 ),
     (78,         1,             'IRPF'                        , 75  , 3 ),
     (79,         1,             'IRPJ'                        , 75  , 3 ),
     --80,      1           ''                         , 75  , 3 ),
     --81,      1           ''                         , 75  , 3 ),
     --82,      1           ''                         , 75  , 3 ),
     --83,      1           ''                         , 75  , 3 ),
     --84,      1           ''                         , 75  , 3 ),
     --85,      1           ''                         , 75  , 3 ),
     --86,      1           ''                         , 75  , 3 ),
     --87,      1           ''                         , 75  , 3 ),
     --88,      1           ''                         , 75  , 3 ),
     (89,         1,             'OUTROS IMPOSTOS'           , 75  , 3 ),
     ----------------------------------------------------------------------------
     (90,     7,             'DESPESA FINANCEIRA'               , 8   , 2 ),
     (91,         1,             'DESPESA BANCARIA'             , 90  , 3 ),
     (92,         2,             'JUROS'                        , 90  , 3 ),
     (93,         3,             'DESCONTOS'                    , 90  , 3 ),
     ----------------------------------------------------------------------------
     (151,    8,         'OUTRAS DESPESAS'                      , 8,    2 ),
     ----------------------------------------------------------------------------
;

    insert into Lanca(Plano, Data, Valor) values
     (3,Current_Date,120)
    ,(4,Current_Date,50)
    ,(6,Current_Date,50)
;

    select * from plano inner join lanca on lanca.plano = plano.id;

    with recursive 
    Lista(hierarquia, id, pai, analitico, sintetico, ordem, nivel, tipo, descricao) as (
        select '{}'::integer[], Plano.id, pai, to_char(ordem, 'FM00'), id as sintetico, ordem, nivel, tipo, descricao
          from Plano 
         where pai is null
     union all
        select lista.hierarquia || Plano.pai, Plano.id, Plano.Pai, Lista.analitico || '.' || to_char(Plano.ordem, 'FM00'), Plano.id, Plano.ordem, Plano.nivel, Plano.Tipo, Plano.descricao 
          from Plano
            join Lista on Plano.pai = Lista.id ),
    -------------------------------------------------------------------------------------------------
    Grupo as (
        select hierarquia, L.id, L.pai, L.analitico, L.sintetico, L.ordem, L.nivel, L.Tipo, L.descricao, sum(Lanca.valor) valor
           from Lista L left 
           join Lanca on L.id = Lanca.plano
           where data between '2022-01-01' and '2022-12-31' 
           or data is null --<-- listar todas as contas
       group by 1, 2, 3, 4, 5, 6, 7, 8, 9)
     --------------------------------------------------------------------------------------------------  
    select
        sintetico,
        analitico,
        nivel,
        repeat('  ', nivel-1)|| descricao as descricao,
        coalesce(valor, 0) + coalesce(Filhos, 0) valor,
        case Tipo 
            when 'entrada' then '(+)'    
            else '(-)'
        end as sinal 
    from
        Grupo
    left join lateral (
        select
            sum(valor) Filhos
        from
            Grupo L
        where
            Grupo.ID = any(L.hierarquia)) x on
        true
    order by
        Analitico;
    
    update Plano set tipo = 'saida' where id >= 8 and id <100

     /*
     

     sintetico|analitico  |nivel|descricao                      |valor |sinal|
---------|-----------|-----|-------------------------------|------|-----|
         1|01        |    1|RECEITA                        |220.00|(+)  |
         2|01.01     |    2|  RECEITA OPERACIONAL          |170.00|(+)  |
         3|01.01.01  |    3|    VENDA DE MERCADORIAS       |120.00|(+)  |
         8|02        |    1|DESPESA                        |    50|(-)  |         
        90|02.07     |    2|  DESPESA FINANCEIRA           |    50|(-)  |
        91|02.07.01  |    3|    DESPESA BANCARIA           |     0|(-)  |
        92|02.07.02  |    3|    JUROS                      |     0|(-)  |
        93|02.07.03  |    3|    DESCONTOS                  |    50|(-)  |
       151|02.08     |    2|  OUTRAS DESPESAS              |     0|(-)  |
     
     */
