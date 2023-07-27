# Cubo com Postgres

![cube](https://github.com/ricardodarocha/SQL/assets/11846512/ead3963a-41df-4bf7-9b5e-d8fdba7f85c9)


## level 1 

_apenas (soma por empresa, ou por vendedor, ou por cliente)_

```sql
select empresa, vendedor, cliente, sum(valor) from vendas
group by grouping sets (empresa, vendedor, cliente)
```
## level 2

_(soma por empresa, por empresa+vendedor, por empresa+vendedor+cliente)_
```sql
select empresa, vendedor, cliente, sum(valor) from vendas
group by rollup (empresa, vendedor, cliente)
```
## level 3 

_(soma cruzada por todas as 6 combinações)_

```sql
select empresa, vendedor, cliente, sum(valor) from vendas
group by cube (empresa, vendedor, cliente)
```
