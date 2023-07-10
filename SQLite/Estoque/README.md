# Estoque

Utilizando o SQLite, desenvolver um mecanismo de saldo do estoque


1. Crie a tabela de produtos, contendo o Código do Produto e o Nome do produto (Demais campos opcionais)
```sql
CREATE TABLE produto (
    codigo       INTEGER      PRIMARY KEY ON CONFLICT ROLLBACK AUTOINCREMENT
                              NOT NULL,
    nome         VARCHAR(50)  NOT NULL,
    tipo         VARCHAR(1)   NOT NULL DEFAULT 'P', --P produto M matéria prima
    grupo        INTEGER,
    ref          VARCHAR(10),
    codbarras    VARCHAR(36)                           
);
```
2. Crie a tabela de estoque, com chave estrangeira na tabela de produto

```sql
CREATE TABLE estoque (
    seq       INTEGER         PRIMARY KEY ON CONFLICT ROLLBACK AUTOINCREMENT
                              NOT NULL,
    prod      INTEGER         NOT NULL
                              REFERENCES produto (CODIGO),
    saldo_ini NUMERIC (12, 3) NULL, --Deve ser preenchido por uma trigger
    entrada   NUMERIC (12, 3) NOT NULL
                              DEFAULT (0),
    saida     NUMERIC (12, 3) NOT NULL
                              DEFAULT (0),
    data      TIMESTAMP            NOT NULL DEFAULT (CURRENT_TIMESTAMP) 
                              
);
```

3. Ao inserir um lançamento, deverão ser alimentados apenas os campos prod (código do produto), entrada e saída.
4. O campo saldo_ini deve ser omitido
5. O campo data poderá ser oimitido, pois será gerado automaticamente
6. O campo seq deverá ser oimitido, pois será gerado automaticamente

7. Após inserir, o próprio banco de dados ficará encarregado de atualizar o saldo inicial, com base no último lançamento do produto
```sql

CREATE TRIGGER update_saldo 
   AFTER INSERT ON estoque
BEGIN
   UPDATE ESTOQUE set saldo_ini = coalesce(
           (SELECT coalesce(saldo_ini, 0.0)+(coalesce(entrada, 0.0) - coalesce(saida, 0.0))
             FROM estoque
            WHERE seq = (
                              SELECT max(seq) 
                                FROM estoque sub
                               WHERE sub.prod = NEW.PROD and sub.seq < new.seq   --sub.data = master.data
                 
                               group by sub.prod 
                           order by data desc)
      ), 0.00)  --saldo inicial do novo lançamento será o saldo final do ultimo lancamento
      WHERE ESTOQUE.prod = NEW.PROD  and saldo_ini is null;
END;
```

Para testar

Insira vários lançamentos de entrada, saída ou entrada e saída e acompanhe a evolução do saldo
Uma forma inteligente de testar é inserir valores de entrada e saída aleatórios para um determinado produto (informar o parâmetro :PROD)  
Rode o seguinte script várias vezes. O saldo inicial de um produto deverá coincidir com o último saldo final daquele produto
```SQL
INSERT INTO estoque (PROD, ENTRADA, SAIDA) VALUES (:PROD, abs(random() % 9), abs(random() % 9));
```
