Esta versão de plano de contas considera os seguintes registros

```
Plano de Contas - Ativos

1 Ativo
1.1 Ativo Circulante
1.1.1 Caixa e Equivalentes de Caixa 1.1.2 Contas a Receber 1.1.3 Estoques
1.2 Ativo Não Circulante 1.2.1 Investimentos 1.2.2 Imobilizado 1.2.3 Intangível

Plano de Contas - Passivos

2 Passivo
2.1 Passivo Circulante
2.1.1 Fornecedores 2.1.2 Empréstimos e Financiamentos de Curto Prazo 2.1.3 Salários e Encargos a Pagar
2.2 Passivo Não Circulante 2.2.1 Empréstimos e Financiamentos de Longo Prazo 2.2.2 Provisões 2.2.3 Impostos e Contribuições a Pagar
```

```sql
--Crie a estrutura básica da tabela
create table if not exists planocontas (codigo serial, codigo_analitico varchar, descricao varchar, tipo varchar(10), nivel integer, pai varchar )
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('1', 'Ativo', 'ativo', 1, null);

INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('2', 'Passivo', 'passivo', 1, null);

--Insira o plano de contas da maneira que quiser. Obedeça o código analítico para criar níveis descendentes

-- Inserir Ativos
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('1.1', 'Ativo Circulante', 'ativo', 2, '1');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('1.1.1', 'Caixa e Equivalentes de Caixa', 'ativo', 3, '1.1');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('1.1.2', 'Contas a Receber', 'ativo', 3, '1.1');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('1.1.3', 'Estoques', 'ativo', 3, '1.1');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('1.2', 'Ativo Não Circulante', 'ativo', 2, '1');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('1.2.1', 'Investimentos', 'ativo', 3, '1.2');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('1.2.2', 'Imobilizado', 'ativo', 3, '1.2');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('1.2.3', 'Intangível', 'ativo', 3, '1.2');

-- Inserir Passivos
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('2.1', 'Passivo Circulante', 'passivo', 2, '2');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('2.1.1', 'Fornecedores', 'passivo', 3, '2.1');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('2.1.2', 'Empréstimos e Financiamentos de Curto Prazo', 'passivo', 3, '2.1');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('2.1.3', 'Salários e Encargos a Pagar', 'passivo', 3, '2.1');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('2.2', 'Passivo Não Circulante', 'passivo', 2, '2');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('2.2.1', 'Empréstimos e Financiamentos de Longo Prazo', 'passivo', 3, '2.2');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('2.2.2', 'Provisões', 'passivo', 3, '2.2');
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai)
VALUES ('2.2.3', 'Impostos e Contribuições a Pagar', 'passivo', 3, '2.2');

--observe que ele gerou o campo código (serial), esse campo será único para cada empresa
alter table add codigopai integer ;

--Agora vamos gravar o campo código na chave codigopai para buscar a sequência automática
--A sequência automática é preferível em vez da chave analítica para compor os índices

--procedure associar_chaves_planocontas
DO $$
DECLARE
    chave_da_busca VARCHAR(50);
    novo_codigo_da_busca integer;
BEGIN
    FOR chave_da_busca, novo_codigo_da_busca IN
        SELECT codigo_analitico, codigo
        FROM planocontas 
    LOOP
        UPDATE planocontas
        SET codigopai = novo_codigo_da_busca
        WHERE pai = chave_da_busca and codigopai is null;
    END LOOP;
END $$;

select * from planocontas;

--voce poderá criar novos itens do plano de contas, porém eles devem informar o campo codiogpai como null, em seguida deve ser rodada a procedure associar_chaves_planocontas
--você não poderá excluir ou editar itens que possuam lançamento
```

## Criando lançamentos

```sql
CREATE TABLE IF NOT EXISTS LANCAMENTOS (codigo serial, planocontas integer not null, data timestamp default current_timestamp not null,
valor numeric(15,2))
```

## Listando os lançamentos

```sql
SELECT planocontas, SUM(valor) AS total
FROM lancamentos
GROUP BY ROLLUP (planocontas)
```

De forma mais elaborada

```Sql
SELECT C1, C2, SUM(valor)
FROM (
    SELECT 
        SPLIT_PART(p.codigo_analitico, '.', 1) AS c1,
        SPLIT_PART(p.codigo_analitico, '.', 2) AS c2,
        COALESCE(SUM(valor), 0.0) AS valor
    FROM planocontas p
    LEFT JOIN lancamentos l ON l.planocontas = p.codigo
    GROUP BY p.codigo_analitico
    ORDER BY p.codigo_analitico
) AS relacionamentos
GROUP BY ROLLUP (c1, c2)
ORDER BY C1, C2;
```

Para evitar que sejam lançados valores nos primeiros níveis, crie uma coluna redirect, e informe a chave outros para o plano de contas

```sql
alter table planocontas add redirect integer
```

```sql
INSERT INTO PLANOCONTAS 
 (codigo_analitico, Descricao, Tipo, nivel, pai, CODIGO_PAI)
VALUES ('1.1.9', 'Outros', 'ativo', 3, '1.1', null) RETURNING CODIGO AS NOVO_CODIGO
--associar_chaves_planocontas
```

```
UPDATE PLANOCONTAS SET REDIRECT = :NOVO_CODIGO WHERE CODIGO_SINTETICO = '1';
UPDATE PLANOCONTAS SET REDIRECT = :NOVO_CODIGO WHERE CODIGO_SINTETICO = '1.1';
```

```funcao redirecionar_outros
DO $$
DECLARE
    chave_da_busca VARCHAR(50);
    novo_codigo_da_busca integer;
BEGIN
    FOR chave_da_busca, redirect IN
        SELECT codigo, redirect
        FROM planocontas
        WHERE redirect is not null
    LOOP
        UPDATE LANCAMENTOS
        SET planocontas = redirect
        WHERE planocontas = chave_da_busca;
    END LOOP;
END $$;
```
agora é possível redirecionar lançamentos dos primeiros níveis para itens do nível mais baixo

`redirecionar_outros`

## Dúvidas do Suporte

### Como alterar a descrição de um plano de contas

O sistema não permitirá excluir ou editar itens que possuam lançamentos
Para forçar isso pode ser feita a seguinte manipulação
1. Criar um novo plano de contas temporário, com a descrição anterior
   Digamos que queremos renomear o codigo '2.1.3' para 'Salários e Encargos'
```
INSERT INTO PLANOCONTAS (codigo_analitico, Descricao, Tipo, nivel, pai, codigo_pai)
select codigo_analitico, Descricao, Tipo, nivel, pai from
PLANOCONTAS where codigo_analitico = 14 RETURNING CODIGO as NOVO_CODIGO_GERADO;
```

2. Altere a descricao do novo plano de contas
```
UPDATE PLANOCONTAS SET DESCRICAO = :NOVA_DESCRICAO WHERE CODIGO = :NOVO_CODIGO_GERADO
```
4. Mova todos os lançamentos anteriores para o novo código
```
UPDATE LANCAMENTOS SET PLANOCONTAS = :NOVO_CODIGO_GERADO 
```
