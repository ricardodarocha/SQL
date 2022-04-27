# JSON

Neste tutorial eu mostro como trabalhar com Json utilizando o **PostgreSQL**.  
🔗 Acesse o fonte [Json.SQL](https://github.com/ricardodarocha/SQL/blob/main/PG/Json.sql)

## Introdução

*[JSON]: JavaScript Object Notation  
*[PostgreSQL]: PostgreSQL Database Management System - Portions Copyright © 1996-2022, The PostgreSQL Global Development Group  

Há duas formas de trabalhar com JSON dentro do PostgreSQL. A primeira é salvando um documento JSON no campo `JSON/JSONb`.
A segunda forma é trabalhar com estruturas relacionais convencionais e convertê-las em JSON. Isto significa realizar consultas da maneira que você sempre fez, com relacionamentos JOIN e agregações (SUN, COUNT, MAX) que serão convertidos em JSON,
podendo ser um **JSON Object** ou **JSON Array**, a depender do seu cenário.

Neste artigo eu explico todos estes formatos.


## TYPE JSON e JSONb

O PostgreSQL possui dois **tipos nativos** para você armazenar objetos JSON. `JSON` e `JSONB`, Sendo o `JSON` o tipo mais simples e `JSONb` um formato binário otimizado, ideal para realizar buscas ou para compactar a base de dados.

_Ben Brumm_ oferece a seguinte comparação   
(https://www.databasestar.com/postgresql-json/)


Feature                     | JSON                      | JSONB
----------------------------|---------------------------|-------------------------------------
Storage                     | Stored exactly as entered | Stored in a decomposed binary format
Supports full text indexing | No                        | Yes
reserve white spaces        | Yes                       | No. It's removed
Preserve order of keys      | Yes                       | Yes
Keep duplicate keys         | No                        | (last value is kept)

### TYPE JSON

Este tipo é recomendado para JSON pequenos que não envolva muitos dados. Por exemplo se você tiver muitas linhas ou muitas colunas em um mesmo documento este formato não é recomendado.
Este tipo também é conhecido como beautifull JSON, pois ele tem a característica de armazer o JSON com a formatação que você inseriu.

**Características do tipo JSON**

 - Beautifull JSON: mantém a formatação
 - Mantém os pares CHAVE-VALOR na sequência que você inseriu
 - Recomendado para documentos pequenos
 - Não realiza busca
 
 ### TYPE JSONb

Um tipo de JSON binário, que otimiza o formato antes de salvar. É ideal para documentos grandes, com muitas linhas ou colunas, e possui um mecanismo de busca nativo do próprio PostgreSQL. É um formato extremamente rápido e indexado. Este formato reorganiza os pares Chave-Valor para favorecer os mecanismos de busca, o que significa que não irá preservar a formatação original.

**Características do tipo JSONb**

 - Bynary JSON: formato otimizado para armazenamento e busca
 - Formato compacto para armazenar, rápido para recuperar
 - Reorganiza as chaves de modo a otimizar os mecanismos de busca
 - Recomendado para documentos grandes
 - Não armazena a formatação original

## Exemplos

Nestes exemplos eu crio uma tabela de _Clientes_ e uma tabela de _Pedidos_, de forma que eu armazeno os dados básicos no formato relacional, no entanto as informações detalhadas (_Endereco_, _Itens do Pedido_) eu armazeno no formato JSON.

Na primeira tabela eu utilizo **JSON** e na segunda **JSONb** (Binary Json)

### Exemplo1

```SQL
DROP TABLE IF EXISTS cliente_test CASCADE;
CREATE TABLE cliente_test (
    id SERIAL PRIMARY KEY,
    nome VARCHAR,
    endereco JSON
);

DROP TABLE IF EXISTS pedido_test CASCADE;
CREATE TABLE pedido_test (
    id SERIAL PRIMARY KEY,
    cliente INT REFERENCES cliente(id),
    data DATE NOT NULL DEFAULT CURRENT_DATE,
    itens JSONB
);

INSERT INTO cliente_test (nome, endereco) VALUES 
    ('Amazon.com, Inc', '{"address":"410 Terry Ave N", "ciy":"Seattle", "PostalCode":98109, "state":"Washington", "country":"United States"}'),
    ('Samsung Electronics', '{"address":"Samsung-ro 129, Yeongtong-gu", "ciy":"Suwon-si", "state":"Gyeonggi-do", "country":"Soulth Korea", "telefone":"031-200-3113"}'),
    ('Broadcom Corporation Jobs', '{"address":"1320 Ridder Park Drive", "ciy":"San Jose", "state":"California", "country":"United States", "telefone":"1-408-433-8000"}'),
    ('Nvidia Corporation', '{"address":"2701 San Tomas Expressway", "ciy":"Santa Clara", "state":"California", "country":"United States", "telefone": "1+ (408) 486-2000"}');

INSERT INTO pedido_test (cliente, itens) VALUES
    (2, '[{"ref":"1a272fde","sequence":1,"cost":  600.00, "qt": 3, "total": 1800.00},
          {"ref":"331ce9ff","sequence":2,"cost":  190.00, "qt": 1, "total": 190},
          {"ref":"82c22c26","sequence":3,"cost": 5714.20, "qt": 2, "discount": 540.00, "total" : 602.84}]');

SELECT * FROM cliente INNER JOIN PEDIDO ON cliente.id = pedido.cliente
```

| id  | nome                | endereco        | pedido  | cliente | data                     | itens                                           |
| --- | ------------------- | --------------- | --- | ------- | ------------------------ | ----------------------------------------------- |
| 2   | Samsung Electronics | [object Object] | 1   | 2       | 2022-04-26T00:00:00.000Z | [object Object],[object Object],[object Object] |

[View on DB Fiddle](https://www.db-fiddle.com/f/4jyoMCicNSZpjMt4jFYoz5/0)

---

# Trabalhando com dados relacionais

```SQL
select row_to_json(row(cliente.codigo, cliente.nome)) from cliente
```

**or**

```SQL
select row_to_json(rowset) from (select cliente.codigo, cliente.nome from cliente) rowset;
```

| cliente                                     |
| ------------------------------------------- |
| {"id":1,"nome":"Amazon.com, Inc"}           |
| {"id":2,"nome":"Samsung Electronics"}       |
| {"id":3,"nome":"Broadcom Corporation Jobs"} |
| {"id":4,"nome":"Nvidia Corporation"}        |

---

```SQL
select array_to_json(array_agg(row(cliente.id, cliente.nome))) from cliente;
```

| cliente                           |
| --------------------------------- |
|[{"cli":1,"add":"Amazon.com, Inc"},{"cli":2,"add":"Samsung Electronics"},{"cli":3,"add":"Broadcom Corporation Jobs"},{"cli":4,"add":"Nvidia Corporation"}] |

---

```SQL
select row_to_json(row(cliente.codigo, cliente.endereco)) from cliente
```

| cliente                                                                                                                                                                    |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| {"id":1,"endereco":{"address":"410 Terry Ave N","ciy":"Seattle","PostalCode":98109,"state":"Washington","country":"United States"}}                                        |
| {"id":2,"endereco":{"address":"Samsung-ro 129, Yeongtong-gu","ciy":"Suwon-si","state":"Gyeonggi-do","country":"Soulth Corea","telefone":"031-200-3113"}}                   |
| {"id":3,"endereco":{"address":"1320 Ridder Park Drive","ciy":"San Jose","state":"California","country":"United States","telefone":"1-408-433-8000"}}          |
| {"id":4,"endereco":{"address":"2701 San Tomas Expressway","ciy":"Santa Clara","state":"California","country":"United States","telefone":"1+ (408) 486-2000"}} |

---

```SQL
select row_to_json(rowset) from
( select cliente.id, cliente.nome, pedido.itens from cliente inner join pedido on pedido.cliente = cliente.id )
```

```JSON
[
    {"cli":2,"ped":2,"nome":"Samsung Electronics","itens": [
        {"ref":"1a272fde","sequence":1,"cost":600,"qt":3,"total":1800},
        {"ref":"331ce9ff","sequence":2,"cost":190,"qt":1,"total":190},
        {"ref":"82c22c26","sequence":3,"cost":5714.2,"qt":2,"discount":540,"total":602.84}]
    },
    {"cli":2,"ped":3,"nome":"Samsung Electronics","itens": [
        {"ref":"28fd272e","sequence":1,"cost":19,"qt":10,"total":100}]
    }
]
```
# Acessando atributos

```PGSQL
SELECT
id,
nome,
endereco -> 'country' AS country,
endereco ->> 'country' AS country_value
FROM cliente_test;
```
|id|nome        |country  | country_value               |
|--|------------|---------|-----------------------------|
|1 |  Amazon    | “United States” |    United States    |
|2 |  Samsung   |  "South Korea"  |    South Korea      |
|3 |  BroadCom  | “United States” |    United States    |
|4 |  Nvidia    | “United States” |    United States    |


# Referências externas

Quer aprender mais sobre json, eu recomendo ler meu artigo no Medium
[**Cálculo dos dias úteis com Postgre**](https://rickrochaso.medium.com/c%C3%A1lculo-dos-dias-%C3%BAteis-no-postgresql-76be47470647)

Repositório do GitHub
https://github.com/ricardodarocha/DiasUteisPG

## Outros links

[**PostgreSQL JSON cheatsheet**](https://devhints.io/postgresql-json)

**Documentação oficial**
[Functions](https://www.postgresql.org/docs/current/static/functions-json.html)
[Tipos](https://www.postgresql.org/docs/current/static/datatype-json.html)
